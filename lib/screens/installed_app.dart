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
        ]
      },
    );
    _allApps = apps?.map((e) => InstalledApp.fromMap(e)).toList() ?? [];
    _allApps.sort((a, b) => a.applicationLabel!.compareTo(b.applicationLabel!));
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
                e.applicationLabel?.toLowerCase().contains(queryLowerCase) ==
                    true ||
                e.packageName.toLowerCase().contains(queryLowerCase))
            .toList();
      }

      if (!isToShowSystemApps) {
        _filteredApps =
            _filteredApps.where((e) => e.flagSystem == false).toList();
      }
    });
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
              itemBuilder: (context) =>
                  InstalledAppScreenAction.values.map((action) {
                switch (action) {
                  case InstalledAppScreenAction.showSystemApps:
                    return PopupMenuItem(
                      child: IgnorePointer(
                        child: CheckboxListTile(
                          title: Text(action.localized(context)),
                          value: isToShowSystemApps,
                          onChanged: (_) {},
                        ),
                      ),
                      onTap: () {
                        isToShowSystemApps = !isToShowSystemApps;
                        updateFilteredAppList();
                      },
                    );
                }
              }).toList(),
              onSelected: (selected) {
                switch (selected) {
                  case InstalledAppScreenAction.showSystemApps:
                }
              },
            )
          ],
        ),
        body: Scrollbar(
          interactive: true,
          child: Skeletonizer(
            enabled: _filteredApps.isEmpty,
            child: ListView.builder(
              primary: true,
              itemCount: _filteredApps.isEmpty ? 4 : _filteredApps.length,
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
                  title: Text(app.applicationLabel ?? ""),
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
  final String? applicationLabel;
  final bool? flagSystem;
  final int? lastUpdateTime;
  final String? iconPath;

  InstalledApp({
    required this.packageName,
    this.applicationLabel,
    this.flagSystem,
    this.lastUpdateTime,
    this.iconPath,
  });

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    return InstalledApp(
      packageName: map['packageName'],
      applicationLabel: map['applicationLabel'],
      flagSystem: map['flagSystem'],
      lastUpdateTime: map['installedTimestamp'],
      iconPath: map['iconPath'],
    );
  }
}

enum InstalledAppScreenAction {
  showSystemApps,
}

extension InstalledAppScreenActionX on InstalledAppScreenAction {
  String localized(BuildContext context) {
    switch (this) {
      case InstalledAppScreenAction.showSystemApps:
        return "Show system apps";
    }
  }
}
