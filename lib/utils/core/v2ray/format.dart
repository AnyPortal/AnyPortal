import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../models/profile_group_remote/generic.dart';
import '../base/format.dart';

/// https://github.com/Gozargah/Marzban/blob/master/app/subscription/v2ray.py
class FormatV2ray extends FormatBase {
  static final logger = GetIt.I<Logger>();

  @override
  String? fromRemoteGeneric(String s, String coreCfgFmt) {
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

    Map<String, String> payload;
    String userInfo;
    String host;
    int port;

    try {
      /// as base64 encoded json string
      // payload = {
      //   "add":  "",                                          [uri.host]
      //   "aid":  "", /// alterid                              ["alterId"]
      //   "host": "", /// streamSettings host
      //   "id":   "", /// vmess, vless user id                 [uri.userInfo]
      //   "net":  "", /// "tcp" | "ws" | ...                   ["type"]
      //   "path": "", /// streamSettings path
      //   "port": "",                                          [uri.port]
      //   "ps":   "", /// remark                               [uri.fragment]
      //   "scy":  "", /// vmess security                       ["encryption"]
      //   "tls":  "", /// "tls" | "xtls" | "reality" | "none"  ["security"]
      //   "type": "", /// headerType                           ["headerType"]
      //   "v":   "2",
      // }
      String decoded = utf8.decode(
        base64.decode(s.split("://").sublist(1).join()),
      );
      payload = (json.decode(decoded) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
      userInfo = payload["id"]!;
      host = payload["add"]!;
      port = int.parse(payload["port"]!);

      pinn(payload, "alterId", payload["aid"]);
      pinn(payload, "security", payload["tls"]);
      pinn(payload, "headerType", payload["type"]);
      pinn(payload, "type", payload["net"]);
      pinn(payload, "encryption", payload["scy"]);
    } catch (_) {
      /// as uri
      /// https://github.com/XTLS/Xray-core/issues/91
      payload = {...uri.queryParameters};
      userInfo = Uri.decodeComponent(uri.userInfo);
      host = uri.host;
      port = uri.port;
    }

    pinn(payload, "remote-host", host);

    final settings = getOutboundSettings(
      proxyProtocol,
      host,
      port,
      userInfo,
      payload,
    );
    if (settings == null) return null;

    final streamSettings = getOutboundStreamSettings(
      payload,
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

    return json.encode(coreConfigMap);
  }

  /// https://xtls.github.io/config/outbounds/
  Map<String, dynamic>? getOutboundSettings(
    ProxyProtocol proxyProtocol,
    String host,
    int port,
    String userInfo,
    Map<String, String> payload,
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
        final alterId = payload["alterId"] != null
            ? int.tryParse(payload["alterId"]!)
            : null;
        return {
          "vnext": [
            {
              "address": host,
              "port": port,
              "users": [
                {
                  "id": userInfo,
                  if (alterId != null) "alterId": alterId,
                  if (payload["flow"] != null) "flow": payload["flow"],
                  if (payload["encryption"] != null)
                    "security": payload["encryption"],
                  if (proxyProtocol == ProxyProtocol.vless)
                    "encryption": "none",
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
            "getOutboundSettings: failed to parse methodPassword: $methodPassword",
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
          "getOutboundSettings: unknown proxyProtocol: $proxyProtocol",
        );
        return null;
    }
  }

  /// https://xtls.github.io/config/transport.html#streamsettingsobject
  Map<String, dynamic> getOutboundStreamSettings(
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
      case "http":
        pinn(networkSettings, "path", m['path']);
        networkSettings["host"] = m['host']?.split(",") ?? [m["remote-host"]!];
      case "splithttp":
      case "xhttp":
        pinn(networkSettings, "path", m['path']);
        pinn(networkSettings, "host", m['host']);
        pinn(networkSettings, "mode", m['mode']);
        if (m["extra"] != null) {
          networkSettings["extra"] = json.decode(m["extra"]!);
        }
      case "ws":
        pinn(networkSettings, "path", m['path'] ?? "/");
        pinn(networkSettings, "host", m['host']);
        pinn(networkSettings, "heartbeatPeriod", m['heartbeatPeriod']);
      case "kcp":
        pinn(networkSettings, "seed", m['seed']);
        pinn(networkSettings, "host", m['host']);
        networkSettings["header"] = {"type": headerType ?? "none"};
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
        pinn(securitySettings, "serverName", m['sni']);
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

  /// put if not null
  void pinn(Map<String, dynamic> m, String k, dynamic v) {
    if (v == null) return;
    m[k] = v;
  }

  String normalizeBase64(String input) {
    /// Add padding if necessary
    int remainder = input.length % 4;
    if (remainder > 0) {
      input += '=' * (4 - remainder);
    }
    return input;
  }
}
