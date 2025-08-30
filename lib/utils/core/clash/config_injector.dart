import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../../models/log_level.dart';
import '../../../models/send_through_binding_stratagy.dart';
import '../../connectivity_manager.dart';
import '../../get_local_ip.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../../yaml_map_converter.dart';
import '../base/config_injector.dart';

class ConfigInjectorClash extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    Map<String, dynamic> cfg = {};
    switch (coreCfgFmt) {
      case "json":
        cfg = jsonDecode(cfgStr) as Map<String, dynamic>;
        break;
      case "yaml":
      case _:
        cfg = (loadYaml(cfgStr) as YamlMap).toMap();
        break;
    }

    final injectLog = prefs.getBool('inject.log')!;
    final injectApi = prefs.getBool('inject.api')!;
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

    if (injectLog) {
      final pathLog = File(
        p.join(global.applicationSupportDirectory.path, 'log', 'core.log'),
      ).absolute.path;
      cfg["log-level"] = logLevel.name;
      cfg["log-file"] = pathLog;
    }

    if (injectApi) {
      cfg["external-controller"] = "$serverAddress:$apiPort";
      // cfg["secret"] ??= "";
    }

    if (injectHttp) {
      cfg["port"] = httpPort;
    }

    if (injectSocks) {
      cfg["mixed-port"] = socksPort;
    }

    if (injectHttp || injectSocks) {
      cfg["allow-lan"] = true;
      cfg["bind-address"] = serverAddress;
    }

    if (!cfg.containsKey("proxies")) {
      cfg["proxies"] = [];
    }
    if (injectSendThrough) {
      String? interfaceName;
      if (injectSendThrough) {
        switch (sendThroughBindingStratagy) {
          case SendThroughBindingStratagy.internet:
            final effectiveNetInterface = await ConnectivityManager()
                .getEffectiveNetInterface();
            interfaceName = effectiveNetInterface?.name;
          case SendThroughBindingStratagy.ip:
            final ip = prefs.getString('inject.sendThrough.bindingIp')!;
            interfaceName = await getInterfaceNameOfIP(ip);
          case SendThroughBindingStratagy.interface:
            interfaceName = prefs.getString(
              'inject.sendThrough.bindingInterface',
            )!;
        }
      }
      for (var outbound in cfg["proxies"]) {
        outbound["interface-name"] = interfaceName;
      }
    }

    switch (coreCfgFmt) {
      case "json":
        return jsonEncode(cfg);
      case "yaml":
      case _:
        return YamlWriter().write(cfg);
    }
  }

  @override
  Future<String> getInjectedConfigPing(
    String cfgStr,
    String coreCfgFmt,
    int socksPort,
  ) async {
    Map<String, dynamic> cfg = {};
    switch (coreCfgFmt) {
      case "json":
        cfg = jsonDecode(cfgStr) as Map<String, dynamic>;
        break;
      case "yaml":
      case _:
        cfg = (loadYaml(cfgStr) as YamlMap).toMap();
        break;
    }

    cfg["listeners"] = [];
    cfg["mixed-port"] = socksPort;
    if (cfg.containsKey("port")) {
      cfg.remove("port");
    }
    if (cfg.containsKey("socks-port")) {
      cfg.remove("socks-port");
    }
    if (cfg.containsKey("redir-port")) {
      cfg.remove("redir-port");
    }
    if (cfg.containsKey("tproxy-port")) {
      cfg.remove("tproxy-port");
    }
    cfg["listeners"] = [];
    if (cfg.containsKey("dns")) {
      final dns = cfg["dns"] as Map;
      if (dns.containsKey("listen")) {
        dns.remove("listen");
      }
    }

    if (cfg.containsKey("external-controller")) {
      cfg.remove("external-controller");
    }

    switch (coreCfgFmt) {
      case "json":
        return jsonEncode(cfg);
      case "yaml":
      case _:
        return YamlWriter().write(cfg);
    }
  }
}
