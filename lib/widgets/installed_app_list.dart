import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

import '../utils/prefs.dart';

class InstalledAppList extends StatefulWidget {
  const InstalledAppList({super.key});

  @override
  State<InstalledAppList> createState() => _InstalledAppListState();
}

class _InstalledAppListState extends State<InstalledAppList> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _listInstalledApps();
  }
  
  Set<String> _selectApps = {};
  
  Future<void> _loadSettings() async {
    final selectedAppString = prefs.getString('tun.selectedApps') ?? "[]";
    final selectedAppStringDecoded = jsonDecode(selectedAppString);
    setState(() {
      _selectApps = List<String>.from(selectedAppStringDecoded).toSet();
    });
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
        _filteredApps = _allApps
            .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
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
                          value: _selectApps.contains(app.packageName),
                          onChanged: (selected) {
                            setState(() {
                              if (selected!) {
                                _selectApps.add(app.packageName);
                              } else {
                                _selectApps.remove(app.packageName);
                              }
                            });
                            prefs.setString('tun.selectedApps', jsonEncode(_selectApps.toList()));
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
