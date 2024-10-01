import 'package:flutter/material.dart';
import 'package:fv2ray/widgets/installed_app_list.dart';

class InstalledAppScreen extends StatefulWidget {
  const InstalledAppScreen({
    super.key,
  });

  @override
  State<InstalledAppScreen> createState() => _InstalledAppScreenState();
}

class _InstalledAppScreenState extends State<InstalledAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Installed apps"),
              ),
      body: const InstalledAppList(),
    );
  }
}
