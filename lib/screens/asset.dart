import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../utils/db.dart';
import '../../models/asset.dart';
import '../utils/prefs.dart';

class AssetScreen extends StatefulWidget {
  final TypedResult? asset;

  const AssetScreen({
    super.key,
    this.asset,
  });

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  AssetType _assetType = AssetType.local;
  final _assetPathController = TextEditingController();
  final _urlController = TextEditingController();
  final _autoUpdateIntervalController = TextEditingController(text: '0');

  Future<void> _loadAsset() async {
    String assetPath = "";

    if (widget.asset != null) {
        _assetType = widget.asset!.readWithConverter(db.asset.type)!;
        if (_assetType == AssetType.local) {
          assetPath = widget.asset!.read(db.asset.path)!;
        }
    }

    if (mounted) {
      setState(() {
        _assetType = _assetType;
        _assetPathController.text = assetPath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  // Method to handle form submission
  void _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    bool ok = false;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        final oldAsset = widget.asset;
        String _assetPath = _assetPathController.text;
        int assetId;
        await db.transaction(() async {
          if (oldAsset != null) {
            assetId = oldAsset.read(db.asset.id)!;
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

  Future<void> _selectAssetPath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    String assetPath = result.files.single.path!;
    if (Platform.isAndroid) {
      final folder = await getApplicationDocumentsDirectory();
      final dest = File(p.join(folder.path, 'fv2ray', 'asset')).path;
      await File(assetPath).rename(dest);
      await FilePicker.platform.clearTemporaryFiles();
      assetPath = dest;
    }
    prefs.setString('asset.path', assetPath);
    setState(() {
      _assetPathController.text = assetPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<AssetType>(
          decoration: const InputDecoration(
            labelText: 'asset type',
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
      if (_assetType == AssetType.local)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _assetPathController,
                decoration: const InputDecoration(
                  labelText: 'asset path',
                  hintText: '/path/to/asset_excutable',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _selectAssetPath,
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
        title: const Text("Edit asset"),
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
