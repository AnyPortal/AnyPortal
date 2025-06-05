import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../platform.dart';
import '../prefs.dart';
import 'github.dart';

/// this class always extracts app since the canInstall always returns true
class AssetRemoteProtocolApp extends AssetRemoteProtocolGithub {
  AssetRemoteProtocolApp.init() {
    owner = "anyportal";
    repo = "anyportal";
    assetName = "anyportal-${Platform.operatingSystem}.zip";
    if (platform.isWindows) {
      assetName = "anyportal-windows-setup.exe";
    }
    url = "github://$owner/$repo/$assetName";
  }

  @override
  String? getOldMeta({
    TypedResult? oldAsset,
  }) {
    return prefs.getString("app.github.meta");
  }

  /// if everythings fine, record to prefs
  @override
  Future<int> postDownload(
    File downloadedFile,
    TypedResult? oldAsset,
    String newMeta,
    int autoUpdateInterval,
  ) async {
    String assetPath = downloadedFile.path;
    if (assetPath.toLowerCase().endsWith(".zip") && subPath != null) {
      assetPath = assetPath.substring(0, assetPath.length - 4);
      final subPathList = subPath!.split('/');
      assetPath = File(p.joinAll([assetPath, ...subPathList])).path;
    }

    prefs.setString("app.github.downloadedFilePath", assetPath);

    final createdAt =
        (jsonDecode(newMeta) as Map<String, dynamic>)["created_at"];
    prefs.setString("app.github.meta", "{\"created_at\": \"$createdAt}\"");
    return 0;
  }

  @override
  bool canInstallNow(TypedResult? oldAsset) {
    return false;
  }

  @override
  Future<bool> install(File downloadedFile) async {
    await Process.run(
      downloadedFile.path,
      [],
      runInShell: true,
    );
    return true;
  }
}
