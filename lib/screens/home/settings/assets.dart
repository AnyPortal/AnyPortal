import 'package:flutter/material.dart';

import 'package:drift/drift.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:anyportal/extensions/localization.dart';
import '../../../models/asset.dart';
import '../../../screens/asset.dart';
import '../../../utils/db.dart';

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

extension ToLCString on AssetsAction {
  String toLCString(context) {
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

enum AssetTypeAction {
  edit,
  delete,
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

  void handleAssetsAction(action) {
    switch (action) {
      case AssetsAction.addAsset:
        _addAsset();
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
          title: Stack(children: [
            Text(context.loc.assets),
            Align(
                alignment: Alignment.topRight,
                child: SmoothHighlight(
                    enabled: _highlightAssetsPopupMenuButton,
                    color: Colors.grey,
                    child: PopupMenuButton(
                      itemBuilder: (context) => AssetsAction.values
                          .map((action) => PopupMenuItem(
                                value: action,
                                child: Text(action.toLCString(context)),
                              ))
                          .toList(),
                      onSelected: (value) => handleAssetsAction(value),
                    )))
          ]),
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
                          child: Text(action.name),
                        ))
                    .toList(),
              ),
            );
          },
        ));
  }
}
