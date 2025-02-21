import 'dart:io';

import 'package:anyportal/utils/permission_manager.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/db.dart';
import '../../models/core.dart';
import '../models/asset.dart';
import '../utils/logger.dart';
import 'asset.dart';
import 'core_type.dart';

class CoreScreen extends StatefulWidget {
  final TypedResult? core;

  const CoreScreen({
    super.key,
    this.core,
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
    String? status;
    int? coreId;
    bool permitted = true;

    if (Platform.isAndroid) {
      if (context.mounted) {
        await permMan.requestPermission(
          context,
          Permission.storage,
          "Storage permission is required for cores to load assets.",
        ).then((status){
          if (status != PermissionStatus.granted) {
            permitted = false;
          }
        });
      }

      if (context.mounted) {
        await permMan.requestPermission(
          context,
          Permission.notification,
          "Notification permission is required for quick tiles to work properly",
        ).then((status){
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
            status = "updated";
          } else {
            coreId = await db.into(db.core).insert(CoreCompanion(
                  coreTypeId: Value(_coreTypeId),
                  updatedAt: Value(DateTime.now()),
                  isExec: Value(_coreIsExec),
                  workingDir: Value(workingDir),
                  envs: Value(envs),
                ));
            status = "inserted";
          }

          if (_coreIsExec) {
            await db.into(db.coreExec).insertOnConflictUpdate(CoreExecCompanion(
                  coreId: Value(coreId!),
                  assetId: Value(_assetId!),
                ));
          }
        });
        ok = true;
      }
    } catch (e) {
      logger.e("$e");
      final snackBar = SnackBar(
        content: Text("$e"),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final fields = [
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'core type',
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
              decoration: const InputDecoration(
                labelText: 'core asset',
                border: OutlineInputBorder(),
              ),
              items: _assets.map((e) {
                return DropdownMenuItem<int>(
                  value: e.read(db.asset.id),
                  child: Text(getAssetTitle(e)),
                );
              }).toList(),
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
                  if (res['ok'] == true){
                    _loadAssets();
                  }
                  if (res['status'] == 'inserted'){
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
        "Advanced",
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      TextFormField(
        controller: _envsController,
        decoration: const InputDecoration(
          labelText: 'envs',
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
                decoration: const InputDecoration(
                  labelText: 'working dir',
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
          decoration: const InputDecoration(
            labelText: 'args',
            hintText: '["run", "-c", "{config.path}"}]',
            border: OutlineInputBorder(),
          ),
        ),
      Center(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          ),
          child: const Text('Save and update'),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Edit core"),
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
