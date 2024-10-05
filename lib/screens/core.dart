import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../utils/db.dart';
import '../../models/core.dart';
import '../models/asset.dart';
import '../utils/prefs.dart';

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
  int _coreTypeId = CoreTypeDefault.v2ray.index;
  bool _coreIsExec = true;

  final _workingDirController = TextEditingController(text: '');
  final _argsController =
      TextEditingController(text: '["run", "-c", "{configFile}"}]');
  final _envsController = TextEditingController(text: '{}');

  AssetType _assetType = AssetType.local;
  final _assetPathController = TextEditingController();
  final _urlController = TextEditingController();
  final _autoUpdateIntervalController = TextEditingController(text: '0');

  Future<void> _loadField() async {
    _coreTypeDataList = await (db.select(db.coreType).get());
    if (mounted) {
      setState(() {
        _coreTypeDataList = _coreTypeDataList;
      });
    }
  }

  Future<void> _loadCore() async {
    String args = "";
    String assetPath = "";

    if (widget.core != null) {
      _coreIsExec = widget.core!.read(db.core.isExec)!;
      _coreTypeId = widget.core!.read(db.core.coreTypeId)!;
      final coreId = widget.core!.read(db.core.id)!;
      if (_coreIsExec) {
        final coreExec = await (db.select(db.coreExec)
              ..where((p) => p.coreId.equals(coreId)))
            .getSingle();
        args = coreExec.args;
        final asset = await (db.select(db.asset)
              ..where((p) => p.id.equals(coreExec.assetId)))
            .getSingle();
        _assetType = asset.type;
        if (_assetType == AssetType.local) {
          assetPath = asset.path;
        }
      }
    }

    if (mounted) {
      setState(() {
        _coreIsExec = _coreIsExec;
        _coreTypeId = _coreTypeId;
        _assetType = _assetType;
        _argsController.text = args;
        _assetPathController.text = assetPath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadField();
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
        final _args = _argsController.text;
        String _workingDir = _workingDirController.text;
        String _assetPath = _assetPathController.text;
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

          int assetId;
          if (_coreIsExec) {
            if (oldCore != null) {
              assetId = (await (db.select(db.coreExec)
                        ..where((p) => p.coreId.equals(coreId)))
                      .getSingle())
                  .assetId;
              await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
                    id: Value(assetId),
                    type: Value(_assetType),
                    path: Value(_assetPath),
                    updatedAt: Value(DateTime.now()),
                  ));
            } else {
              assetId = await db.into(db.asset).insert(AssetCompanion(
                    type: Value(_assetType),
                    path: Value(_assetPath),
                    updatedAt: Value(DateTime.now()),
                  ));
            }
            await db.into(db.coreExec).insertOnConflictUpdate(CoreExecCompanion(
                  coreId: Value(coreId),
                  args: Value(_args),
                  assetId: Value(assetId),
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
      final folder = await getApplicationDocumentsDirectory();
      final dest = File(p.join(folder.path, 'fv2ray', 'core')).path;
      await File(corePath).rename(dest);
      await FilePicker.platform.clearTemporaryFiles();
      corePath = dest;
    }
    if (Platform.isAndroid) {
      await Process.start("chmod", ["a+x", corePath]);
    }
    prefs.setString('core.path', corePath);
    setState(() {
      _assetPathController.text = corePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<int>(
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
      DropdownButtonFormField<AssetType>(
          decoration: const InputDecoration(
            labelText: 'core file type',
            border: OutlineInputBorder(),
          ),
          items: AssetType.values.map((AssetType t) {
            return DropdownMenuItem<AssetType>(value: t, child: Text(t.name));
          }).toList(),
          value: _assetType,
          onChanged: (value) {
            setState(() {
              _assetType = value!;
            });
          }),
      if (_coreIsExec && _assetType == AssetType.local)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _assetPathController,
                decoration: const InputDecoration(
                  labelText: 'core path',
                  hintText: '/path/to/core_excutable',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _selectCorePath,
            ),
          ],
        ),
      if (_assetType == AssetType.remote)
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'url',
            hintText: 'github://owner/repo/asset.ext[/sub/path]',
            border: OutlineInputBorder(),
          ),
        ),
      if (_assetType == AssetType.remote)
        TextFormField(
          controller: _autoUpdateIntervalController,
          decoration: const InputDecoration(
            labelText: 'auto update interval (seconds), 0 to disable',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
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
