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
    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    if (!cfg.containsKey("inbounds")) {
      cfg["inbounds"] = [];
    }
    final inbounds = (cfg["inbounds"] as List).cast<Map<String, dynamic>>();

    if (!cfg.containsKey("outbounds")) {
      cfg["outbounds"] = [];
    }
    final outbounds = (cfg["outbounds"] as List).cast<Map<String, dynamic>>();

    if (!cfg.containsKey("routing")) {
      cfg["routing"] = {"rules": []};
    }
    if (!(cfg["routing"] as Map).containsKey("rules")) {
      cfg["routing"]["rules"] = [];
    }
    final routingRules = cfg["routing"]["rules"] as List;

    if (!cfg.containsKey("dns")) {
      cfg["dns"] = <String, dynamic>{};
    }
    if (!(cfg["dns"] as Map).containsKey("servers")) {
      cfg["dns"]["servers"] = <dynamic>[];
    }
    final dnsServers = cfg["dns"]["servers"] as List;

    final injectLog = prefs.getBool('inject.log')!;
    final injectApi = prefs.getBool('inject.api')!;
    final injectFakeDns = prefs.getBool('inject.dns.fakedns')!;
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

    outbounds.add({"protocol": "freedom", "tag": "anyportal_ot_freedom"});

    if (!RuntimePlatform.isWeb && injectLog) {
      final pathLogErr = File(
        p.join(global.applicationSupportDirectory.path, 'log', 'core.log'),
      ).absolute.path;
      cfg["log"] = {
        "loglevel": logLevel.name,
        "error": pathLogErr,
        "access": pathLogErr,
      };
    }

    if (injectApi) {
      cfg["api"] = {
        "tag": "ot_api",
        "services": ["HandlerService", "StatsService"],
      };

      inbounds.add({
        "listen": serverAddress,
        "port": apiPort,
        "protocol": "dokodemo-door",
        "settings": {"address": serverAddress},
        "tag": "in_api",
      });

      routingRules.insert(0, {
        "type": "field",
        "inboundTag": ["in_api"],
        "outboundTag": "ot_api",
      });

      cfg["policy"] = {
        "levels": {
          "0": {
            "statsUserUplink": true,
            "statsUserDownlink": true,
          },
        },
        "system": {
          "statsInboundUplink": true,
          "statsInboundDownlink": true,
          "statsOutboundUplink": true,
          "statsOutboundDownlink": true,
        },
      };

      cfg["stats"] = {};
    }

    if (injectHttp) {
      inbounds.insert(0, {
        "listen": serverAddress,
        "port": httpPort,
        "protocol": "http",
        "sniffing": {
          "destOverride": ["fakedns+others"],
          "enabled": true,
          "metadataOnly": false,
        },
        "tag": "anyportal_in_http",
      });
    }

    if (injectSocks) {
      inbounds.insert(0, {
        "listen": serverAddress,
        "port": socksPort,
        "protocol": "socks",
        "settings": {"udp": true},
        "sniffing": {
          "destOverride": ["fakedns+others"],
          "enabled": true,
          "metadataOnly": false,
        },
        "tag": "anyportal_in_socks",
      });
    }

    /// find if dns outbound is configured
    String? dnsOutboundTag;
    for (final outbound in outbounds) {
      if (outbound.containsKey("protocol") &&
          outbound["protocol"] == "dns" &&
          outbound.containsKey("tag")) {
        dnsOutboundTag = outbound["tag"];
        break;
      }
    }
    if (dnsOutboundTag == null) {
      dnsOutboundTag = "anyportal_ot_dns";

      /// no dns outbound, add one, no side effect
      outbounds.add({
        "protocol": "dns",
        "tag": dnsOutboundTag,
      });
    }

    /// hijack default dns requests
    /// - if original config alreay has hijack rule,
    ///   - it doesn't matter if we add another on top
    /// - if original config does not have hijack rule,
    ///   - if it queries tun dns, they should be hijacked or it's invalid
    ///   - if it queries local dns, they should be hijacked or it's dns leak
    /// need to reboot core when local dns changes!
    final effectiveNetInterface = await ConnectivityManager()
        .getEffectiveNetInterface();
    final dns = effectiveNetInterface!.dns;
    routingRules.insert(0, {
      "type": "field",
      "outboundTag": dnsOutboundTag,
      "port": 53,
      "network": "udp",
      "ip": [
        // if (RuntimePlatform.isWindows || RuntimePlatform.isLinux)
        "172.19.0.2",
        // if (RuntimePlatform.isWindows || RuntimePlatform.isLinux)
        "fdfe:dcba:9876::2",
        // if (RuntimePlatform.isMacOS || RuntimePlatform.isAndroid)
        ...dns.ipv4,
        // if (RuntimePlatform.isMacOS || RuntimePlatform.isAndroid)
        ...dns.ipv6,
      ],
    });

    /// add fakedns
    /// - if original config alreay have fakedns
    ///   - it doesn't matter if we add another at bottom
    /// - if original config does not have fakedns but has a proper config
    ///   - this will block dns fallback!
    /// - if original config does not have a proper dns config
    ///   - this is a proper one and thus necessary
    if (injectFakeDns) {
      dnsServers.add("fakedns");
    }

    /// all outbound domains should be resolved by system dns
    /// find outbound domains and add them to dns "localhost"
    /// not to confuse with "localhost" like 127.0.0.1
    /// "localhost" in v2ray/xray dns config means system dns
    /// no side effect
    final outboundsDomains = extractDomains(outbounds);
    if (outboundsDomains.isNotEmpty) {
      /// add as the first dns server with domains
      int i = 0;
      for (i = 0; i < dnsServers.length; ++i) {
        dynamic server = dnsServers[i];
        if (server is! Map) {
          continue;
        }
        if (server.containsKey("domains")) {
          break;
        }
      }
      dnsServers.insert(i, {
        "address": "localhost",
        "domains": outboundsDomains,
      });
    }

    /// currently only one dns record is used!
    /// maybe duplicate those records to use alternatives
    if (injectDnsLocal) {
      /// patch dns records where server is "localhost"
      for (final (i, server) in dnsServers.indexed) {
        if (server is String) {
          if (server == "localhost") {
            final dnsStr = await ConnectivityManager().getEffectiveDnsStr();
            if (dnsStr == null) {
              break;
            }
            dnsServers[i] = dnsStr;
          }
        } else if (server is Map) {
          if (server["address"] == "localhost") {
            final dnsStr = await ConnectivityManager().getEffectiveDnsStr();
            if (dnsStr == null) {
              break;
            }
            server["address"] = dnsStr;
          }
        }
      }
    }

    /// all dns requests that shall be sent to system dns "localhost",
    /// as determined by v2ray/xray internal dns server $dnsInboundTag
    /// shall be sent there directly
    /// need to reboot core when local dns changes!
    if (!(cfg["dns"] as Map).containsKey("tag")) {
      cfg["dns"]["tag"] = "anyportal_in_dns";
    }
    String dnsInboundTag = cfg["dns"]["tag"];
    if (dns.ipv4.isNotEmpty || dns.ipv6.isNotEmpty) {
      routingRules.insert(0, {
        "type": "field",
        "outboundTag": "anyportal_ot_freedom",
        "inboundTag": [dnsInboundTag],
        "network": "udp",
        "port": 53,
        "ip": [
          ...dns.ipv4,
          ...dns.ipv6,
        ],
      });
    }

    if (injectSendThrough) {
      if (RuntimePlatform.isLinux || RuntimePlatform.isAndroid) {
        /// only linux supports binding to interface
        String? sendThrough;
        String? interfaceName;
        if (injectSendThrough) {
          switch (sendThroughBindingStratagy) {
            case SendThroughBindingStratagy.internet:
              final effectiveNetInterface = await ConnectivityManager()
                  .getEffectiveNetInterface();
              interfaceName = effectiveNetInterface?.name;
            case SendThroughBindingStratagy.ip:
              sendThrough = prefs.getString('inject.sendThrough.bindingIp')!;
            case SendThroughBindingStratagy.interface:
              interfaceName = prefs.getString(
                'inject.sendThrough.bindingInterface',
              )!;
          }
        }

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
            final streamSettings = (outbound["streamSettings"] as Map)
                .cast<String, dynamic>();
            if (!streamSettings.containsKey("sockopt")) {
              (streamSettings as Map).cast<String, dynamic>()["sockopt"] = {};
            }
            final sockopt = (streamSettings["sockopt"] as Map)
                .cast<String, dynamic>();
            sockopt["bindToDevice"] = interfaceName;
            sockopt["interface"] = interfaceName;
          }
        }
      } else {
        /// for other systems fall back to ip binding
        /// this is a bug of v2ray/xray
        String sendThrough = "0.0.0.0";
        if (injectSendThrough) {
          switch (sendThroughBindingStratagy) {
            case SendThroughBindingStratagy.internet:
              final effectiveNetInterface = await ConnectivityManager()
                  .getEffectiveNetInterface();
              final internetIp =
                  effectiveNetInterface?.ip.ipv4.first ??
                  effectiveNetInterface?.ip.ipv6.first;
              if (internetIp != null) {
                sendThrough = internetIp;
              }
            case SendThroughBindingStratagy.ip:
              sendThrough = prefs.getString('inject.sendThrough.bindingIp')!;
            case SendThroughBindingStratagy.interface:
              final bindingInterface = prefs.getString(
                'inject.sendThrough.bindingInterface',
              )!;
              final ip = await getIPv4OfInterfaceName(bindingInterface);
              if (ip == null) {
                withContext((context) {
                  showSnackBarNow(
                    context,
                    Text(
                      context.loc
                          .ip_not_found_for_binding_interface_binding_interface(
                            bindingInterface,
                          ),
                    ),
                  );
                });
                throw Exception(
                  'IP not found for binding interface: $bindingInterface',
                );
              }
              sendThrough = ip;
          }
        }

        for (var outbound in outbounds) {
          outbound["sendThrough"] = sendThrough;
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

  @override
  Future<String> getInjectedConfigPing(
    String cfgStr,
    String coreCfgFmt,
    int socksPort,
  ) async {
    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    if (!cfg.containsKey("inbounds")) {
      cfg["inbounds"] = [];
    }
    final inbounds = (cfg["inbounds"] as List).cast<Map<String, dynamic>>();

    for (final inbound in inbounds) {
      if (inbound.containsKey("port")) {
        inbound["port"] = 0;
      }
    }

    inbounds.insert(0, {
      "listen": "127.0.0.1",
      "port": socksPort,
      "protocol": "socks",
    });

    return jsonEncode(cfg);
  }
}

/// Extracts all server domain names from various outbound protocols
List<String> extractDomains(List<Map<String, dynamic>> outbounds) {
  final domains = <String>{};

  for (final ob in outbounds) {
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
  if (value.contains(':')) return false;
  if (RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(value)) return false;
  return true;
}
