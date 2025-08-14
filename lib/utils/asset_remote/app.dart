// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../logger.dart';
import '../method_channel.dart';
import '../platform_file_mananger.dart';
import '../prefs.dart';
import '../runtime_platform.dart';
import '../vpn_manager.dart';

import 'github.dart';

class AssetRemoteProtocolApp extends AssetRemoteProtocolGithub {
  Future<bool> init() async {
    bool ok = true;
    owner = "anyportal";
    repo = "anyportal";
    assetName = "anyportal-${Platform.operatingSystem}.zip";
    if (RuntimePlatform.isWindows) {
      if (await File(
        p.join(
          File(Platform.resolvedExecutable).parent.path,
          "unins000.exe", // created by inno setup
        ),
      ).exists()) {
        assetName = "anyportal-windows-setup.exe";
      }
    } else if (RuntimePlatform.isMacOS) {
      assetName = "anyportal-macos.dmg";
    } else if (RuntimePlatform.isAndroid) {
      ok = await updateAssetNameAndroid();
    }
    url = "github://$owner/$repo/$assetName";
    return ok;
  }

  /// return update success
  Future<bool> updateAssetNameAndroid() async {
    final platform = mCMan.methodChannel;
    final abis = await platform.invokeMethod<List<Object?>>('os.abis');
    if (abis == null || abis.isEmpty) return false;
    String abi = abis[0] as String;
    final targetSdkVersion = await platform.invokeMethod<int>(
      'app.targetSdkVersion',
    );
    if (targetSdkVersion == null) return false;
    String targetSdkVersionString = targetSdkVersion == 28 ? "28" : "latest";
    assetName = "anyportal-android-api$targetSdkVersionString-$abi.apk";
    return true;
  }

  @override
  String? getDownloadedMeta({
    TypedResult? asset,
  }) {
    return prefs.getString("app.github.meta");
  }

  @override
  String? getDownloadedFilePath({TypedResult? asset}) {
    return prefs.getString("app.github.downloadedFilePath");
  }

  @override
  Future<void> postGetRemoteMeta(
    int assetId,
    String remoteMeta,
  ) async {
    prefs.setInt(
      "app.autoUpdate.checkedAt",
      (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
    );
  }

  /// if everythings fine, record to prefs
  /// return assetPath
  @override
  Future<void> postDownload(
    int assetId,
    File downloadedFile,
    String assetPath,
    String remoteMeta,
    int? autoUpdateInterval,
  ) async {
    prefs.setString("app.github.downloadedFilePath", downloadedFile.path);

    final remoteMetaObj = jsonDecode(remoteMeta) as Map<String, dynamic>;
    final createdAt = remoteMetaObj["created_at"];
    final tagName = remoteMetaObj["tag_name"];
    prefs.setString(
      "app.github.meta",
      '{"created_at": "$createdAt", "tag_name": "$tagName"}',
    );
    return;
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
        final platform = mCMan.methodChannel;
        await platform.invokeMethod('os.installApk', {
          'path': downloadedFile.path,
        });
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

  /// return isUpdated
  @override
  Future<bool> update({
    TypedResult? asset,
    int? autoUpdateInterval = 0,
    bool shouldCheckRemote = true,
    bool shouldInstall = false,
  }) async {
    /// check if need to update
    loggerD("to update: $url");
    final downloadedMeta = getDownloadedMeta();
    String? remoteMeta = downloadedMeta;
    if (shouldCheckRemote) {
      remoteMeta = await getRemoteMeta(useSocks: vPNMan.isCoreActive);
      if (remoteMeta == null) {
        loggerD("failed to get meta: $url");
        return true;
      }
      await postGetRemoteMeta(0, remoteMeta);
    }

    final remoteMetaObj = jsonDecode(remoteMeta!) as Map<String, dynamic>;
    final remoteTagName = remoteMetaObj["tag_name"] as String;
    final remoteBuildNumber = int.parse(remoteTagName.split("+").last);
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = int.parse(packageInfo.buildNumber);
    final isAppUpdated = remoteBuildNumber <= buildNumber;

    Map<String, dynamic> downloadedMetaObj = {};
    int downloadedBuildNumber = 0;
    try {
      downloadedMetaObj = jsonDecode(downloadedMeta!) as Map<String, dynamic>;
      final downloadedTagName = downloadedMetaObj["tag_name"] as String;
      downloadedBuildNumber = int.parse(downloadedTagName.split("+").last);
    } catch (e) {
      logger.w("jsonDecode(appGithubMeta): $e");
    }
    final isDownloadedMetaUpdated = remoteBuildNumber <= downloadedBuildNumber;

    String? downloadedFilePath = getDownloadedFilePath();
    File? downloadedFile;
    if (isAppUpdated) {
      /// if app updated, must have installed
      /// check if upgraded by checking downloadedFilePath
      if (downloadedFilePath != null) {
        loggerD("upgraded to: $remoteTagName");
        prefs.remove("app.github.downloadedFilePath");
        return true;
      } else {
        loggerD("already up to date: $url");
        return true;
      }
    } else {
      if (isDownloadedMetaUpdated && downloadedFilePath != null) {
        loggerD("already downloaded: $url");
        downloadedFile = File(downloadedFilePath);
      } else {
        /// get download url
        loggerD("need download: $url");
        final downloadUrl = getDownloadUrl(remoteMeta);
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

        /// record remoteMeta after download
        await postDownload(
          0,
          downloadedFile,
          "",
          remoteMeta,
          null,
        );
      }
    }

    if (shouldInstall) {
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
