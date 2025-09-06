import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'base.dart';

class ProfileGroupRemoteGeneric extends ProfileGroupRemoteBase {
  ProfileGroupRemoteGeneric(super.profiles);
  static final logger = GetIt.I<Logger>();

  factory ProfileGroupRemoteGeneric.fromString(String s) {
    final List<Profile> profiles = [];

    String decoded = "";
    try {
      decoded = utf8.decode(base64.decode(s));
    } catch (_) {
      decoded = s;
    }

    List<String> lines = LineSplitter().convert(decoded);
    final meta = <String, String>{};
    for (final line in lines) {
      if (line.startsWith("#")) {
        try {
          final splitted = line.substring(1).split(": ");
          if (splitted.length >= 2) {
            final key = splitted[0];
            String value = splitted.sublist(1).join();
            if (value.startsWith("base64:")) {
              value = utf8.decode(base64.decode(value.substring(7)));
            }
            meta[key] = value;
          }
        } catch (_) {}
        continue;
      }

      final profile = ProfileRemoteGeneric.fromString(line);
      if (profile != null) {
        profiles.add(profile);
      } else {
        logger.w("failed to decode profile: $line");
      }
    }

    return ProfileGroupRemoteGeneric(profiles);
  }
}

enum ProxyProtocolScheme {
  trojan,
  ss,
  vmess,
  vless,
}

enum ProxyProtocol {
  trojan,
  shadowsocks,
  vmess,
  vless,
}

extension ProxyProtocolX on ProxyProtocol {
  static ProxyProtocol? fromSchemeString(String s) {
    switch (s) {
      case "ss":
        return ProxyProtocol.shadowsocks;
      case _:
        return ProxyProtocol.values.asNameMap()[s];
    }
  }
}

/// https://github.com/XTLS/Xray-core/issues/91
/// https://github.com/Gozargah/Marzban/blob/master/app/subscription/v2ray.py
class ProfileRemoteGeneric extends Profile {
  ProfileRemoteGeneric(
    super.name,
    super.key,
    super.coreType,
    super.format,
    super.coreConfig,
  );

  static final logger = GetIt.I<Logger>();

  static Profile? fromString(String s) {
    Uri uri;
    try {
      uri = Uri.parse(s);
    } catch (_) {
      logger.w("failed to parse uri: $s");
      return null;
    }

    final proxyProtocolSchemeString = uri.scheme;
    final proxyProtocol = ProxyProtocolX.fromSchemeString(
      proxyProtocolSchemeString,
    );
    if (proxyProtocol == null) return null;

    Map<String, String> queryParameters;
    String userInfo;
    String host;
    int port;
    String fragment;

    try {
      /// as base64 encoded json string
      String decoded = utf8.decode(
        base64.decode(s.split("://").sublist(1).join()),
      );
      queryParameters = (json.decode(decoded) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
      userInfo = queryParameters["id"]!;
      host = queryParameters["add"]!;
      port = int.parse(queryParameters["port"]!);
      fragment = queryParameters["ps"]!;
    } catch (_) {
      /// as uri
      queryParameters = uri.queryParameters;
      userInfo = Uri.decodeComponent(uri.userInfo);
      host = uri.host;
      port = uri.port;
      fragment = Uri.decodeComponent(uri.fragment);
    }

    final key = uri.toString();
    final name = fragment.isNotEmpty ? fragment : "$host:$port";
    final coreType = "xray";
    final format = "json";

    final settings = getSettings(
      proxyProtocol,
      host,
      port,
      userInfo,
      queryParameters,
    );
    if (settings == null) return null;

    final streamSettings = getStreamSettings(
      queryParameters,
    );

    final coreConfigMap = <String, dynamic>{
      "outbounds": [
        {
          "protocol": proxyProtocol.name,
          "settings": settings,
          "streamSettings": streamSettings,
        },
      ],
    };

    return Profile(
      name,
      key,
      coreType,
      format,
      json.encode(coreConfigMap),
    );
  }

  /// put if not null
  static void pinn(Map<String, dynamic> m, k, v) {
    if (v == null) return;
    m[k] = v;
  }

  static Map<String, dynamic> getStreamSettings(Map<String, String> m) {
    final streamSettings = <String, dynamic>{};

    final security = m["security"];
    final network = m["type"] ?? "tcp";
    final headerType = m["headerType"];
    pinn(streamSettings, "security", security);
    pinn(streamSettings, "network", network);

    final networkSettings = <String, dynamic>{};
    switch (network) {
      case "grpc":
        pinn(networkSettings, "serviceName", m['serviceName']);
        pinn(networkSettings, "authority", m["authority"]);
        pinn(networkSettings, "multiMode", m["mode"] == "multi");
      case "quic":
        pinn(networkSettings, "key", m['key']);
        pinn(networkSettings, "quicSecurity", m['quicSecurity']);
        if (headerType != null) {
          pinn(networkSettings, "header", {"type": headerType});
        }
      case "splithttp":
      case "xhttp":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        pinn(networkSettings, "mode", m['mode']);
        if (m["extra"] != null) {
          pinn(networkSettings, "extra", json.decode(m["extra"]!));
        }
      case "ws":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        pinn(networkSettings, "heartbeatPeriod", m['heartbeatPeriod']);
      case "kcp":
        pinn(networkSettings, "seed", m['path']);
        pinn(networkSettings, "host", m['host']);
        if (headerType != null) {
          pinn(networkSettings, "header", {"type": headerType});
        }
      case "raw":
      case "tcp":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        if (headerType != null) {
          pinn(networkSettings, "header", {"type": headerType});
        }
      case _:
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
    }
    streamSettings["${network}Settings"] = networkSettings;

    final securitySettings = <String, dynamic>{};
    switch (security) {
      case "tls":
        pinn(securitySettings, "sni", m['sni']);
        pinn(securitySettings, "fingerprint", m['fp'] ?? "random");
        pinn(securitySettings, "alpn", m["alpn"]?.split(','));
        pinn(securitySettings, "fragment", m['fragment']);
        pinn(
          securitySettings,
          "allowInsecure",
          ["true", "True", "1"].contains(m['allowInsecure']) ? true : null,
        );
      case "reality":
        pinn(securitySettings, "sni", m['sni']);
        pinn(securitySettings, "fingerprint", m['fp']);
        pinn(securitySettings, "publicKey", m['pbk']);
        pinn(securitySettings, "shortId", m['sid']);
        pinn(securitySettings, "spiderX", m['spx']);
    }
    if (["tls", "reality"].contains(security)) {
      streamSettings["${security}Settings"] = securitySettings;
    }

    return streamSettings;
  }

  static Map<String, dynamic>? getSettings(
    ProxyProtocol proxyProtocol,
    String host,
    int port,
    String userInfo,
    Map<String, String> queryParameters,
  ) {
    switch (proxyProtocol) {
      case ProxyProtocol.trojan:
        return {
          "servers": [
            {
              "address": host,
              "port": port,
              "password": userInfo,
            },
          ],
        };
      case ProxyProtocol.vless:
      case ProxyProtocol.vmess:
        return {
          "vnext": [
            {
              "address": host,
              "port": port,
              "users": [
                {
                  "id": userInfo,
                  "encryption": "none",
                  if (queryParameters["flow"] != null)
                    "flow": queryParameters["flow"],
                },
              ],
            },
          ],
        };
      case ProxyProtocol.shadowsocks:
        final decoded = utf8.decode(base64.decode(normalizeBase64(userInfo)));
        final methodPassword = decoded.split(":");
        if (methodPassword.length != 2) {
          logger.w(
            "getSettings: failed to parse methodPassword: $methodPassword",
          );
          return null;
        }
        return {
          "servers": [
            {
              "address": host,
              "port": port,
              "password": methodPassword[1],
              "method": methodPassword[0],
            },
          ],
        };
      // ignore: unreachable_switch_case
      case _:
        logger.w("getSettings: unknown proxyProtocol: $proxyProtocol");
        return null;
    }
  }

  static String normalizeBase64(String input) {
    /// Add padding if necessary
    int remainder = input.length % 4;
    if (remainder > 0) {
      input += '=' * (4 - remainder);
    }
    return input;
  }
}
