import 'package:flutter/material.dart';

import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppList extends StatefulWidget {
  final Set<String> selectedApps;

  const InstalledAppList({
    super.key,
    required this.selectedApps,
  });
  @override
  State<InstalledAppList> createState() => _InstalledAppListState();
}

class _InstalledAppListState extends State<InstalledAppList> {
  @override
  void initState() {
    super.initState();
    _listInstalledApps();
  }

  bool _allAppsLoaded = false;
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];

  String _query = "";

  Future<void> _listInstalledApps() async {
    _allApps = await InstalledApps.getInstalledApps(false, true);
    if (mounted) {
      setState(() {
        _allAppsLoaded = true;
      });
      updateAppList();
    }
  }

  updateAppList() {
    setState(() {
      if (_query == "") {
        _filteredApps = _allApps;
      } else {
        final queryLowerCase = _query.toLowerCase();
        _filteredApps = _allApps
            .where((e) =>
                e.name.toLowerCase().contains(queryLowerCase) ||
                e.packageName.toLowerCase().contains(queryLowerCase))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: SearchBar(
          onChanged: (value) {
            _query = value;
            updateAppList();
          },
          leading: const Icon(Icons.search),
        ),
      ),
      Expanded(
          child: !_allAppsLoaded
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _filteredApps.length,
                  itemBuilder: (context, i) {
                    final app = _filteredApps[i];
                    final icon = app.icon;
                    return ListTile(
                      leading: (icon == null) ? null : Image.memory(icon),
                      title: Text(app.name),
                      subtitle: Text(app.packageName),
                      trailing: Checkbox(
                          value: widget.selectedApps.contains(app.packageName),
                          onChanged: (selected) {
                            setState(() {
                              if (selected!) {
                                widget.selectedApps.add(app.packageName);
                              } else {
                                widget.selectedApps.remove(app.packageName);
                              }
                            });

                          }),
                    );
                  }))
    ]);
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
  }
}
