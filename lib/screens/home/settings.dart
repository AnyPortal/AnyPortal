import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fv2ray/screens/home/settings/tun.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'settings/about.dart';
import 'settings/core.dart';
import 'settings/profile_override.dart';

class SettingList extends StatefulWidget {
  const SettingList({
    super.key,
  });

  @override
  State<SettingList> createState() => _SettingListState();
}

class _SettingListState extends State<SettingList> {
  bool _launchAtStartup = false;

  @override
  @override
  void initState() {
    super.initState();
    _loadLaunchAtStartup();
  }

  _loadLaunchAtStartup() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      launchAtStartup.isEnabled().then((value) {
        setState(() {
          _launchAtStartup = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(children: [
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ListTile(
              title: const Text("Auto start"),
              subtitle: const Text("Launch at startup"),
              trailing: Switch(
                value: _launchAtStartup,
                onChanged: (value) async {
                  if (value) {
                    await launchAtStartup.enable();
                  } else {
                    await launchAtStartup.disable();
                  }
                  _loadLaunchAtStartup();
                },
              ),
            ),
          ListTile(
            title: const Text("Core"),
            subtitle: const Text("Path of core exectuable, assets, etc."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoreScreen()),
              );
            },
          ),
          ListTile(
            title: const Text("Profile override"),
            subtitle: const Text("Inject configuration into v2ray profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileOverrideScreen()),
              );
            },
          ),
          if (Platform.isAndroid || Platform.isIOS)
            ListTile(
                title: const Text("Tun"),
                subtitle: const Text("Tun adaptor"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TunScreen()),
                  );
                }),
          ListTile(
            title: const Text("About"),
            subtitle: const Text("fv2ray"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ]),
      ),
    );
  }
}
