import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fv2ray/screens/installed_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../widgets/popup/text_input.dart';
import '../../../utils/prefs.dart';

class TunScreen extends StatefulWidget {
  const TunScreen({
    super.key,
  });

  @override
  State<TunScreen> createState() => _TunScreenState();
}

class _TunScreenState extends State<TunScreen> {
  bool _perAppProxy = prefs.getBool('tun.perAppProxy')!;
  String _socksAddress = prefs.getString('tun.socks.address')!;
  int _socksPort = prefs.getInt('tun.socks.port')!;
  String _socksUserName = prefs.getString('tun.socks.username')!;
  String _socksPassword = prefs.getString('tun.socks.password')!;
  String _dnsIpv4 = prefs.getString('tun.dns.ipv4')!;
  String _dnsIpv6 = prefs.getString('tun.dns.ipv6')!;
  bool _ipv4 = prefs.getBool('tun.ipv4')!;
  bool _ipv6 = prefs.getBool('tun.ipv6')!;

  @override
  void initState() {
    super.initState();
  }

  void _updatePerAppProxy(bool value) {
    prefs.setBool('tun.perAppProxy', value);
    setState(() {
      _perAppProxy = value;
    });
  }

  void _editApplist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InstalledAppScreen()),
    );
  }

  void writeTProxyConf() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'fv2ray', 'tproxy.yaml'));
    final usernameLine =
        _socksUserName == "" ? "" : "username: $_socksUserName";
    final passwordLine =
        _socksPassword == "" ? "" : "password: $_socksPassword";
        
    if(!file.existsSync()){
      file.create();
    }

    await file.writeAsString("""tunnel:
  mtu: 8500

socks5:
  port: $_socksPort
  address: $_socksAddress
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
        title: Text("Per-app proxy",
            style: Theme.of(context).textTheme.headlineSmall),
        trailing: Switch(
          value: _perAppProxy,
          onChanged: _updatePerAppProxy,
        ),
      ),
      ListTile(
        title: const Text("White list"),
        subtitle: const Text("Only apps in white list will be proxied"),
        onTap: _editApplist,
        enabled: _perAppProxy,
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Advanced",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text('Socks address'),
        subtitle: Text(_socksAddress),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Socks address',
                initialValue: _socksAddress,
                onSaved: (value) {
                  prefs.setString('tun.socks.address', value);
                  setState(() {
                    _socksAddress = value;
                  });
                }),
          );
        },
      ),
      ListTile(
        title: const Text('Socks port'),
        subtitle: Text("$_socksPort"),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Socks Port',
                initialValue: "$_socksPort",
                onSaved: (value) {
                  prefs.setInt('tun.socks.port', int.parse(value));
                  setState(() {
                    _socksPort = int.parse(value);
                  });
                }),
          );
        },
      ),
      ListTile(
        title: const Text('Socks user name'),
        subtitle: Text(_socksUserName),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Socks user name',
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
        title: const Text('Socks password'),
        subtitle: Text(_socksPassword),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Socks password',
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
        title: const Text('DNS IPv4'),
        subtitle: Text(_dnsIpv4),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'DNS IPv4',
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
        title: const Text('DNS IPv6'),
        subtitle: Text(_dnsIpv6),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'DNS IPv6',
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
        title: const Text("IPv4"),
        subtitle: const Text("enable IPv4"),
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
        title: const Text("IPv6"),
        subtitle: const Text("enable IPv6"),
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
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: const Text("Tun settings"),
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

tProxyConfInit() async {
  final folder = await getApplicationDocumentsDirectory();
  final file = File(p.join(folder.path, 'fv2ray', 'tproxy.yaml'));
  if (!file.existsSync()){
    _TunScreenState().writeTProxyConf();
  }
}