import 'dart:io';

import 'package:flutter/material.dart';
import 'package:anyportal/screens/home/settings/tun_hev_socks5_tunnel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings/about.dart';
import 'settings/assets.dart';
import 'settings/cores.dart';
import 'settings/general.dart';
import 'settings/profile_override.dart';
import 'settings/system_proxy.dart';
import 'settings/tun_sing_box.dart';

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
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "Assets",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
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
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "Profile",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
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
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "Connection",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          if (Platform.isAndroid || Platform.isIOS)
            ListTile(
                title: const Text("Tun"),
                subtitle: const Text("Vitual network adaptor to direct all traffic"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TunHevSocks5TunnelScreen()),
                  );
                }),
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ListTile(
                title: const Text("Tun"),
                subtitle: const Text("Vitual network adaptor to direct all traffic"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TunSingBoxScreen()),
                  );
                }),
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            ListTile(
                title: const Text("System proxy"),
                subtitle: Text("Provided by ${Platform.operatingSystem}, not all apps respect this setting"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SystemProxyScreen()),
                  );
                }),
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "About",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ListTile(
            title: const Text("About"),
            subtitle: const Text("AnyPortal"),
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
