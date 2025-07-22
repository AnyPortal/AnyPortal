import 'dart:io';

import 'package:flutter/material.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../extensions/localization.dart';
import '../utils/method_channel.dart';

class InstalledAppScreen extends StatefulWidget {
  late final Set<String> selectedApps;
  final void Function(Set<String>)? handleSelectedApps;
  late final String? title;

  InstalledAppScreen({
    super.key,
    selectedApps,
    this.handleSelectedApps,
    this.title,
  }) {
    this.selectedApps = selectedApps ?? {};
  }

  @override
  State<InstalledAppScreen> createState() => _InstalledAppScreenState();
}

class _InstalledAppScreenState extends State<InstalledAppScreen> {
  bool isEditingSearchQuery = false;
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  bool isToShowSystemApps = true;
  String sortBy = "applicationLabel";

  bool isAppListLoading = false;
  List<InstalledApp> _allApps = [];
  List<InstalledApp> _filteredApps = [];

  Future<void> updateAppList({bool ensureIcon = false}) async {
    setState(() {
      isAppListLoading = true;
    });
    final apps = await mCMan.methodChannel.invokeListMethod(
      'os.getInstalledApps',
      {
        'fields': [
          "applicationLabel",
          "flagSystem",
          "iconPath",
          "firstInstallTime",
          "lastUpdateTime",
        ]
      },
    );
    _allApps = apps?.map((e) => InstalledApp.fromMap(e)).toList() ?? [];
    if (mounted) {
      setState(() {
        _allApps = _allApps;
        isAppListLoading = false;
      });
      updateFilteredAppList();
    }
  }

  void updateFilteredAppList() {
    setState(() {
      if (textEditingController.text == "") {
        _filteredApps = _allApps;
      } else {
        final queryLowerCase = textEditingController.text.toLowerCase();
        _filteredApps = _allApps
            .where((e) =>
                e.applicationLabel.toLowerCase().contains(queryLowerCase) ==
                    true ||
                e.packageName.toLowerCase().contains(queryLowerCase))
            .toList();
      }

      if (!isToShowSystemApps) {
        _filteredApps =
            _filteredApps.where((e) => e.flagSystem == false).toList();
      }

      _filteredApps.sort((a, b) {
        switch (sortBy) {
          case "firstInstallTime":
            return -a.firstInstallTime.compareTo(b.firstInstallTime);
          case "lastUpdateTime":
            return -a.lastUpdateTime.compareTo(b.lastUpdateTime);
          case "applicationLabel":
          case _:
            return a.applicationLabel.compareTo(b.applicationLabel);
        }
      });
    });
  }

  List<PopupMenuEntry> getPopupMenuItems(BuildContext context) {
    return [
      PopupMenuItem(
        child: Text(
          context.loc.sort_by,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      PopupMenuItem(
        child: IgnorePointer(
          child: RadioListTile(
            title: Text(context.loc.app_name),
            value: "applicationLabel",
            groupValue: sortBy,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (_) {},
          ),
        ),
        onTap: () {
          sortBy = "applicationLabel";
          updateFilteredAppList();
        },
      ),
      PopupMenuItem(
        child: IgnorePointer(
          child: RadioListTile(
            title: Text(context.loc.last_update_time),
            value: "lastUpdateTime",
            groupValue: sortBy,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (_) {},
          ),
        ),
        onTap: () {
          sortBy = "lastUpdateTime";
          updateFilteredAppList();
        },
      ),
      PopupMenuItem(
        child: IgnorePointer(
          child: RadioListTile(
            title: Text(context.loc.first_install_time),
            value: "firstInstallTime",
            groupValue: sortBy,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (_) {},
          ),
        ),
        onTap: () {
          sortBy = "firstInstallTime";
          updateFilteredAppList();
        },
      ),
      PopupMenuItem(
        child: Text(
          context.loc.options,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      PopupMenuItem(
        child: IgnorePointer(
          child: CheckboxListTile(
            title: Text(context.loc.show_system_apps),
            value: isToShowSystemApps,
            onChanged: (_) {},
          ),
        ),
        onTap: () {
          isToShowSystemApps = !isToShowSystemApps;
          updateFilteredAppList();
        },
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    updateFilteredAppList();
    updateAppList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? context.loc.installed_apps;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (widget.handleSelectedApps != null) {
          widget.handleSelectedApps!(widget.selectedApps);
        }
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: isEditingSearchQuery
              ? TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Theme.of(context).hintColor,
                        width: 0.1,
                      )),
                      isDense: true),
                  onChanged: (_) {
                    updateFilteredAppList();
                  },
                )
              : Text(title),
          actions: [
            IconButton(
              icon: Icon(isEditingSearchQuery ? Icons.close : Icons.search),
              onPressed: () {
                final wasEditingSearchQuery = isEditingSearchQuery;
                setState(() {
                  isEditingSearchQuery = !wasEditingSearchQuery;
                });
                if (!wasEditingSearchQuery) {
                  focusNode.requestFocus();
                }
              },
            ),
            PopupMenuButton(
              itemBuilder: getPopupMenuItems,
            )
          ],
        ),
        body: Scrollbar(
          interactive: true,
          child: Skeletonizer(
            enabled: _filteredApps.isEmpty,
            child: ListView.builder(
              primary: true,
              itemCount: _filteredApps.isEmpty ? 12 : _filteredApps.length,
              cacheExtent: 5000,
              itemBuilder: (context, i) {
                if (_filteredApps.isEmpty) {
                  return const ListTile(
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: Skeletonizer.zone(
                        child: Bone.square(
                          size: 56,
                        ),
                      ),
                    ),
                    title: Skeletonizer.zone(child: Bone.text()),
                    subtitle: Skeletonizer.zone(child: Bone.text()),
                    trailing: Checkbox(
                      value: false,
                      onChanged: null,
                    ),
                  );
                }

                final app = _filteredApps[i];
                final iconPath = app.iconPath;
                return CheckboxListTile(
                  secondary: SizedBox(
                      width: 56,
                      height: 56,
                      child: (iconPath != null)
                          ? Image.file(File(iconPath))
                          : Skeletonizer.zone(
                              child: Bone.square(
                              size: 56,
                            ))),
                  title: Text(app.applicationLabel),
                  subtitle: Text(app.packageName),
                  value: widget.selectedApps.contains(app.packageName),
                  onChanged: (selected) {
                    setState(() {
                      if (selected!) {
                        widget.selectedApps.add(app.packageName);
                      } else {
                        widget.selectedApps.remove(app.packageName);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class InstalledApp {
  final String packageName;
  final String applicationLabel;
  final bool flagSystem;
  final int firstInstallTime;
  final int lastUpdateTime;
  final String? iconPath;

  InstalledApp({
    required this.packageName,
    required this.applicationLabel,
    required this.flagSystem,
    required this.firstInstallTime,
    required this.lastUpdateTime,
    required this.iconPath,
  });

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    return InstalledApp(
      packageName: map['packageName'],
      applicationLabel: map['applicationLabel'],
      flagSystem: map['flagSystem'],
      firstInstallTime: map['firstInstallTime'],
      lastUpdateTime: map['lastUpdateTime'],
      iconPath: map['iconPath'],
    );
  }
}
