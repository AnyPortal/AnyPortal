// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../logger.dart';
import '../platform_file_mananger.dart';
import '../prefs.dart';
import '../runtime_platform.dart';
import '../vpn_manager.dart';

import 'github.dart';

/// only windows, android
class AssetRemoteProtocolApp extends AssetRemoteProtocolGithub {
  Future<bool> init() async {
    bool ok = true;
    owner = "anyportal";
    repo = "anyportal";
    assetName = "anyportal-${Platform.operatingSystem}.zip";
    if (RuntimePlatform.isWindows &&
        File(p.join(
          File(Platform.resolvedExecutable).parent.path,
          "unins000.exe", // created by inno setup
        )).existsSync()) {
      assetName = "anyportal-windows-setup.exe";
    }
    if (RuntimePlatform.isAndroid) {
      ok = await updateAssetNameAndroid();
    }
    url = "github://$owner/$repo/$assetName";
    return ok;
  }

  /// return update success
  Future<bool> updateAssetNameAndroid() async {
    final platform = MethodChannel('com.github.anyportal.anyportal');
    final abis = await platform.invokeMethod<List<Object?>>('os.abis');
    if (abis == null || abis.isEmpty) return false;
    String abi = abis[0] as String;
    final targetSdkVersion =
        await platform.invokeMethod<int>('app.targetSdkVersion');
    if (targetSdkVersion == null) return false;
    String targetSdkVersionString = targetSdkVersion == 28 ? "28" : "latest";
    assetName = "anyportal-android-api$targetSdkVersionString-$abi.apk";
    return true;
  }

  @override
  String? getOldMeta({
    TypedResult? oldAsset,
  }) {
    return prefs.getString("app.github.meta");
  }

  @override
  String? getDownloadedFilePath({TypedResult? oldAsset}) {
    return prefs.getString("app.github.downloadedFilePath");
  }

  @override
  Future<void> postGetNewMeta(String newMeta, {TypedResult? oldAsset}) async {
    prefs.setInt("app.autoUpdate.checkedAt",
        (DateTime.now().millisecondsSinceEpoch / 1000).toInt());
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

    final newMetaObj = jsonDecode(newMeta) as Map<String, dynamic>;
    final createdAt = newMetaObj["created_at"];
    final tagName = newMetaObj["tag_name"];
    prefs.setString(
      "app.github.meta",
      '{"created_at": "$createdAt", "tag_name": "$tagName"}',
    );
    return 0;
  }

  @override
  Future<bool> install(File downloadedFile) async {
    if (RuntimePlatform.isWindows) {
      await Process.start(
        downloadedFile.path,
        [],
        runInShell: true,
      );
      return true;
    } else if (RuntimePlatform.isAndroid) {
      try {
        final platform = MethodChannel('com.github.anyportal.anyportal');
        await platform
            .invokeMethod('os.installApk', {'path': downloadedFile.path});
        return true;
      } on PlatformException catch (e) {
        logger.e("Failed to install APK: '${e.message}'.");
        return false;
      }
    } else {
      PlatformFileMananger.highlightFileInFolder(downloadedFile.path);
      return true;
    }
  }

  @override
  Future<bool> update({
    TypedResult? oldAsset,
    int autoUpdateInterval = 0,
    bool shouldInstall = false,
  }) async {
    /// check if need to update
    loggerD("to update: $url");
    final newMeta = await getNewMeta(useSocks: vPNMan.isCoreActive);
    if (newMeta == null) {
      loggerD("failed to get meta: $url");
      return true;
    }
    await postGetNewMeta(newMeta);

    final newMetaObj = jsonDecode(newMeta) as Map<String, dynamic>;
    final newTagName = newMetaObj["tag_name"] as String;
    final newBuildNumber = int.parse(newTagName.split("+").last);
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = int.parse(packageInfo.buildNumber);
    final isAppUpdated = newBuildNumber <= buildNumber;

    /// if app updated, must have downloaded (could be deleted)
    /// check if installed by checking downloadedFilePath
    String? downloadedFilePath = getDownloadedFilePath();
    File? downloadedFile;
    if (isAppUpdated) {
      if (downloadedFilePath != null) {
        loggerD("upgraded to: $newTagName");
        prefs.remove("app.github.downloadedFilePath");
        return true;
      } else {
        loggerD("already up to date: $url");
        return true;
      }
    } else {
      /// get download url
      loggerD("need download: $url");
      final downloadUrl = getDownloadUrl(newMeta);
      if (downloadUrl == null) {
        loggerD("downloadUrl == null: $url");
        return true;
      }

      /// download
      loggerD("downloading: $downloadUrl");
      downloadedFile = await download(
        downloadUrl,
        useSocks: vPNMan.isCoreActive,
      );
      if (downloadedFile == null) {
        loggerD("download failed: $downloadUrl");
        return false;
      }
      loggerD("downloaded: $downloadUrl");

      /// record newMeta after download
      await postDownload(
        downloadedFile,
        oldAsset,
        newMeta,
        autoUpdateInterval,
      );
    }

    if (shouldInstall) {
      /// install only if not using
      loggerD("to install: $url");
      final isInstalling = await install(downloadedFile);
      if (isInstalling) {
        loggerD("installing: $url");
      } else {
        loggerD("install failed: $url");
      }
    } else {
      loggerD("pending install: $url");
    }
    return true;
  }
}
