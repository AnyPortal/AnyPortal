import 'package:flutter/material.dart';
import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/widgets/installed_app_list.dart';

class InstalledAppScreen extends StatefulWidget {
  late final Set<String> selectedApps;
  final void Function(Set<String>)? handleSelectedApps;
  late final String title;

  InstalledAppScreen({
    super.key,
    selectedApps,
    this.handleSelectedApps,
    title,
  }){
    this.selectedApps = selectedApps ?? {};
    this.title = title ?? "Installed apps";
  }

  @override
  State<InstalledAppScreen> createState() => _InstalledAppScreenState();
}

class _InstalledAppScreenState extends State<InstalledAppScreen> {
  @override
  Widget build(BuildContext context) {
    widget.title = context.loc.installed_apps;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (widget.handleSelectedApps != null) {
          widget.handleSelectedApps!(widget.selectedApps);
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: Text(widget.title),
        ),
        body: InstalledAppList(selectedApps: widget.selectedApps),
      ),
    );
  }
}
