import 'package:flutter/material.dart';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/core.dart';
import '../../utils/db.dart';
import '../extensions/localization.dart';
import '../models/asset.dart';
import '../models/edit_status.dart';
import '../utils/logger.dart';
import '../utils/permission_manager.dart';
import '../utils/runtime_platform.dart';
import '../utils/show_snack_bar_now.dart';
import '../widgets/form/progress_button.dart';

import 'asset.dart';
import 'core_type.dart';

class CoreScreen extends StatefulWidget {
  final TypedResult? core;
  final int? coreTypeId;

  const CoreScreen({
    super.key,
    this.core,
    this.coreTypeId,
  });

  @override
  State<CoreScreen> createState() => _CoreScreenState();
}

class _CoreScreenState extends State<CoreScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  List<CoreTypeData> _coreTypeDataList = [];
  List<TypedResult> _assets = [];
  int _coreTypeId = CoreTypeDefault.v2ray.index;
  bool _coreIsExec = true;
  String _workingDir = "";
  int? _assetId;
  String _args = "";
  String _envs = "{}";

  final _workingDirController = TextEditingController(text: '');
  final _argsController =
      TextEditingController(text: '["run", "-c", "{config.path}"}]');
  final _envsController = TextEditingController(text: '{}');

  Future<void> _loadCoreTypes() async {
    _coreTypeDataList = await (db.select(db.coreType).get());
    if (mounted) {
      setState(() {
        _coreTypeDataList = _coreTypeDataList;
      });
    }
  }

  Future<void> _loadAssets() async {
    _assets = await (db.select(db.asset).join([
      leftOuterJoin(
          db.assetRemote, db.asset.id.equalsExp(db.assetRemote.assetId)),
    ])
          ..orderBy([OrderingTerm.asc(db.asset.path)]))
        .get();
    if (mounted) {
      setState(() {
        _assets = _assets;
      });
    }
  }

  Future<void> _loadCore() async {
    _coreTypeId = widget.coreTypeId ?? _coreTypeId;
    if (widget.core != null) {
      _coreIsExec = widget.core!.read(db.core.isExec)!;
      _coreTypeId = widget.core!.read(db.core.coreTypeId)!;
      _envs = widget.core!.read(db.core.envs)!;
      _workingDir = widget.core!.read(db.core.workingDir)!;
      if (_coreIsExec) {
        _args = widget.core!.read(db.coreExec.args)!;
        _assetId = widget.core!.read(db.coreExec.assetId)!;
      }
    }

    if (mounted) {
      setState(() {
        _coreIsExec = _coreIsExec;
        _coreTypeId = _coreTypeId;
        _envsController.text = _envs;
        _workingDirController.text = _workingDir;
        _argsController.text = _args;
        _assetId = _assetId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCoreTypes();
    _loadAssets();
    _loadCore();
  }

  // Method to handle form submission
  void _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    bool ok = false;
    EditStatus? status;
    int? coreId;
    bool permitted = true;

    if (RuntimePlatform.isAndroid) {
      if (context.mounted) {
        await permMan
            .requestPermission(
          context,
          Permission.storage,
          context.loc.storage_permission_is_required_for_cores_to_load_assets_,
        )
            .then((status) {
          if (status != PermissionStatus.granted) {
            permitted = false;
          }
        });
      }
    }

    try {
      if (permitted && (_formKey.currentState?.validate() ?? false)) {
        final oldCore = widget.core;
        final workingDir = _workingDirController.text;
        final envs = _envsController.text;
        final args = _argsController.text;
        await db.transaction(() async {
          if (oldCore != null) {
            coreId = oldCore.read(db.core.id)!;
            await db.into(db.core).insertOnConflictUpdate(CoreCompanion(
                  id: Value(coreId!),
                  coreTypeId: Value(_coreTypeId),
                  updatedAt: Value(DateTime.now()),
                  isExec: Value(_coreIsExec),
                  workingDir: Value(workingDir),
                  envs: Value(envs),
                ));
            status = EditStatus.updated;
          } else {
            coreId = await db.into(db.core).insert(CoreCompanion(
                  coreTypeId: Value(_coreTypeId),
                  updatedAt: Value(DateTime.now()),
                  isExec: Value(_coreIsExec),
                  workingDir: Value(workingDir),
                  envs: Value(envs),
                ));
            status = EditStatus.inserted;
          }

          if (_coreIsExec) {
            await db.into(db.coreExec).insertOnConflictUpdate(CoreExecCompanion(
                  args: Value(args),
                  coreId: Value(coreId!),
                  assetId: Value(_assetId!),
                ));
          }
        });
        ok = true;
      }
    } catch (e) {
      logger.e("_submitForm: $e");
      if (mounted) showSnackBarNow(context, Text("_submitForm: $e"));
    }

    setState(() {
      _isSubmitting = false;
    });

    /// check permitted, or could accidently pop permission request popup instead
    if (permitted && mounted && Navigator.canPop(context)) {
      Navigator.pop(context, {
        'ok': ok,
        'status': status,
        'coreId': coreId,
        'coreTypeId': _coreTypeId,
      });
    }
  }

  Future<void> _selectWorkingDir() async {
    String? workingDir = await FilePicker.platform.getDirectoryPath();
    if (workingDir == null) {
      return;
    }
    _workingDirController.text = workingDir;
  }

  String getAssetTitle(TypedResult asset) {
    if (asset.readWithConverter(db.asset.type) == AssetType.local) {
      return asset.read(db.asset.path)!;
    } else {
      return asset.read(db.assetRemote.url)!;
    }
  }

  List<DropdownMenuItem<int>> getDropdownMenuItems() {
    final dropdownMenuItems = _assets.map((e) {
      int? assetId = -1;
      assetId = e.read(db.asset.id);
      return DropdownMenuItem<int>(
        value: assetId,
        child: Text(getAssetTitle(e)),
      );
    }).toList();

    // e.g. if asset is deleted, _assetId not in dropdownMenuItems would cause problems
    bool isAssetIdValid = false;
    for (DropdownMenuItem item in dropdownMenuItems) {
      if (item.value == _assetId) {
        isAssetIdValid = true;
        break;
      }
    }
    if (!isAssetIdValid) {
      dropdownMenuItems.add(DropdownMenuItem<int>(
        value: _assetId,
        child: Text(context.loc.warning_invalid_asset),
      ));
    }

    return dropdownMenuItems;
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: context.loc.core_type,
                border: OutlineInputBorder(),
              ),
              items: _coreTypeDataList.map((e) {
                return DropdownMenuItem<int>(value: e.id, child: Text(e.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _coreTypeId = value!;
                });
              },
              value: _coreTypeId,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoreTypeScreen()),
              ).then((res) {
                if (res != null && res['ok'] == true) {
                  _loadCoreTypes();
                }
              });
            },
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: context.loc.core_executable,
                border: OutlineInputBorder(),
              ),
              items: getDropdownMenuItems(),
              onChanged: (e) {
                setState(() {
                  _assetId = e;
                });
              },
              value: _assetId,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssetScreen()),
              ).then((res) {
                if (res != null) {
                  if (res['ok'] == true) {
                    _loadAssets();
                  }
                  if (res['status'] == EditStatus.inserted) {
                    setState(() {
                      _assetId = res['id'];
                    });
                  }
                }
              });
            },
          ),
        ],
      ),
      const Divider(),
      Text(
        context.loc.advanced,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      TextFormField(
        controller: _envsController,
        decoration: InputDecoration(
          labelText: context.loc.envs,
          hintText: '{"key1":"value1", "key2":"value2"}',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      if (_coreIsExec)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _workingDirController,
                decoration: InputDecoration(
                  labelText: context.loc.working_dir,
                  hintText: "use core's parent folder if leave empty",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _selectWorkingDir,
            ),
          ],
        ),
      if (_coreIsExec)
        TextFormField(
          controller: _argsController,
          decoration: InputDecoration(
            labelText: context.loc.args,
            hintText: '["run", "-c", "{config.path}"}]',
            border: OutlineInputBorder(),
          ),
        ),
      ProgressButton(
        isInProgress: _isSubmitting,
        onPressed: _submitForm,
        child: Text(context.loc.save_and_update),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.edit_core),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView.separated(
            itemCount: fields.length,
            itemBuilder: (context, index) => fields[index],
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }
}
