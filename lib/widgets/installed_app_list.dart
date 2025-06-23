import 'package:flutter/material.dart';

import 'package:installed_apps/app_info.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../utils/installed_app_list_manager.dart';

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
    updateFilteredAppList();
    updateAppList().then((_) {
      updateAppList(withIcon: true);
    });
  }

  bool isAppListLoading = false;
  List<AppInfo> _allApps = InstalledAppListManager.instance.appList;
  List<AppInfo> _filteredApps = [];

  String _query = "";

  Future<void> updateAppList({bool withIcon = false}) async {
    setState(() {
      isAppListLoading = true;
    });
    await InstalledAppListManager.instance.update(withIcon: withIcon);
    if (mounted) {
      setState(() {
        _allApps = InstalledAppListManager.instance.appList;
        isAppListLoading = false;
      });
      updateFilteredAppList();
    }
  }

  void updateFilteredAppList() {
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
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onChanged: (value) {
            _query = value;
            updateFilteredAppList();
          },
          leading: const Icon(Icons.search),
        ),
      ),
      SizedBox(
        height: 4,
        child: isAppListLoading ? LinearProgressIndicator() : null,
      ),
      Expanded(
          child: Scrollbar(
              interactive: true,
              child: Skeletonizer(
                  enabled: _filteredApps.isEmpty,
                  child: ListView.builder(
                      primary: true,
                      itemCount:
                          _filteredApps.isEmpty ? 12 : _filteredApps.length,
                      cacheExtent: 500,
                      itemBuilder: (context, i) {
                        if (_filteredApps.isEmpty) {
                          return const ListTile(
                              leading: SizedBox(
                                width: 56,
                                child: null,
                              ),
                              title: Text(""),
                              subtitle: Text(""),
                              trailing: Checkbox(
                                value: false,
                                onChanged: null,
                              ));
                        }

                        final app = _filteredApps[i];
                        final icon = app.icon;
                        return ListTile(
                          leading: SizedBox(
                              width: 56,
                              child: (icon != null && icon.isNotEmpty)
                                  ? Image(
                                      image: MemoryImage(icon),
                                      gaplessPlayback: true,
                                    )
                                  : Skeletonizer.zone(
                                      child: Bone.square(
                                      size: 56,
                                    ))),
                          title: Text(app.name),
                          subtitle: Text(app.packageName),
                          trailing: Checkbox(
                              value:
                                  widget.selectedApps.contains(app.packageName),
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
                      }))))
    ]);
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
  }
}
