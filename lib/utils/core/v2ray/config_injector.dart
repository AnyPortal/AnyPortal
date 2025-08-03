import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../models/log_level.dart';
import '../../../models/send_through_binding_stratagy.dart';
import '../../connectivity_manager.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../../runtime_platform.dart';
import '../base/config_injector.dart';

class ConfigInjectorV2Ray extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    if (!cfg.containsKey("outbounds")) {
      cfg["outbounds"] = [];
    }
    (cfg["outbounds"] as List)
        .add({"protocol": "freedom", "tag": "anyportal_ot_freedom"});

    final injectLog = prefs.getBool('inject.log')!;
    final injectApi = prefs.getBool('inject.api')!;
    final injectDnsLocal = prefs.getBool('inject.dns.local')!;
    final logLevel = LogLevel.values[prefs.getInt('inject.log.level')!];
    final serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    final injectSocks = prefs.getBool('inject.socks')!;
    final socksPort = prefs.getInt('app.socks.port')!;
    final injectHttp = prefs.getBool('inject.http')!;
    final httpPort = prefs.getInt('app.http.port')!;
    final injectSendThrough = prefs.getBool('inject.sendThrough')!;
    final sendThroughBindingStratagy = SendThroughBindingStratagy
        .values[prefs.getInt('inject.sendThrough.bindingStratagy')!];

    if (!RuntimePlatform.isWeb && injectLog) {
      final pathLogErr = File(p.join(
        global.applicationSupportDirectory.path,
        'log',
        'core.log',
      )).absolute.path;
      cfg["log"] = {
        "loglevel": logLevel.name,
        "error": pathLogErr,
        "access": pathLogErr,
      };
    }

    if (injectApi) {
      cfg["api"] = {
        "tag": "ot_api",
        "services": ["HandlerService", "StatsService"]
      };

      if (!cfg.containsKey("inbounds")) {
        cfg["inbounds"] = [];
      }

      cfg["inbounds"] += [
        {
          "listen": serverAddress,
          "port": apiPort,
          "protocol": "dokodemo-door",
          "settings": {"address": serverAddress},
          "tag": "in_api"
        }
      ];

      if (!cfg.containsKey("routing")) {
        cfg["routing"] = {"rules": []};
      }

      if (!(cfg["routing"] as Map).containsKey("rules")) {
        cfg["routing"]["rules"] = [];
      }

      (cfg["routing"]["rules"] as List).insert(0, {
        "type": "field",
        "inboundTag": ["in_api"],
        "outboundTag": "ot_api"
      });

      cfg["policy"] = {
        "levels": {
          "0": {"statsUserUplink": true, "statsUserDownlink": true}
        },
        "system": {
          "statsInboundUplink": true,
          "statsInboundDownlink": true,
          "statsOutboundUplink": true,
          "statsOutboundDownlink": true
        }
      };

      cfg["stats"] = {};
    }

    if (injectHttp) {
      (cfg["inbounds"] as List).insert(0, {
        "listen": serverAddress,
        "port": httpPort,
        "protocol": "http",
        "sniffing": {
          "destOverride": ["fakedns+others"],
          "enabled": true,
          "metadataOnly": false
        },
        "tag": "anyportal_in_http"
      });
    }

    if (injectSocks) {
      (cfg["inbounds"] as List).insert(0, {
        "listen": serverAddress,
        "port": socksPort,
        "protocol": "socks",
        "settings": {"udp": true},
        "sniffing": {
          "destOverride": ["fakedns+others"],
          "enabled": true,
          "metadataOnly": false
        },
        "tag": "anyportal_in_socks"
      });
    }

    String? dnsInboundTag;
    bool didInjectDnsLocal = false;
    if (injectDnsLocal) {
      /// find outbound domains and add them to dns "localhost"
      /// not to confuse with "localhost" like 127.0.0.1
      /// "localhost" in v2ray/xray dns config means system dns
      if (!cfg.containsKey("outbounds")) {
        cfg["outbounds"] = <Map<String, dynamic>>[];
      }
      final outbounds = (cfg["outbounds"] as List).cast<Map<String, dynamic>>();
      final outboundsDomains = extractDomains(outbounds);
      if (outboundsDomains.isNotEmpty) {
        if (!cfg.containsKey("dns")) {
          cfg["dns"] = <String, dynamic>{};
        }
        if (!(cfg["dns"] as Map).containsKey("servers")) {
          cfg["dns"]["servers"] = <dynamic>[];
        }

        /// add as the first dns server with domains
        int i = 0;
        for (i = 0; i < (cfg["dns"]["servers"] as List).length; ++i) {
          dynamic server = cfg["dns"]["servers"][i];
          if (server is! Map) {
            continue;
          }
          if (server.containsKey("domains")) {
            break;
          }
        }
        (cfg["dns"]["servers"] as List).insert(i, {
          "address": "localhost",
          "domains": outboundsDomains,
        });
      }

      /// patch dns records where server is "localhost"
      if (cfg.containsKey("dns") &&
          (cfg["dns"] as Map).containsKey("servers")) {
        for (final (i, server) in (cfg["dns"]["servers"] as List).indexed) {
          if (server is String) {
            if (server == "localhost") {
              final dnsStr = await ConnectivityManager().getEffectiveDnsStr();
              if (dnsStr == null) {
                break;
              }
              cfg["dns"]["servers"][i] = dnsStr;
              didInjectDnsLocal = true;
            }
          } else if (server is Map) {
            if (server["address"] == "localhost") {
              final dnsStr = await ConnectivityManager().getEffectiveDnsStr();
              if (dnsStr == null) {
                break;
              }
              server["address"] = dnsStr;
              didInjectDnsLocal = true;
            }
          }
        }
        if ((cfg["dns"] as Map).containsKey("tag")) {
          dnsInboundTag = cfg["dns"]["tag"];
        } else {
          dnsInboundTag = "anyportal_in_dns";
          cfg["dns"]["tag"] = "anyportal_in_dns";
        }
      }

      /// all dns requests that shall be sent to system dns,
      /// as determined by v2ray/xray internal dns server "in_dns"
      /// shall be sent there directly
      if (didInjectDnsLocal) {
        if (!cfg.containsKey("routing")) {
          cfg["routing"] = {"rules": []};
        }
        if (!(cfg["routing"] as Map).containsKey("rules")) {
          cfg["routing"]["rules"] = [];
        }
        final effectiveNetInterface =
            await ConnectivityManager().getEffectiveNetInterface();
        final dns = effectiveNetInterface!.dns;
        (cfg["routing"]["rules"] as List).insert(0, {
          "type": "field",
          "inboundTag": [dnsInboundTag],
          "ip": [
            ...dns.ipv4,
            ...dns.ipv6,
          ],
          "port": 53,
          "outboundTag": "anyportal_ot_freedom"
        });
      }
    }

    if (injectSendThrough) {
      String? sendThrough;
      String? interfaceName;
      if (injectSendThrough) {
        switch (sendThroughBindingStratagy) {
          case SendThroughBindingStratagy.internet:
            final effectiveNetInterface =
                await ConnectivityManager().getEffectiveNetInterface();
            interfaceName = effectiveNetInterface?.name;
          case SendThroughBindingStratagy.ip:
            sendThrough = prefs.getString('inject.sendThrough.bindingIp')!;
          case SendThroughBindingStratagy.interface:
            interfaceName =
                prefs.getString('inject.sendThrough.bindingInterface')!;
        }
      }
      if (!cfg.containsKey("outbounds")) {
        cfg["outbounds"] = <Map<String, dynamic>>[];
      }
      final outbounds = (cfg["outbounds"] as List).cast<Map<String, dynamic>>();
      for (var (i, outbound) in outbounds.indexed) {
        if (sendThrough != null) {
          outbound["sendThrough"] = sendThrough;
        }
        if (interfaceName != null) {
          if (!outbound.containsKey("streamSettings")) {
            Map<String, dynamic> newOutbound = {...outbound};
            outbounds[i] = newOutbound;
            outbound = newOutbound;
            newOutbound["streamSettings"] = {};
          }
          final streamSettings =
              (outbound["streamSettings"] as Map).cast<String, dynamic>();
          if (!streamSettings.containsKey("sockopt")) {
            (streamSettings as Map).cast<String, dynamic>()["sockopt"] = {};
          }
          final sockopt =
              (streamSettings["sockopt"] as Map).cast<String, dynamic>();
          sockopt["bindToDevice"] = interfaceName;
          sockopt["interface"] = interfaceName;
        }
      }
    }

    /// tun settings (v2ray) not working
    // if (!cfg.containsKey("services")) {
    //   cfg["services"] = {};
    // }
    // cfg["services"]["tun"] = {
    //   "name": "tun0",
    //   "mtu": 8500,
    //   "tag": "in_tun",
    //   "ips": [
    //     {
    //       "ip": [172, 19, 0, 1],
    //       "prefix": 30
    //     }
    //   ],
    //   "routes": [
    //     {
    //       "ip": [0, 0, 0, 0],
    //       "prefix": 0
    //     }
    //     // , { "ip": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "prefix": 0 }
    //   ],
    //   "enablePromiscuousMode": true,
    //   "enableSpoofing": true,
    //   "packetEncoding": "Packet",
    //   "sniffingSettings": {
    //     "destinationOverride": ["fakedns+others"],
    //     "enabled": true,
    //     "metadataOnly": false,
    //   },
    // };

    return jsonEncode(cfg);
  }
}

/// Extracts all server domain names from various outbound protocols
List<String> extractDomains(dynamic outbounds) {
  final domains = <String>{};

  if (outbounds is! List) return [];

  for (final ob in outbounds) {
    if (ob is! Map) continue;
    final settings = ob['settings'];
    if (settings == null) continue;

    if (settings is Map) {
      /// vmess, vless
      if (settings.containsKey('vnext')) {
        for (var node in settings['vnext']) {
          if (node is Map && isDomain(node['address'])) {
            domains.add(node['address']);
          }
        }
      }

      /// trojan, shadowsocks
      if (settings.containsKey('servers')) {
        for (var node in settings['servers']) {
          if (node is Map && isDomain(node['address'])) {
            domains.add(node['address']);
          }
        }
      }

      /// socks / http / others
      if (settings.containsKey('address') && isDomain(settings['address'])) {
        domains.add(settings['address']);
      }
    }
  }

  return domains.toList();
}

bool isDomain(dynamic value) {
  if (value is! String) return false;
  final ipPattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
  return !ipPattern.hasMatch(value);
}
