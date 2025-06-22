import 'package:flutter/material.dart';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/asset.dart';
import '../../utils/db.dart';
import '../extensions/localization.dart';
import '../models/edit_status.dart';
import '../utils/asset_remote/github.dart';
import '../utils/logger.dart';
import '../utils/runtime_platform.dart';
import '../utils/show_snack_bar_now.dart';
import '../widgets/form/progress_button.dart';

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
    EditStatus? status;
    int? id;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        final oldAsset = widget.asset;
        final assetPath = _assetPathController.text;
        final autoUpdateInterval = _autoUpdateIntervalController.text;

        if (_assetType == AssetType.remote) {
          final assetRemote =
              AssetRemoteProtocolGithub.fromUrl(_urlController.text);
          await assetRemote.update(
            asset: oldAsset,
            autoUpdateInterval: int.parse(autoUpdateInterval),
          );
        } else if (_assetType == AssetType.local) {
          if (oldAsset != null) {
            final assetId = oldAsset.read(db.asset.id)!;
            await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
                  id: Value(assetId),
                  type: Value(_assetType),
                  path: Value(assetPath),
                  updatedAt: Value(DateTime.now()),
                ));
            status = EditStatus.updated;
            id = assetId;
          } else {
            id = await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
                  type: Value(_assetType),
                  path: Value(assetPath),
                  updatedAt: Value(DateTime.now()),
                ));
            status = EditStatus.inserted;
          }
        }
      }
      ok = true;
    } catch (e) {
      logger.e("_submitForm: $e");
      if (mounted) showSnackBarNow(context, Text("_submitForm: $e"));
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted && Navigator.canPop(context)) {
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
          decoration: InputDecoration(
            labelText: context.loc.asset_type,
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
                decoration: InputDecoration(
                  labelText: context.loc.asset_path,
                  hintText: RuntimePlatform.isWindows
                      ? context.loc.e_g_c_path_to_v2ray_exe
                      : context.loc.e_g_path_to_v2ray,
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
          decoration: InputDecoration(
            labelText: context.loc.url,
            hintText: context
                .loc.e_g_github_v2fly_v2ray_core_v2ray_windows_64_zip_v2ray_exe,
            border: OutlineInputBorder(),
          ),
        ),
      if (_assetType == AssetType.remote)
        TextFormField(
          controller: _autoUpdateIntervalController,
          decoration: InputDecoration(
            labelText: context.loc.auto_update_interval_seconds_0_to_disable,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
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
        title: Text(context.loc.edit_asset),
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
