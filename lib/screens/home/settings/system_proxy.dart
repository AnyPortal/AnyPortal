import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/platform_system_proxy_user.dart';
import '../../../utils/vpn_manager.dart';

class SystemProxyScreen extends StatefulWidget {
  const SystemProxyScreen({
    super.key,
  });

  @override
  State<SystemProxyScreen> createState() => _SystemProxyScreenState();
}

class _SystemProxyScreenState extends State<SystemProxyScreen> {
  bool? _systemProxy = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    _systemProxy = await platformSystemProxyUser.isEnabled();
    setState(() {
      _systemProxy = _systemProxy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ListTile(
        enabled: _systemProxy != null,
        title: const Text("Enable system proxy"),
        subtitle: Text(
            "Provided by ${Platform.operatingSystem}, not all apps respect this setting"),
        trailing: Switch(
          value: _systemProxy == null ? false : _systemProxy!,
          onChanged: (bool shouldEnable) {
            setState(() {
              _systemProxy = shouldEnable;
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
