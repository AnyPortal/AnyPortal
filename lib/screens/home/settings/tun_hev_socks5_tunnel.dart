import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/screens/installed_app.dart';
import '../../../utils/global.dart';
import '../../../utils/prefs.dart';
import '../../../utils/vpn_manager.dart';
import '../../../widgets/popup/text_input.dart';

class TunHevSocks5TunnelScreen extends StatefulWidget {
  const TunHevSocks5TunnelScreen({
    super.key,
  });

  @override
  State<TunHevSocks5TunnelScreen> createState() =>
      _TunHevSocks5TunnelScreenState();
}

class _TunHevSocks5TunnelScreenState extends State<TunHevSocks5TunnelScreen> {
  bool _tun = prefs.getBool('tun')!;
  bool _tunUseEmbedded = prefs.getBool('tun.useEmbedded')!;
  bool _perAppProxy = prefs.getBool('tun.perAppProxy')!;
  String _socksUserName = prefs.getString('tun.socks.username')!;
  String _socksPassword = prefs.getString('tun.socks.password')!;
  String _dnsIpv4 = prefs.getString('tun.dns.ipv4')!;
  String _dnsIpv6 = prefs.getString('tun.dns.ipv6')!;
  bool _ipv4 = prefs.getBool('tun.ipv4')!;
  bool _ipv6 = prefs.getBool('tun.ipv6')!;
  bool _perAppProxyAllowed = prefs.getBool('android.tun.perAppProxy.allowed')!;

  @override
  void initState() {
    super.initState();
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
              title: title)),
    );
  }

  void _editAllowedApplications() {
    _editProxyApplist(
        'android.tun.allowedApplications', context.loc.allowed_applications);
  }

  void _editDisallowedApplications() {
    _editProxyApplist(
        'android.tun.disAllowedApplications', context.loc.disallowed_applications);
  }

  void writeTProxyConf() async {
    final folder = global.applicationSupportDirectory;
    final file =
        File(p.join(folder.path, 'conf', 'tun.hev_socks5_tunnel.gen.yaml'));
    final usernameLine =
        _socksUserName == "" ? "" : "username: $_socksUserName";
    final passwordLine =
        _socksPassword == "" ? "" : "password: $_socksPassword";

    final socksPort = prefs.getInt('app.socks.port')!;
    String socksAddress = prefs.getString('app.server.address')!;
    if (socksAddress == "0.0.0.0") {
      socksAddress = "127.0.0.1";
    }

    await file.writeAsString("""tunnel:
  mtu: 8500

socks5:
  port: $socksPort
  address: $socksAddress
  udp: 'udp'
  $usernameLine
  $passwordLine

misc:
  task-stack-size: 81920
""");
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ListTile(
        title: Text(context.loc.enable_tun_via_platform_api_),
        subtitle:
            Text(context.loc.enable_tun2socks_so_a_socks_proxy_works_like_a_vpn),
        trailing: Switch(
          value: _tun && _tunUseEmbedded,
          onChanged: (shouldEnable) {
            prefs.setWithNotification('tun', shouldEnable);
            setState(() {
              _tun = shouldEnable;
              if (shouldEnable) {
                _tunUseEmbedded = true;
                prefs.setBool('tun.useEmbedded', true);
              }
            });
            if (vPNMan.isCoreActive) {
              if (shouldEnable) {
                vPNMan.startTun();
              } else {
                vPNMan.stopTun();
              }
            }
          },
        ),
      ),
      ListTile(
        enabled: _tun,
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
        enabled: _tun && _perAppProxy,
        title: Text(context.loc.per_app_proxy_mode),
        subtitle: Text(_perAppProxyAllowed
            ? context.loc.allowed_all_apps_in_allowed_list_will_be_proxied
            : context.loc.disallowed_all_apps_not_in_disallowed_list_will_be_proxied),
        trailing: Switch(
          value: _perAppProxyAllowed,
          onChanged: _tun && _perAppProxy
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
        enabled: _tun && _perAppProxy && _perAppProxyAllowed,
        title: Text(context.loc.allowed_applications),
        subtitle: Text(context.loc.all_apps_in_allowed_list_will_be_proxied),
        onTap: _editAllowedApplications,
      ),
      ListTile(
        enabled: _tun && _perAppProxy && !_perAppProxyAllowed,
        title: Text(context.loc.disallowed_applications),
        subtitle: Text(context.loc.all_apps_not_in_disallowed_list_will_be_proxied),
        onTap: _editDisallowedApplications,
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
                }),
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
                }),
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
                }),
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
                }),
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
  final folder = global.applicationSupportDirectory;
  final file =
      File(p.join(folder.path, 'conf', 'tun.hev_socks5_tunnel.gen.yaml'));
  if (!file.existsSync()) {
    await file.create(recursive: true);
    _TunHevSocks5TunnelScreenState().writeTProxyConf();
  }
}
