import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../utils/db.dart';
import '../../models/asset.dart';
import '../utils/asset_remote/github.dart';
import '../utils/logger.dart';

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

    final asset = widget.asset;

    if (asset != null) {
      _assetType = widget.asset!.readWithConverter(db.asset.type)!;
      if (_assetType == AssetType.local) {
        assetPath = asset.read(db.asset.path)!;
      } else {
        _urlController.text = asset.read(db.assetRemote.url)!;
        _autoUpdateIntervalController.text =
            asset.read(db.assetRemote.autoUpdateInterval).toString();
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
    String? status;
    int? id;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        final oldAsset = widget.asset;
        final assetPath = _assetPathController.text;
        final autoUpdateInterval = _autoUpdateIntervalController.text;

        if (_assetType == AssetType.remote) {
          final assetRemote =
              AssetRemoteProtocolGithub.fromUrl(_urlController.text);
          if (assetRemote == null) {
            throw Exception("invalid url");
          } else {
            await assetRemote.update(
              oldAsset: oldAsset,
              autoUpdateInterval: int.parse(autoUpdateInterval),
            );
          }
        } else if (_assetType == AssetType.local) {
          if (oldAsset != null) {
            final assetId = oldAsset.read(db.asset.id)!;
            await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
                  id: Value(assetId),
                  type: Value(_assetType),
                  path: Value(assetPath),
                  updatedAt: Value(DateTime.now()),
                ));
            status = "updated";
            id = assetId;
          } else {
            id = await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
                  type: Value(_assetType),
                  path: Value(assetPath),
                  updatedAt: Value(DateTime.now()),
                ));
            status = "inserted";
          }
        }
      }
      ok = true;
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
        'id': id,
      });
    }
  }

  Future<void> _selectAssetPath() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return;
    }
    String assetPath = result.files.single.path!;
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
              icon: const Icon(Icons.folder_open),
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
