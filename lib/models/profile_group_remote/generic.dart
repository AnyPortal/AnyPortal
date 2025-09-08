import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'base.dart';

class ProfileGroupRemoteGeneric extends ProfileGroupRemoteBase {
  ProfileGroupRemoteGeneric(
    super.profiles, {
    super.name,
    super.autoUpdateInterval,
    super.subscriptionUserInfo,
    super.supportUrl,
    super.profileWebPageUrl,
  });
  static final logger = GetIt.I<Logger>();

  factory ProfileGroupRemoteGeneric.fromString(String s, String coreTypeName) {
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

      try {
        final profile = ProfileRemoteGeneric.fromString(line, coreTypeName);
        if (profile != null) {
          profiles.add(profile);
        } else {
          logger.w("failed to decode profile: $line");
        }
      } catch (e) {
        logger.w(e);
      }
      continue;
    }

    Map<String, dynamic> parseKeyValueString(String? input) {
      if (input == null) return {};
      final Map<String, dynamic> result = {};

      /// Split by semicolon
      final parts = input.split(';');
      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;

        /// Split each "key=value"
        final kv = part.split('=');
        if (kv.length == 2) {
          final key = kv[0].trim();
          final value = kv[1].trim();

          /// Try parsing as int if possible, otherwise leave as string
          final intValue = int.tryParse(value);
          result[key] = intValue ?? value;
        }
      }

      return result;
    }

    return ProfileGroupRemoteGeneric(
      profiles,
      name: meta["profile-title"],
      autoUpdateInterval: int.tryParse(meta["profile-update-interval"] ?? ""),
      subscriptionUserInfo: SubscriptionUserInfo.fromJson(
        parseKeyValueString(meta["subscription-userinfo"]),
      ),
      supportUrl: meta["support-url"],
      profileWebPageUrl: meta["profile-web-page-url"],
    );
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

  static Profile? fromString(String s, String coreTypeName) {
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

    final key = uri.removeFragment().toString();
    final name = fragment.isNotEmpty ? fragment : "$host:$port";

    switch (coreTypeName) {
      case "v2ray":
      case "xray":
        final format = "json";

        final settings = getV2rayOutboundSettings(
          proxyProtocol,
          host,
          port,
          userInfo,
          queryParameters,
        );
        if (settings == null) return null;

        final streamSettings = getV2rayOutboundStreamSettings(
          queryParameters,
        );

        /// https://xtls.github.io/config/outbound.html
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
          null,
          format,
          json.encode(coreConfigMap),
        );
      case "sing-box":
        final format = "json";

        final fields = getSingBoxOutboundFields(
          proxyProtocol,
          host,
          port,
          userInfo,
          queryParameters,
        );
        if (fields == null) return null;

        /// https://sing-box.sagernet.org/configuration/outbound/
        final coreConfigMap = <String, dynamic>{
          "outbounds": [
            {
              "type": proxyProtocol.name,
              ...fields,
            },
          ],
        };

        return Profile(
          name,
          key,
          coreTypeName,
          format,
          json.encode(coreConfigMap),
        );
      case _:
        logger.w(
          "coreType not supported: $coreTypeName",
        );
        return null;
    }
  }

  /// put if not null
  static void pinn(Map<String, dynamic> m, String k, dynamic v) {
    if (v == null) return;
    m[k] = v;
  }

  /// https://xtls.github.io/config/transport.html#streamsettingsobject
  static Map<String, dynamic> getV2rayOutboundStreamSettings(
    Map<String, String> m,
  ) {
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
          networkSettings["header"] = {"type": headerType};
        }
      case "splithttp":
      case "xhttp":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        pinn(networkSettings, "mode", m['mode']);
        if (m["extra"] != null) {
          networkSettings["extra"] = json.decode(m["extra"]!);
        }
      case "ws":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        pinn(networkSettings, "heartbeatPeriod", m['heartbeatPeriod']);
      case "kcp":
        pinn(networkSettings, "seed", m['path']);
        pinn(networkSettings, "host", m['host']);
        if (headerType != null) {
          networkSettings["header"] = {"type": headerType};
        }
      case "raw":
      case "tcp":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        if (headerType != null) {
          networkSettings["header"] = {"type": headerType};
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

  /// https://xtls.github.io/config/outbounds/
  static Map<String, dynamic>? getV2rayOutboundSettings(
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
            "getV2rayOutboundSettings: failed to parse methodPassword: $methodPassword",
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
        logger.w(
          "getV2rayOutboundSettings: unknown proxyProtocol: $proxyProtocol",
        );
        return null;
    }
  }

  /// https://sing-box.sagernet.org/configuration/outbound/
  static Map<String, dynamic>? getSingBoxOutboundFields(
    ProxyProtocol proxyProtocol,
    String host,
    int port,
    String userInfo,
    Map<String, String> m,
  ) {
    switch (proxyProtocol) {
      case ProxyProtocol.trojan:
        final fields = {
          "server": host,
          "server_port": port,
          "password": userInfo,
        };
        pinn(fields, "tls", getSingBoxTLS(m));
        pinn(fields, "transport", getSingBoxTransport(m));
        return fields;
      case ProxyProtocol.vless:
      case ProxyProtocol.vmess:
        final fields = {
          "server": host,
          "server_port": port,
          "uuid": userInfo,
          if (m["flow"] != null) "flow": m["flow"],
        };
        pinn(fields, "tls", getSingBoxTLS(m));
        pinn(fields, "transport", getSingBoxTransport(m));
        return fields;
      case ProxyProtocol.shadowsocks:
        final decoded = utf8.decode(base64.decode(normalizeBase64(userInfo)));
        final methodPassword = decoded.split(":");
        if (methodPassword.length != 2) {
          logger.w(
            "getSingBoxOutboundFields: failed to parse methodPassword: $methodPassword",
          );
          return null;
        }
        return {
          "server": host,
          "server_port": port,
          "method": methodPassword[0],
          "password": methodPassword[1],
        };
      // ignore: unreachable_switch_case
      case _:
        logger.w(
          "getSingBoxOutboundFields: unknown proxyProtocol: $proxyProtocol",
        );
        return null;
    }
  }

  /// https://sing-box.sagernet.org/configuration/shared/v2ray-transport/
  static Map<String, dynamic>? getSingBoxTransport(
    Map<String, String> m,
  ) {
    final transport = <String, dynamic>{};

    final network = m["type"] ?? "tcp";
    pinn(transport, "type", network);
    // final headerType = m["headerType"];

    switch (network) {
      case "http":
        pinn(transport, "path", m['path']);
        pinn(transport, "host", m['host']?.split(','));
      case "ws":
        pinn(transport, "path", m['path']);
      case "quic":
        break;
      case "grpc":
        pinn(transport, "service_name", m['serviceName']);
      case "httpupgrade":
        pinn(transport, "path", m['path']);
        pinn(transport, "host", m['host']);
      case _:
        logger.w("getSingBoxTransport: unsupported: $network");
        throw Exception("getSingBoxTransport: unsupported: $network");
    }

    return transport.isEmpty ? null : transport;
  }

  /// https://sing-box.sagernet.org/configuration/shared/tls/
  static Map<String, dynamic>? getSingBoxTLS(
    Map<String, String> m,
  ) {
    final tls = <String, dynamic>{};

    final security = m["security"];
    if (!["tls", "reality"].contains(security)) {
      tls["enabled"] = false;
    }
    pinn(tls, "server_name", m['sni']);
    if (m['fp'] != null) {
      tls["utls"] = {"enabled": false, "fingerprint": m['fp']};
    }
    pinn(tls, "alpn", m["alpn"]?.split(','));
    pinn(
      tls,
      "insecure",
      ["true", "True", "1"].contains(m['allowInsecure']) ? true : null,
    );

    if (security == "reality") {
      final reality = <String, dynamic>{};
      pinn(reality, "enabled", true);
      pinn(reality, "public_key", m['pbk']);
      pinn(reality, "short_id", m['sid']);
      tls["reality"] = reality;
    }

    return tls.isEmpty ? null : tls;
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
