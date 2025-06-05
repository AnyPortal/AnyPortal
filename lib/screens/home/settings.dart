import 'package:flutter/material.dart';

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/screens/home/settings/tun_hev_socks5_tunnel.dart';
import 'settings/about.dart';
import 'settings/assets.dart';
import 'settings/connectivity_basic.dart';
import 'settings/cores.dart';
import 'settings/general.dart';
import 'settings/profile_override.dart';
import 'settings/system_proxy.dart';
import 'settings/tun_sing_box.dart';
import '../../utils/platform.dart';

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
        title: Text(context.loc.settings),
              ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(children: [
          ListTile(
            title: Text(context.loc.general),
            subtitle: Text(context.loc.auto_startup_tray_icon_etc_),
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
              context.loc.connectivity,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ListTile(
              title: Text(context.loc.socks_and_http),
              subtitle: Text(context.loc.either_to_match_predefined_profile_or_for_profile_injection),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConnectivityBasicScreen()),
                );
              }),
          if (platform.isWindows || platform.isLinux || platform.isMacOS || platform.isAndroid)
            ListTile(
                title: Text(context.loc.system_proxy),
                subtitle: Text(context.loc.provided_by_os_not_all_apps_respect_this_setting),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SystemProxyScreen()),
                  );
                }),
          if (platform.isAndroid || platform.isIOS)
            ListTile(
                title: Text(context.loc.tun_via_platform_api_),
                subtitle: Text(context.loc.vitual_network_adaptor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TunHevSocks5TunnelScreen()),
                  );
                }),
          if (platform.isWindows || platform.isLinux || platform.isMacOS || platform.isAndroid)
            ListTile(
                title: Text(context.loc.tun_via_root_),
                subtitle: Text(context.loc.vitual_network_adaptor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TunSingBoxScreen()),
                  );
                }),
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              context.loc.assets,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ListTile(
            title: Text(context.loc.cores),
            subtitle: Text(context.loc.path_of_core_exectuable_assets_etc_),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoresScreen()),
              );
            },
          ),
          ListTile(
            title: Text(context.loc.assets),
            subtitle: Text(context.loc.assets_remote_auto_update_etc_),
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
              context.loc.profile,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ListTile(
            title: Text(context.loc.profile_override),
            subtitle: Text(context.loc.inject_configuration_into_v2ray_xray_profile),
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
              context.loc.about,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ListTile(
            title: Text(context.loc.about),
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
