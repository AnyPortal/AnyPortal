import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/global.dart';
import '../../../utils/platform_launch_at_login.dart';
import '../../../utils/prefs.dart';
import '../../../utils/theme_manager.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({
    super.key,
  });

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  bool _launchAtLogin = false;
  bool _connectAtLaunch = prefs.getBool('app.connectAtLaunch')!;
  bool _runElevated = prefs.getBool('app.runElevated')!;
  final String _elevatedUser = Platform.isWindows ? "Administrator" : "root";
  bool _brightnessIsDark = prefs.getBool('app.brightness.dark')!;
  bool _brightnessFollowSystem = prefs.getBool('app.brightness.followSystem')!;
  bool _skipTaskbar = prefs.getBool('app.window.skipTaskbar')!;

  @override
  void initState() {
    super.initState();
    _loadLaunchAtLogin();
  }

  _loadLaunchAtLogin() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      platformLaunchAtLogin.isEnabled().then((value) {
        setState(() {
          _launchAtLogin = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Launch settings",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      if (Platform.isWindows ||
          (!global.isElevated && (Platform.isLinux || Platform.isMacOS)))
        ListTile(
          title: const Text("Auto launch"),
          subtitle: Text(
              "Auto launch at login, ${_runElevated ? 'with' : 'without'} privilege"),
          trailing: Switch(
            value: _launchAtLogin,
            onChanged: (value) async {
              bool ok = false;
              if (value) {
                ok = await platformLaunchAtLogin.enable(
                    isElevated: _runElevated);
              } else {
                ok = await platformLaunchAtLogin.disable();
              }
              if (ok) {
                setState(() {
                  _launchAtLogin = value;
                });
              } else {
                final snackBar = SnackBar(
                  content: Text(
                      "Failed. If you enabled auto launch as $_elevatedUser, you need to be $_elevatedUser to disable it."),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
          ),
        ),
      if (Platform.isWindows)
        ListTile(
          enabled: global.isElevated,
          title: Text("Run as $_elevatedUser"),
          subtitle: const Text("Typically required by Tun"),
          trailing: Switch(
            value: _runElevated,
            onChanged: (value) async {
              if (!global.isElevated) {
                final snackBar = SnackBar(
                  content: Text(
                      "You need to be $_elevatedUser to modify this setting"),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                return;
              }
              if (_launchAtLogin) {
                bool ok = false;
                await platformLaunchAtLogin.disable();
                ok = await platformLaunchAtLogin.enable(isElevated: value);
                if (!ok) {
                  const snackBar = SnackBar(
                    content:
                        Text("Failed due to unable to update launchAtLogin"),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  return;
                }
              }
              prefs.setBool('app.runElevated', value);
              setState(() {
                _runElevated = value;
              });
            },
          ),
        ),
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
        ListTile(
          title: const Text("Minimize to tray"),
          subtitle: const Text("Hide taskbar icon when minimized"),
          trailing: Switch(
            value: _skipTaskbar,
            onChanged: (value) async {
              prefs.setBool('app.window.skipTaskbar', value);
              setState(() {
                _skipTaskbar = value;
              });
            },
          ),
        ),
      ListTile(
        title: const Text("Auto connect"),
        subtitle: const Text("Auto connect selected profile at app launch"),
        trailing: Switch(
          value: _connectAtLaunch,
          onChanged: (value) async {
            prefs.setBool('app.connectAtLaunch', value);
            setState(() {
              _connectAtLaunch = value;
            });
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Theme settings",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text("Follow system brightness"),
        subtitle: const Text("Auto change brightness"),
        trailing: Switch(
          value: _brightnessFollowSystem,
          onChanged: (value) async {
            prefs.setBool('app.brightness.followSystem', value);
            setState(() {
              _brightnessFollowSystem = value;
            });
            themeManager.updateBrightness(notify: true);
          },
        ),
      ),
      ListTile(
        enabled: _brightnessFollowSystem == false,
        title: const Text("Dark theme"),
        subtitle: const Text("Use dark theme"),
        trailing: Switch(
          value: _brightnessIsDark,
          onChanged: _brightnessFollowSystem == true
              ? null
              : (value) async {
                  prefs.setBool('app.brightness.dark', value);
                  setState(() {
                    _brightnessIsDark = value;
                  });
                  themeManager.updateBrightness(notify: true);
                },
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("General settings"),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
        // separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
