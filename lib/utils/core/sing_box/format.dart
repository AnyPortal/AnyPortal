import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../models/profile_group_remote/generic.dart';
import '../base/format.dart';

class FormatSingBox extends FormatBase {
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

    final fields = getOutboundFields(
      proxyProtocol,
      host,
      port,
      userInfo,
      payload,
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

    return json.encode(coreConfigMap);
  }

  /// https://sing-box.sagernet.org/configuration/outbound/
  Map<String, dynamic>? getOutboundFields(
    ProxyProtocol proxyProtocol,
    String host,
    int port,
    String userInfo,
    Map<String, String> payload,
  ) {
    switch (proxyProtocol) {
      case ProxyProtocol.trojan:
        final fields = {
          "server": host,
          "server_port": port,
          "password": userInfo,
        };
        pinn(fields, "tls", getTLS(payload));
        pinn(fields, "transport", getTransport(payload));
        return fields;
      case ProxyProtocol.vless:
      case ProxyProtocol.vmess:
        final alterId = payload["alterId"] != null
            ? int.tryParse(payload["alterId"]!)
            : null;
        final fields = {
          "server": host,
          "server_port": port,
          "uuid": userInfo,
          if (alterId != null) "alter_id": alterId,
          if (payload["flow"] != null) "flow": payload["flow"],
          if (payload["encryption"] != null) "security": payload["encryption"],
        };
        pinn(fields, "tls", getTLS(payload));
        pinn(fields, "transport", getTransport(payload));
        return fields;
      case ProxyProtocol.shadowsocks:
        final decoded = utf8.decode(base64.decode(normalizeBase64(userInfo)));
        final methodPassword = decoded.split(":");
        if (methodPassword.length != 2) {
          logger.w(
            "getOutboundFields: failed to parse methodPassword: $methodPassword",
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
          "getOutboundFields: unknown proxyProtocol: $proxyProtocol",
        );
        return null;
    }
  }

  /// https://sing-box.sagernet.org/configuration/shared/v2ray-transport/
  Map<String, dynamic>? getTransport(
    Map<String, String> m,
  ) {
    final transport = <String, dynamic>{};

    final network = m["type"] ?? "tcp";
    pinn(transport, "type", network);
    // final headerType = m["headerType"];

    switch (network) {
      case "http":
        pinn(transport, "path", m['path']);
        transport["host"] = m['host']?.split(',') ?? [m["remote-host"]!];
      case "ws":
        pinn(transport, "path", m['path'] ?? "/");
      case "quic":
        break;
      case "grpc":
        pinn(transport, "service_name", m['serviceName']);
      case "httpupgrade":
        pinn(transport, "path", m['path']);
        pinn(transport, "host", m['host']);
      case _:
        logger.w("getTransport: unsupported: $network");
        throw Exception("getTransport: unsupported: $network");
    }

    return transport.isEmpty ? null : transport;
  }

  /// https://sing-box.sagernet.org/configuration/shared/tls/
  Map<String, dynamic>? getTLS(
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
