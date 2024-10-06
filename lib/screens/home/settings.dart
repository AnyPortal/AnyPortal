import 'dart:io';

import 'package:flutter/material.dart';
import 'package:anyportal/screens/home/settings/tun.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings/about.dart';
import 'settings/assets.dart';
import 'settings/cores.dart';
import 'settings/general.dart';
import 'settings/profile_override.dart';

class SettingList extends StatefulWidget {
  const SettingList({
    super.key,
  });

  @override
  State<SettingList> createState() => _SettingListState();
}

class _SettingListState extends State<SettingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
              ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(children: [
          ListTile(
            title: const Text("General"),
            subtitle: const Text("Auto startup, tray icon, etc."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GeneralScreen()),
              );
            },
          ),
          ListTile(
            title: const Text("Cores"),
            subtitle: const Text("Path of core exectuable, assets, etc."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoresScreen()),
              );
            },
          ),
          ListTile(
            title: const Text("Assets"),
            subtitle: const Text("Assets remote auto update, etc."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssetsScreen()),
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
            subtitle: const Text("anyportal"),
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
