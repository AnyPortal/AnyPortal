import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart' as p;

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/models/log_level.dart';
import '../../../utils/global.dart';
import '../../../utils/logger.dart';
import '../../../utils/platform.dart';
import '../../../utils/platform_file_mananger.dart';
import '../../../utils/prefs.dart';
import '../../../utils/vpn_manager.dart';
import '../../../widgets/popup/radio_list_selection.dart';

class TunSingBoxScreen extends StatefulWidget {
  const TunSingBoxScreen({
    super.key,
  });

  @override
  State<TunSingBoxScreen> createState() => _TunSingBoxScreenState();
}

class _TunSingBoxScreenState extends State<TunSingBoxScreen> {
  bool _tun = prefs.getBool('tun')!;
  bool _tunUseEmbedded = prefs.getBool('tun.useEmbedded')!;
  bool _injectLog = prefs.getBool('tun.inject.log')!;
  LogLevel _logLevel = LogLevel.values[prefs.getInt('tun.inject.log.level')!];
  bool _injectSocks = prefs.getBool('tun.inject.socks')!;
  bool _injectExcludeCorePath = prefs.getBool('tun.inject.excludeCorePath')!;

  @override
  void initState() {
    super.initState();
  }

  void writeTProxyConf() async {}
  File tunSingBoxUserConfigFile = vPNMan.getTunSingBoxUserConfigFile();

  void handleError(Object e) {
    logger.e("tun: $e");
    final snackBar = SnackBar(
      content: Text("$e"),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> copyTextThenNotify(String text) async {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      final snackBar = SnackBar(
        content: Text("Copied"),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    String injectSocksAddress = prefs.getString('app.server.address')!;
    if (injectSocksAddress == "0.0.0.0") {
      injectSocksAddress = "127.0.0.1";
    }
    final fields = [
      ListTile(
        enabled: global.isElevated,
        title: Text(context.loc.enable_tun_via_root_),
        subtitle: Text(context.loc
            .enable_tun2socks_so_a_socks_proxy_works_like_a_vpn_requires_elevation_),
        trailing: Switch(
          value: _tun && !_tunUseEmbedded,
          onChanged: (shouldEnable) {
            if (!global.isElevated) {
              final snackBar = SnackBar(
                content: Text(context.loc
                    .warning_you_need_to_be_elevated_user_to_modify_this_setting(
                        platform.isWindows
                            ? context.loc.administrator
                            : "root")),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              return;
            }
            setState(() {
              _tun = shouldEnable;
              if (shouldEnable) {
                _tunUseEmbedded = false;
                prefs.setBool('tun.useEmbedded', false);
              }
            });
            prefs.setWithNotification('tun', shouldEnable);
            vPNMan.getIsCoreActive().then((isCoreActive) {
              if (isCoreActive) {
                if (isCoreActive) {
                  if (shouldEnable) {
                    vPNMan.startTun().catchError(handleError);
                  } else {
                    vPNMan.stopTun().catchError(handleError);
                  }
                }
              }
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
                  ));
        },
      ),
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
        subtitle:
            Text("$injectSocksAddress:${prefs.getInt('app.socks.port')!}"),
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
          context.loc.routing_rule_additionally_exclude_core_path,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_rule_to_exclude_core_path),
        subtitle: Text(context.loc
            .disable_to_improve_performance_make_sure_you_have_bound_core_to_a_correct_interface),
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
        trailing: const Icon(Icons.folder_open),
        onTap: () {
          PlatformFileMananger.highlightFileInFolder(
              tunSingBoxUserConfigFile.path);
          copyTextThenNotify(tunSingBoxUserConfigFile.path);
        },
      ),
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
          title: Text(context.loc.tun_settings),
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

Future<void> tProxyConfInit() async {
  final file = File(p.join(
    global.applicationSupportDirectory.path,
    'conf',
    'tun.sing_box.gen.json',
  ));
  if (!await file.exists()) {
    await file.create(recursive: true);
    _TunSingBoxScreenState().writeTProxyConf();
  }
}
