import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fv2ray/models/asset.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import '../../../screens/core.dart';
import '../../../utils/db.dart';
import '../../core_type.dart';

class CoresScreen extends StatefulWidget {
  const CoresScreen({
    super.key,
  });

  @override
  State<CoresScreen> createState() => _CoresScreenState();
}

enum CoresAction {
  addCore,
  addCoreType,
}

extension ToLCString on CoresAction {
  String toShortString(context) {
    switch (this) {
      case CoresAction.addCore:
        return AppLocalizations.of(context)!.addCore;
      case CoresAction.addCoreType:
        return AppLocalizations.of(context)!.addCoreType;
    }
  }
}

enum CoreAction {
  delete,
  edit,
}

enum CoreTypeAction {
  delete,
  edit,
}

class _CoresScreenState extends State<CoresScreen> {
  var _highlightCoresPopupMenuButton = false;

  void setHighlightCoresPopupMenuButton() async {
    for (var i = 0; i < 5; ++i) {
      if (mounted) {
        setState(() {
          _highlightCoresPopupMenuButton = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        return;
      }
    }
  }

  void handleCoresAction(action) {
    switch (action) {
      case CoresAction.addCore:
        _addCore();
      case CoresAction.addCoreType:
        _addCoreType();
    }
  }

  void _addCore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CoreScreen()),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadCores();
      }
    });
  }

  void _addCoreType() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CoreTypeScreen()),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadCores();
      }
    });
  }

  void _editCore(TypedResult core) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CoreScreen(
                core: core,
              )),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadCores();
      }
    });
  }

  void _editCoreType(int coreTypeId) async {
    final coreType = await (db.select(db.coreType)
          ..where((p) => p.id.equals(coreTypeId)))
        .getSingle();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CoreTypeScreen(
                  coreType: coreType,
                )),
      ).then((res) {
        if (res != null && res['ok'] == true) {
          _loadCores();
        }
      });
    }
  }

  Map<int, List<TypedResult>> _groupedCores = {};
  Map<int, TypedResult> _cores = {};
  Map<int, TypedResult> _coreTypes = {};
  Map<int, int> _coreTypeSeclectedId = {};

  final TreeNode _root = TreeNode.root();

  Future<void> _loadCores() async {
    final cores = await db.select(db.core).join([
      leftOuterJoin(db.coreExec, db.core.id.equalsExp(db.coreExec.coreId)),
      leftOuterJoin(db.coreLib, db.core.id.equalsExp(db.coreLib.coreId)),
      leftOuterJoin(db.coreTypeSelected,
          db.core.id.equalsExp(db.coreTypeSelected.coreId)),
      leftOuterJoin(db.coreType, db.core.coreTypeId.equalsExp(db.coreType.id)),
      leftOuterJoin(db.asset, db.coreExec.assetId.equalsExp(db.asset.id)),
      leftOuterJoin(
          db.assetRemote, db.assetRemote.assetId.equalsExp(db.asset.id)),
    ]).get();
    final coreTypes = await (db.select(db.coreType).join([
      leftOuterJoin(db.coreTypeSelected,
          db.coreTypeSelected.coreTypeId.equalsExp(db.coreType.id)),
    ])
          ..orderBy([OrderingTerm.asc(db.coreType.name)]))
        .get();

    _groupedCores = {};
    _cores = {};
    for (var core in cores) {
      final coreTypeId = core.read(db.core.coreTypeId)!;
      if (!_groupedCores.containsKey(coreTypeId)) {
        _groupedCores[coreTypeId] = [];
      }
      _groupedCores[coreTypeId]!.add(core);
      _cores[core.read(db.core.id)!] = core;
    }
    _coreTypeSeclectedId = {};
    _coreTypes = {};
    for (var coreType in coreTypes) {
      final coreTypeId = coreType.read(db.coreType.id)!;
      _coreTypes[coreTypeId] = coreType;
      final coreTypeSelectedId = coreType.read(db.coreTypeSelected.coreId);
      if (coreTypeSelectedId != null) {
        _coreTypeSeclectedId[coreTypeId] = coreTypeSelectedId;
      }
    }

    _root.clear();

    for (var coreTypeId in _coreTypes.keys) {
      final cores = _groupedCores[coreTypeId];
      if (cores != null) {
        _root.add(TreeNode(
          data: coreTypeId,
          key: "$coreTypeId",
        )..addAll(cores.map((core) {
            return TreeNode(data: core, key: "${core.read(db.core.id)!}");
          }).toList()));
      }
    }

    if (cores.isEmpty) {
      setHighlightCoresPopupMenuButton();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCores();
  }

  void handleCoreAction(TypedResult core, CoreAction action) async {
    switch (action) {
      case CoreAction.delete:
        await (db.delete(db.core)
              ..where((e) => e.id.equals(core.read(db.core.id)!)))
            .go();
        _loadCores();
      case CoreAction.edit:
        _editCore(core);
    }
  }

  void handleCoreTypeAction(int coreTypeId, CoreTypeAction action) async {
    switch (action) {
      case CoreTypeAction.delete:
        await db.transaction(() async {
          (db.delete(db.core)..where((e) => e.coreTypeId.equals(coreTypeId)))
              .go();
          // do not delete the default local group
          if (coreTypeId > 2) {
            (db.delete(db.coreType)..where((e) => e.id.equals(coreTypeId)))
                .go();
          }
        });
        _loadCores();
      case CoreTypeAction.edit:
        _editCoreType(coreTypeId);
    }
  }

  String getCoreTypeTitle(TypedResult coreType) {
    return coreType.read(db.coreType.name)!;
  }

  String getCoreTypeSubTitle(TypedResult coreType) {
    final coreTypeId = coreType.read(db.coreType.id)!;
    if (_coreTypeSeclectedId.containsKey(coreTypeId)) {
      final selectedCoreId = _coreTypeSeclectedId[coreTypeId];
      final selectedCore = _cores[selectedCoreId];
      return getCoreTitle(selectedCore!);
    } else {
      return "No core selected!";
    }
  }

  String getCoreTitle(TypedResult core) {
    if (core.readWithConverter(db.asset.type) == AssetType.local) {
      if (core.read(db.core.isExec)!) {
        return core.read(db.asset.path)!;
      } else {
        return "embedded";
      }
    } else {
      return core.read(db.assetRemote.url)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Stack(children: [
            Text(AppLocalizations.of(context)!.cores),
            Align(
                alignment: Alignment.topRight,
                child: SmoothHighlight(
                    enabled: _highlightCoresPopupMenuButton,
                    color: Colors.grey,
                    child: PopupMenuButton(
                      itemBuilder: (context) => CoresAction.values
                          .map((action) => PopupMenuItem(
                                value: action,
                                child: Text(action.toShortString(context)),
                              ))
                          .toList(),
                      onSelected: (value) => handleCoresAction(value),
                    )))
          ]),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: CustomScrollView(slivers: [
              SliverTreeView.simple(
                tree: _root,
                showRootNode: false,
                expansionIndicatorBuilder: (context, node) =>
                    ChevronIndicator.rightDown(
                  alignment: Alignment.centerLeft,
                  tree: node,
                ),
                indentation: const Indentation(style: IndentStyle.squareJoint),
                // onTreeReady: (controller) {
                //   if (true) controller.expandAllChildren(_root);
                // },
                builder: (context, node) {
                  if (node.level == 2) {
                    final core = node.data as TypedResult;
                    final coreId = core.read(db.core.id)!;
                    final coreTypeId = core.read(db.coreType.id)!;
                    return RadioListTile(
                        value: coreId,
                        groupValue: _coreTypeSeclectedId[coreTypeId],
                        onChanged: (value) {
                          // prefs.setInt('app.selectedCoreId', value!);
                          db
                              .into(db.coreTypeSelected)
                              .insertOnConflictUpdate(CoreTypeSelectedCompanion(
                                coreTypeId: Value(coreTypeId),
                                coreId: Value(coreId),
                              ));
                          setState(() {
                            _coreTypeSeclectedId[coreTypeId] = value!;
                          });
                        },
                        title: Text(getCoreTitle(core)),
                        subtitle: Text(
                            'last updated: ${core.read(db.core.updatedAt)}'),
                        secondary: PopupMenuButton<CoreAction>(
                          onSelected: (value) => handleCoreAction(core, value),
                          itemBuilder: (context) => CoreAction.values
                              .map((action) => PopupMenuItem(
                                    value: action,
                                    child: Text(action.name),
                                  ))
                              .toList(),
                        ));
                  } else {
                    final coreTypeId = node.data as int;
                    final coreTypeTitle =
                        getCoreTypeTitle(_coreTypes[coreTypeId]!);
                    final coreTypeSubTitle =
                        getCoreTypeSubTitle(_coreTypes[coreTypeId]!);
                    return ListTile(
                      title: Text(coreTypeTitle),
                      subtitle: Text(coreTypeSubTitle),
                      // leading: node.isExpanded ? Icon(Icons.folder_open) : Icon(Icons.folder),
                      leading: const Icon(null),
                      trailing: PopupMenuButton<CoreTypeAction>(
                        onSelected: (value) =>
                            handleCoreTypeAction(coreTypeId, value),
                        itemBuilder: (context) => CoreTypeAction.values
                            .map((action) => PopupMenuItem(
                                  value: action,
                                  child: Text(action.name),
                                ))
                            .toList(),
                      ),
                    );
                  }
                },
              ),
            ])));
  }
}
