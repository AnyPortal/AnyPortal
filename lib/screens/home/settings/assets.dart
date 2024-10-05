import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

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
  String toShortString(context) {
    switch (this) {
      case AssetsAction.addAsset:
        return AppLocalizations.of(context)!.addAsset;
    }
  }
}

enum AssetAction {
  delete,
  edit,
}

enum AssetTypeAction {
  delete,
  edit,
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
    final assets = await db.select(db.asset).join([
      leftOuterJoin(
          db.assetRemote, db.asset.id.equalsExp(db.assetRemote.assetId)),
    ]).get();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Stack(children: [
            Text(AppLocalizations.of(context)!.assets),
            Align(
                alignment: Alignment.topRight,
                child: SmoothHighlight(
                    enabled: _highlightAssetsPopupMenuButton,
                    color: Colors.grey,
                    child: PopupMenuButton(
                      itemBuilder: (context) => AssetsAction.values
                          .map((action) => PopupMenuItem(
                                value: action,
                                child: Text(action.toShortString(context)),
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
              title: Text(asset.read(db.asset.path)!),
              subtitle: Text(asset.read(db.asset.updatedAt).toString()),
              trailing: PopupMenuButton<AssetAction>(
                        onSelected: (value) =>
                            handleAssetAction(asset, value),
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
