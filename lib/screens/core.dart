import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../utils/db.dart';
import '../../models/core.dart';
import '../models/asset.dart';
import '../utils/global.dart';
import '../utils/prefs.dart';
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
      TextEditingController(text: '["run", "-c", "{configFile}"}]');
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

    try {
      if (_formKey.currentState?.validate() ?? false) {
        final oldCore = widget.core;
        final _envs = _envsController.text;

        String _workingDir = _workingDirController.text;
        int coreId;
        await db.transaction(() async {
          if (oldCore != null) {
            coreId = oldCore.read(db.core.id)!;
            await db.into(db.core).insertOnConflictUpdate(CoreCompanion(
                  id: Value(coreId),
                  coreTypeId: Value(_coreTypeId),
                  updatedAt: Value(DateTime.now()),
                  isExec: Value(_coreIsExec),
                  workingDir: Value(_workingDir),
                  envs: Value(_envsController.text),
                ));
          } else {
            coreId = await db.into(db.core).insert(CoreCompanion(
                  coreTypeId: Value(_coreTypeId),
                  updatedAt: Value(DateTime.now()),
                  isExec: Value(_coreIsExec),
                  workingDir: Value(_workingDir),
                  envs: Value(_envs),
                ));
          }

          if (_coreIsExec) {
            await db.into(db.coreExec).insertOnConflictUpdate(CoreExecCompanion(
                  coreId: Value(coreId),
                  assetId: Value(_assetId!),
                ));
          }
        });
      }
      ok = true;
    } catch (e) {
      final snackBar = SnackBar(
        content: Text("$e"),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (ok) {
      if (mounted) Navigator.pop(context, {'ok': true});
    }
  }

  Future<void> _selectCorePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    String corePath = result.files.single.path!;
    if (Platform.isAndroid) {
      final folder = global.applicationSupportDirectory;
      final dest = File(p.join(folder.path, 'core')).path;
      await File(corePath).rename(dest);
      await FilePicker.platform.clearTemporaryFiles();
      corePath = dest;
    }
    if (Platform.isAndroid) {
      await Process.start("chmod", ["a+x", corePath]);
    }
    prefs.setString('core.path', corePath);
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
              onChanged: widget.core != null
                  ? null
                  : (value) {
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
                if (res != null && res['ok'] == true) {
                  _loadAssets();
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
        TextFormField(
          controller: _workingDirController,
          decoration: const InputDecoration(
            labelText: 'working dir',
            hintText: "use core's parent folder if leave empty",
            border: OutlineInputBorder(),
          ),
        ),
      if (_coreIsExec)
        TextFormField(
          controller: _argsController,
          decoration: const InputDecoration(
            labelText: 'args',
            hintText: '["run", "-c", "{configFile}"}]',
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
