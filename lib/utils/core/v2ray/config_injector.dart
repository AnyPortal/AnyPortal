import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart' as p;

import '../../../extensions/localization.dart';
import '../../../models/log_level.dart';
import '../../../models/send_through_binding_stratagy.dart';
import '../../connectivity_manager.dart';
import '../../get_local_ip.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../../runtime_platform.dart';
import '../../show_snack_bar_now.dart';
import '../../with_context.dart';
import '../base/config_injector.dart';

class ConfigInjectorV2Ray extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    Map<String, dynamic> cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

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

    if (injectSocks) {
      (cfg["inbounds"] as List).insert(0, {
        "listen": serverAddress,
        "port": socksPort,
        "protocol": "socks",
        "settings": {"udp": true},
        "sniffing": {"enabled": true},
        "tag": "anyportal_in_socks"
      });
    }

    String? dnsInboundTag;
    bool didInjectDnsLocal = false;
    if (injectDnsLocal) {
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
      String sendThrough = "0.0.0.0";
      if (injectSendThrough) {
        switch (sendThroughBindingStratagy) {
          case SendThroughBindingStratagy.internet:
            final effectiveNetInterface =
                await ConnectivityManager().getEffectiveNetInterface();
            final internetIp = effectiveNetInterface?.ip.ipv4.first ??
                effectiveNetInterface?.ip.ipv6.first;
            if (internetIp != null) {
              sendThrough = internetIp;
            }
          case SendThroughBindingStratagy.ip:
            sendThrough = prefs.getString('inject.sendThrough.bindingIp')!;
          case SendThroughBindingStratagy.interface:
            final bindingInterface =
                prefs.getString('inject.sendThrough.bindingInterface')!;
            final ip = await getIPv4OfInterfaceName(bindingInterface);
            if (ip == null) {
              withContext((context) {
                showSnackBarNow(
                    context,
                    Text(context.loc
                        .ip_not_found_for_binding_interface_binding_interface(
                            bindingInterface)));
              });
              throw Exception(
                  'IP not found for binding interface: $bindingInterface');
            }
            sendThrough = ip;
        }
      }

      for (var outbound in cfg["outbounds"]) {
        outbound["sendThrough"] = sendThrough;
      }
    }

    /// still not working
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
