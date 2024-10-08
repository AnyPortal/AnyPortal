import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/prefs.dart';
import '../../../utils/tray_menu.dart';
import '../../../utils/vpn_manager.dart';

class SystemProxyScreen extends StatefulWidget {
  const SystemProxyScreen({
    super.key,
  });

  @override
  State<SystemProxyScreen> createState() => _SystemProxyScreenState();
}

class _SystemProxyScreenState extends State<SystemProxyScreen> {
  bool _systemProxy = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    setState(() {
      _systemProxy = prefs.getBool('systemProxy')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ListTile(
        title: const Text("Enable system proxy"),
        subtitle: Text("Provided by ${Platform.operatingSystem}, not all apps respect this setting"),
        trailing: Switch(
          value: _systemProxy,
          onChanged: (bool shouldEnable) {
            setState(() {
              _systemProxy = shouldEnable;
            });
            prefs.setBool('systemProxy', shouldEnable).then((_){
              trayMenu.updateContextMenu();
            });
            vPNMan.getIsCoreActive().then((isCoreActive) {
              if (isCoreActive) {
                if (shouldEnable) {
                  vPNMan.startSystemProxy();
                } else {
                  vPNMan.stopSystemProxy();
                }
              }
            });
          },
        ),
      ),
    ];
    return Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: const Text("SystemProxy"),
                  ),
        body: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) => fields[index],
        ));
  }
}
