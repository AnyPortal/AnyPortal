import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart' as p;

import '../../../extensions/localization.dart';
import '../../../models/log_level.dart';
import '../../../utils/global.dart';
import '../../../utils/logger.dart';
import '../../../utils/platform_file_mananger.dart';
import '../../../utils/prefs.dart';
import '../../../utils/runtime_platform.dart';
import '../../../utils/show_snack_bar_now.dart';
import '../../../utils/vpn_manager.dart';
import '../../../widgets/popup/radio_list_selection.dart';
import '../../../widgets/popup/text_input.dart';
import '../../installed_app.dart';

class TunScreen extends StatefulWidget {
  const TunScreen({
    super.key,
  });

  @override
  State<TunScreen> createState() => _TunScreenState();
}

enum TunVia {
  root,
  platform,
}

class _TunScreenState extends State<TunScreen> {
  bool _tun = prefs.getBool('tun')!;
  TunVia _tunVia = prefs.getBool('tun.useEmbedded')!
      ? TunVia.platform
      : TunVia.root;

  /// android
  bool _perAppProxy = prefs.getBool('tun.perAppProxy')!;
  bool _perAppProxyAllowed = prefs.getBool('android.tun.perAppProxy.allowed')!;

  /// hev_socks5_tunnel
  String _socksUserName = prefs.getString('tun.socks.username')!;
  String _socksPassword = prefs.getString('tun.socks.password')!;
  String _dnsIpv4 = prefs.getString('tun.dns.ipv4')!;
  String _dnsIpv6 = prefs.getString('tun.dns.ipv6')!;
  bool _ipv4 = prefs.getBool('tun.ipv4')!;
  bool _ipv6 = prefs.getBool('tun.ipv6')!;

  /// sing-box
  File tunSingBoxUserConfigFile = File("");
  bool _injectLog = prefs.getBool('tun.inject.log')!;
  LogLevel _logLevel = LogLevel.values[prefs.getInt('tun.inject.log.level')!];
  bool _injectSocks = prefs.getBool('tun.inject.socks')!;
  bool _injectExcludeCorePath = prefs.getBool('tun.inject.excludeCorePath')!;

  @override
  void initState() {
    super.initState();
    vPNMan.getTunSingBoxUserConfigFile().then((value) {
      setState(() {
        tunSingBoxUserConfigFile = value;
      });
    });
  }

  void _editProxyApplist(String prefKey, String title) {
    final selectedAppString = prefs.getString(prefKey) ?? "[]";
    final selectedAppStringDecoded = jsonDecode(selectedAppString);
    final selectedApps = List<String>.from(selectedAppStringDecoded).toSet();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstalledAppScreen(
          selectedApps: selectedApps,
          handleSelectedApps: (Set<String> selectedApps) {
            prefs.setString(prefKey, jsonEncode(selectedApps.toList()));
          },
          title: title,
        ),
      ),
    );
  }

  void _editAllowedApplications() {
    _editProxyApplist(
      'android.tun.allowedApplications',
      context.loc.allowed_applications,
    );
  }

  void _editDisallowedApplications() {
    _editProxyApplist(
      'android.tun.disAllowedApplications',
      context.loc.disallowed_applications,
    );
  }

  void writeTProxyConf() async {
    if (RuntimePlatform.isWeb) return;
    final folder = global.applicationSupportDirectory;
    final file = File(
      p.join(folder.path, 'conf', 'tun2socks.hev_socks5_tunnel.gen.yaml'),
    );
    final usernameLine = _socksUserName == ""
        ? ""
        : "username: $_socksUserName";
    final passwordLine = _socksPassword == ""
        ? ""
        : "password: $_socksPassword";

    final socksPort = prefs.getInt('app.socks.port')!;
    String socksAddress = prefs.getString('app.server.address')!;
    if (socksAddress == "0.0.0.0") {
      socksAddress = "127.0.0.1";
    }

    final logFile = File(
      p.join(folder.path, 'log', 'tun2socks.hev_socks5_tunnel.log'),
    );
    String logFileLine = "log-file: ${logFile.path}";
    final logLevel = LogLevel.values[prefs.getInt('tun.inject.log.level')!];
    String logLevelStr = "warn";
    switch (logLevel) {
      case LogLevel.debug:
      case LogLevel.info:
      case LogLevel.error:
        logLevelStr = logLevel.toString();
      case LogLevel.warning:
      case LogLevel.none:
        logLevelStr = "warn";
        logFileLine = "";
    }

    await file.writeAsString("""tunnel:
  mtu: 8500
  # multi-queue: true
  
socks5:
  port: $socksPort
  address: $socksAddress
  udp: 'udp'
  $usernameLine
  $passwordLine

misc:
  task-stack-size: 81920
  $logFileLine
  log-level: $logLevelStr
""");
  }

  void handleError(Object e) {
    logger.e("tun: $e");
    if (mounted) showSnackBarNow(context, Text("tun: $e"));
  }

  Future<void> copyTextThenNotify(String text) async {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) showSnackBarNow(context, Text(context.loc.copied));
    });
  }

  @override
  Widget build(BuildContext context) {
    String injectSocksAddress = prefs.getString('app.server.address')!;
    if (injectSocksAddress == "0.0.0.0") {
      injectSocksAddress = "127.0.0.1";
    }

    final androidFields = [
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.per_app_proxy,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.per_app_proxy),
        subtitle: Text(context.loc.all_apps_are_proxied_if_disabled),
        trailing: Switch(
          value: _perAppProxy,
          onChanged: (value) {
            prefs.setBool('tun.perAppProxy', value);
            setState(() {
              _perAppProxy = value;
            });
          },
        ),
      ),
      ListTile(
        enabled: _perAppProxy,
        title: Text(context.loc.per_app_proxy_mode),
        subtitle: Text(
          _perAppProxyAllowed
              ? context.loc.allowed_all_apps_in_allowed_list_will_be_proxied
              : context
                    .loc
                    .disallowed_all_apps_not_in_disallowed_list_will_be_proxied,
        ),
        trailing: Switch(
          value: _perAppProxyAllowed,
          onChanged: _perAppProxy
              ? (value) {
                  prefs.setBool('android.tun.perAppProxy.allowed', value);
                  setState(() {
                    _perAppProxyAllowed = value;
                  });
                }
              : null,
        ),
      ),
      ListTile(
        enabled: _perAppProxy && _perAppProxyAllowed,
        title: Text(context.loc.allowed_applications),
        subtitle: Text(context.loc.all_apps_in_allowed_list_will_be_proxied),
        onTap: _editAllowedApplications,
      ),
      ListTile(
        enabled: _perAppProxy && !_perAppProxyAllowed,
        title: Text(context.loc.disallowed_applications),
        subtitle: Text(
          context.loc.all_apps_not_in_disallowed_list_will_be_proxied,
        ),
        onTap: _editDisallowedApplications,
      ),
    ];

    final tunHevSocks5TunnelFields = [
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.advanced,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.socks_user_name),
        subtitle: Text(_socksUserName),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
              title: context.loc.socks_user_name,
              initialValue: _socksUserName,
              onSaved: (value) {
                prefs.setString('tun.socks.username', value);
                setState(() {
                  _socksUserName = value;
                });
              },
            ),
          );
        },
      ),
      ListTile(
        title: Text(context.loc.socks_password),
        subtitle: Text(_socksPassword),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
              title: context.loc.socks_password,
              initialValue: _socksPassword,
              onSaved: (value) {
                prefs.setString('tun.socks.password', value);
                setState(() {
                  _socksPassword = value;
                });
              },
            ),
          );
        },
      ),
      ListTile(
        title: Text(context.loc.dns_ipv4),
        subtitle: Text(_dnsIpv4),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
              title: context.loc.dns_ipv4,
              initialValue: _dnsIpv4,
              onSaved: (value) {
                prefs.setString('tun.dns.ipv4', value);
                setState(() {
                  _dnsIpv4 = value;
                });
              },
            ),
          );
        },
      ),
      ListTile(
        title: Text(context.loc.dns_ipv6),
        subtitle: Text(_dnsIpv6),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
              title: context.loc.dns_ipv6,
              initialValue: _dnsIpv6,
              onSaved: (value) {
                prefs.setString('tun.dns.ipv6', value);
                setState(() {
                  _dnsIpv6 = value;
                });
              },
            ),
          );
        },
      ),
    ];

    final tunSingBoxFields = [
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.outbound_config_additional_socks_outbound,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_socks_outbound),
        subtitle: Text(
          "$injectSocksAddress:${prefs.getInt('app.socks.port')!}",
        ),
        trailing: Switch(
          value: _injectSocks,
          onChanged: (value) {
            prefs.setBool('tun.inject.socks', value);
            setState(() {
              _injectSocks = value;
            });
          },
        ),
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.routing_rule_additional_rules,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_rule_to_exclude_core_path),
        subtitle: Text(
          context
              .loc
              .works_fine_on_windows_will_fail_on_other_systems_with_short_lived_packets_like_dns_,
        ),
        trailing: Switch(
          value: _injectExcludeCorePath,
          onChanged: (value) {
            prefs.setBool('tun.inject.excludeCorePath', value);
            setState(() {
              _injectExcludeCorePath = value;
            });
          },
        ),
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.advanced,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.edit_config),
        subtitle: Text(tunSingBoxUserConfigFile.path),
        trailing: Icon(
          RuntimePlatform.isAndroid ? Icons.copy : Icons.folder_open,
        ),
        onTap: () {
          final filePath = tunSingBoxUserConfigFile.path;
          if (RuntimePlatform.isAndroid) {
            copyTextThenNotify(filePath);
          } else {
            PlatformFileMananger.highlightFileInFolder(filePath);
          }
        },
      ),
    ];

    final fields = [
      ListTile(
        title: Text(context.loc.enable_tun2socks),
        subtitle: Text(
          context.loc.enable_tun2socks_so_a_socks_proxy_works_like_a_vpn,
        ),
        trailing: Switch(
          value: _tun,
          onChanged: (shouldEnable) {
            prefs.setBool('tun', shouldEnable);
            prefs.notifyListeners();
            setState(() {
              _tun = shouldEnable;
            });
            if (vPNMan.isCoreActive) {
              if (shouldEnable) {
                vPNMan.startTun().catchError(handleError);
              } else {
                vPNMan.stopTun().catchError(handleError);
              }
            }
          },
        ),
      ),
      if (RuntimePlatform.isAndroid && global.isElevated)
        ListTile(
          title: Text(context.loc.tun_stack),
          subtitle: Text(_tunVia.name),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => RadioListSelectionPopup<TunVia>(
                title: context.loc.tun_stack,
                items: [
                  if (RuntimePlatform.isAndroid || RuntimePlatform.isIOS)
                    TunVia.platform,
                  if (RuntimePlatform.isWindows ||
                      RuntimePlatform.isLinux ||
                      RuntimePlatform.isMacOS ||
                      RuntimePlatform.isAndroid)
                    TunVia.root,
                ],
                initialValue: _tunVia,
                onSaved: (value) {
                  prefs.setBool('tun.useEmbedded', value == TunVia.platform);
                  setState(() {
                    _tunVia = value;
                  });
                },
                itemToString: (e) => e.name,
              ),
            );
          },
        ),
      ListTile(
        title: Text(context.loc.ipv4),
        subtitle: Text(context.loc.enable_ipv4),
        trailing: Switch(
          value: _ipv4,
          onChanged: (value) {
            prefs.setBool('tun.ipv4', value);
            setState(() {
              _ipv4 = value;
            });
          },
        ),
      ),
      ListTile(
        title: Text(context.loc.ipv6),
        subtitle: Text(context.loc.enable_ipv6),
        trailing: Switch(
          value: _ipv6,
          onChanged: (value) {
            prefs.setBool('tun.ipv6', value);
            setState(() {
              _ipv6 = value;
            });
          },
        ),
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.log_config_override,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_log),
        subtitle: Text(context.loc.override_log_config),
        trailing: Switch(
          value: _injectLog,
          onChanged: (bool value) {
            prefs.setBool('tun.inject.log', value);
            setState(() {
              _injectLog = value;
            });
          },
        ),
      ),
      ListTile(
        enabled: _injectLog,
        title: Text(context.loc.log_level),
        subtitle: Text(_logLevel.name),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => RadioListSelectionPopup<LogLevel>(
              title: context.loc.log_level,
              items: LogLevel.values,
              initialValue: _logLevel,
              onSaved: (value) {
                prefs.setInt('tun.inject.log.level', value.index);
                setState(() {
                  _logLevel = value;
                });
              },
              itemToString: (e) => e.name,
            ),
          );
        },
      ),
      if (RuntimePlatform.isAndroid) ...androidFields,
      if (_tunVia == TunVia.platform) ...tunHevSocks5TunnelFields,
      if (_tunVia == TunVia.root) ...tunSingBoxFields,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        writeTProxyConf();
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: Text(context.loc.tun2socks_settings),
        ),
        body: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) => fields[index],
          // separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }
}

Future<void> tunHevSocks5TunnelConfInit() async {
  final folder = global.applicationSupportDirectory;
  final file = File(
    p.join(folder.path, 'conf', 'tun2socks.hev_socks5_tunnel.gen.yaml'),
  );
  if (!await file.exists()) {
    await file.create(recursive: true);
    _TunScreenState().writeTProxyConf();
  }
}
