import 'dart:io';

import 'package:flutter/material.dart';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:anyportal/utils/asset_remote/github.dart';
import 'package:anyportal/utils/runtime_platform.dart';

import '../../../extensions/localization.dart';
import '../../../models/asset.dart';
import '../../../screens/asset.dart';
import '../../../utils/db.dart';
import '../../../utils/logger.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({
    super.key,
  });

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

enum AssetsAction {
  addAsset,
}

extension AssetsActionX on AssetsAction {
  String localized(BuildContext context) {
    switch (this) {
      case AssetsAction.addAsset:
        return context.loc.add_asset;
    }
  }
}

enum AssetAction {
  edit,
  delete,
}

extension AssetActionX on AssetAction {
  String localized(BuildContext context) {
    switch (this) {
      case AssetAction.edit:
        return context.loc.edit;
      case AssetAction.delete:
        return context.loc.delete;
    }
  }
}

class _AssetsScreenState extends State<AssetsScreen> {
  var _highlightAssetsPopupMenuButton = false;

  void setHighlightAssetsPopupMenuButton() async {
    for (var i = 0; i < 5; ++i) {
      if (mounted) {
        setState(() {
          _highlightAssetsPopupMenuButton = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        return;
      }
    }
  }

  List<TypedResult> _assets = [];

  Future<void> _loadAssets() async {
    final assets = await (db.select(db.asset).join([
      leftOuterJoin(
          db.assetRemote, db.asset.id.equalsExp(db.assetRemote.assetId)),
    ])
          ..orderBy([OrderingTerm.asc(db.asset.path)]))
        .get();

    if (assets.isEmpty) {
      setHighlightAssetsPopupMenuButton();
    }

    if (mounted) {
      setState(() {
        _assets = assets;
      });
    }
  }

  void _addAsset() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssetScreen()),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadAssets();
      }
    });
  }

  void _editAsset(TypedResult asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AssetScreen(
                asset: asset,
              )),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadAssets();
      }
    });
  }

  void handleAssetsAction(AssetsAction action) {
    switch (action) {
      case AssetsAction.addAsset:
        _addAsset();
    }
  }

  /// Deletes the timestamp folder inside the file_picker cache for a given picked file path.
  Future<void> deleteFilePickerAsset(TypedResult asset) async {
    final path = asset.read(db.asset.path)!;
    final file = File(path);
    if (!await file.exists()) {
      logger.d('File does not exist: $path');
      return;
    }

    final fileDir = file.parent;
    final filePickerDirName =
        fileDir.parent.path.split(Platform.pathSeparator).last;

    /// Ensure it's inside the file_picker cache directory and matches expected structure
    if (filePickerDirName != 'file_picker') {
      logger.d('File is not inside file_picker folder');
      return;
    }

    if (await fileDir.exists()) {
      try {
        await fileDir.delete(recursive: true);
        logger.d('Deleted folder: ${fileDir.path}');
      } catch (e) {
        logger.d('Failed to delete folder: $e');
      }
    } else {
      logger.d('Timestamp folder does not exist: ${fileDir.path}');
    }
  }

  Future<void> deleteAssetRemoteProtocolGithub(TypedResult asset) async {
    final assetRemoteProtocolGithub = AssetRemoteProtocolGithub.fromUrl(
      asset.read(db.assetRemote.url)!,
    );
    final assetName = assetRemoteProtocolGithub.assetName;
    final file = assetRemoteProtocolGithub.getAssetFile();
    if (assetName.toLowerCase().endsWith(".zip")) {
      final fileDirPath = p.withoutExtension(file.path);
      final fileDir = Directory(fileDirPath);
      if (await fileDir.exists()) {
        try {
          await fileDir.delete(recursive: true);
          logger.d('Deleted folder: ${fileDir.path}');
        } catch (e) {
          logger.d('Failed to delete folder: $e');
        }
      } else {
        logger.d('Unzipped folder does not exist: ${fileDir.path}');
      }
    }
    if (assetName.toLowerCase().endsWith("tar.gz")) {
      final fileDirPath = p.withoutExtension(p.withoutExtension(file.path));
      final fileDir = Directory(fileDirPath);
      if (await fileDir.exists()) {
        try {
          await fileDir.delete(recursive: true);
          logger.d('Deleted folder: ${fileDir.path}');
        } catch (e) {
          logger.d('Failed to delete folder: $e');
        }
      } else {
        logger.d('Unzipped folder does not exist: ${fileDir.path}');
      }
    } else {
      try {
        await file.delete();
        logger.d('Deleted file: ${file.path}');
      } catch (e) {
        logger.d('Failed to delete file: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  void handleAssetAction(TypedResult asset, AssetAction action) async {
    switch (action) {
      case AssetAction.delete:
        if (RuntimePlatform.isAndroid) {
          await deleteFilePickerAsset(asset);
        }
        if (asset.readWithConverter(db.asset.type) == AssetType.remote) {
          await deleteAssetRemoteProtocolGithub(asset);
        }
        await (db.delete(db.asset)
              ..where((e) => e.id.equals(asset.read(db.asset.id)!)))
            .go();
        _loadAssets();
      case AssetAction.edit:
        _editAsset(asset);
    }
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
    return Scaffold(
        appBar: AppBar(
          title: Text(context.loc.assets),
          actions: [
            SmoothHighlight(
              enabled: _highlightAssetsPopupMenuButton,
              color: Colors.grey,
              child: PopupMenuButton(
                itemBuilder: (context) => AssetsAction.values
                    .map((action) => PopupMenuItem(
                          value: action,
                          child: Text(action.localized(context)),
                        ))
                    .toList(),
                onSelected: (value) => handleAssetsAction(value),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _assets.length,
          itemBuilder: (context, index) {
            final asset = _assets[index];
            return ListTile(
              title: Text(getAssetTitle(asset)),
              subtitle: Text(asset.read(db.asset.updatedAt).toString()),
              trailing: PopupMenuButton<AssetAction>(
                onSelected: (value) => handleAssetAction(asset, value),
                itemBuilder: (context) => AssetAction.values
                    .map((action) => PopupMenuItem(
                          value: action,
                          child: Text(action.localized(context)),
                        ))
                    .toList(),
              ),
            );
          },
        ));
  }
}
