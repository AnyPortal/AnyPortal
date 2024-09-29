import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../../utils/prefs.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({
    super.key,
  });

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  bool _launchAtStartup = false;
  bool _connectAtLaunch = prefs.getBool('app.connectAtLaunch')!;

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
    final fields = [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Launch settings",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
        ListTile(
          title: const Text("Auto launch"),
          subtitle: const Text("Auto launch at login"),
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
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Core settings"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
        // separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
