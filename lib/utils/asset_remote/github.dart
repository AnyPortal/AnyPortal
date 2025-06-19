// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:drift/drift.dart';
import 'package:flutter_socks_proxy/socks_proxy.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../models/asset.dart';
import '../db.dart';
import '../global.dart';
import '../logger.dart';
import '../prefs.dart';
import '../show_snack_bar_now.dart';
import '../undmg.dart';
import '../unzip.dart';
import '../vpn_manager.dart';

import 'protocol.dart';

class AssetRemoteProtocolGithub implements AssetRemoteProtocol {
  late String url;
  late String protocol = "github";
  late String owner;
  late String repo;
  late String assetName;
  String? subPath;

  AssetRemoteProtocolGithub();

  AssetRemoteProtocolGithub.fromUrl(String url) {
    final regex = RegExp(
      r'^github:\/\/([^\/]+)\/([^\/]+)\/([^\/]+)?(?:\/(.+))?$',
    );

    final match = regex.firstMatch(url);
    if (match != null) {
      this.url = url;
      owner = match.group(1)!;
      repo = match.group(2)!;
      assetName = match.group(3)!;
      subPath = match.group(4); // Nullable
    } else {
      logger.w("match failed: $url");
      throw Exception();
    }
  }

  Future<String?> getNewMeta({bool useSocks = true}) async {
    final metaUrl = "https://api.github.com/repos/$owner/$repo/releases/latest";
    if (useSocks) {
      final client = createProxyHttpClient()
        ..findProxy = (url) =>
            'SOCKS5 ${prefs.getString('app.server.address')!}:${prefs.getInt('app.socks.port')!}';
      final request = await client.getUrl(Uri.parse(metaUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        return await utf8.decodeStream(response);
      } else {
        logger.w(
            "${response.statusCode} when accessing $metaUrl. If using shared ip address/exceeding api limit consider add a github token");
        return null;
      }
    } else {
      final response = await http.get(Uri.parse(metaUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        logger.w(
            "${response.statusCode} when accessing $metaUrl. If using shared ip address/exceeding api limit consider add a github token");
        return null;
      }
    }
  }

  String? getOldMeta({
    TypedResult? oldAsset,
  }) {
    return oldAsset?.read(db.assetRemote.meta);
  }

  bool getIsMetaUpdated(
    String? newMeta,
    String? oldMeta,
  ) {
    if (newMeta == null) {
      logger.w("getIsMetaUpdated: failed to get newMeta");
      return true;
    }

    if (oldMeta == null) {
      return false;
    }

    try {
      final oldCreatedAt =
          (jsonDecode(oldMeta) as Map<String, dynamic>)["created_at"];
      final newCreatedAt =
          (jsonDecode(newMeta) as Map<String, dynamic>)["created_at"];

      return oldCreatedAt == newCreatedAt;
    } catch (e) {
      logger.w("getIsMetaUpdated: failed to read created_at");
      return false;
    }
  }

  String? getDownloadUrl(String meta) {
    /// getDownloadUrl
    final assetList = (jsonDecode(meta) as Map<String, dynamic>)["assets"];
    for (final asset in assetList) {
      final assetMap = asset as Map<String, dynamic>;
      if (assetMap["name"] == assetName) {
        return assetMap["browser_download_url"];
      }
    }
    return null;
  }

  Future<File?> download(
    String downloadUrl, {
    bool useSocks = true,
  }) async {
    /// prepare file
    final folder = global.applicationSupportDirectory;
    final file =
        File(p.join(folder.path, 'asset', 'github', owner, repo, assetName));
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        logger.w("failed to delete ${file.path}");
        return null;
      }
    }

    if (useSocks) {
      final client = createProxyHttpClient()
        ..findProxy = (url) =>
            'SOCKS5 ${prefs.getString('app.server.address')!}:${prefs.getInt('app.socks.port')!}';
      final request = await client.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      await file.create(recursive: true);
      final sink = file.openWrite();
      await response.pipe(sink);
      sink.close();
      return file;
    } else {
      final client = http.Client();
      final request = http.Request("GET", Uri.parse(downloadUrl));
      final response = await client.send(request);

      await file.create(recursive: true);
      final sink = file.openWrite();
      await response.stream.pipe(sink);
      sink.close();
      return file;
    }
  }

  /// if everythings fine, record to db
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
    late int assetId;
    await db.transaction(() async {
      if (oldAsset != null) {
        /// update old asset record
        assetId = oldAsset.read(db.assetRemote.assetId)!;
        await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
              id: Value(oldAsset.read(db.assetRemote.assetId)!),
              type: const Value(AssetType.remote),
              path: Value(assetPath),
              updatedAt: Value(DateTime.now()),
            ));
      } else {
        /// insert new asset record
        assetId = await db.into(db.asset).insertOnConflictUpdate(AssetCompanion(
              type: const Value(AssetType.remote),
              path: Value(assetPath),
              updatedAt: Value(DateTime.now()),
            ));
      }

      /// update or insert assetRemote record
      await db.into(db.assetRemote).insertOnConflictUpdate(AssetRemoteCompanion(
            assetId: Value(assetId),
            url: Value(url),
            meta: Value(newMeta),
            autoUpdateInterval: Value(autoUpdateInterval),
            downloadedFilePath: Value(downloadedFile.path),
          ));
    });

    return assetId;
  }

  /// return installOK
  Future<bool> install(
    File downloadedFile,
  ) async {
    String path = downloadedFile.path;

    bool extractOK = false;
    if (path.toLowerCase().endsWith(".zip")) {
      extractOK = await unzipThere(path);
    } else if (path.toLowerCase().endsWith(".dmg")) {
      extractOK = await undmgThere(path, subPath!);
    }
    if (extractOK) {
      try {
        downloadedFile.delete();
      } catch (e) {
        logger.e("failed to delete $path");
        return false;
      }
      return true;
    }

    return true;
  }

  /// remove downloaded file and path record
  Future<bool> postInstall(int assetId) async {
    /// remove pending install status
    await (db.update(db.assetRemote)..where((e) => e.assetId.equals(assetId)))
        .write(AssetRemoteCompanion(
      assetId: Value(assetId),
      downloadedFilePath: Value(null),
    ));

    return true;
  }

  bool canInstallNow({TypedResult? oldAsset}) {
    if (oldAsset == null) {
      return true;
    }
    final assetPath = oldAsset.read(db.asset.path);
    return !(assetPath == vPNMan.corePath && vPNMan.isCoreActive);
  }

  void logStatus(BuildContext? context, String text) {
    logger.d(text);
    if (context != null) {
      showSnackBarNow(context, Text(text));
    }
  }

  String? getDownloadedFilePath({TypedResult? oldAsset}) {
    return oldAsset?.read(db.asset.path);
  }

  /// save last checked timestamp
  Future<void> postGetNewMeta(String newMeta, {TypedResult? oldAsset}) async {
    if (oldAsset == null) return;
    final assetId = oldAsset.read(db.asset.id)!;
    await db.into(db.assetRemote).insertOnConflictUpdate(AssetRemoteCompanion(
          assetId: Value(assetId),
          checkedAt: Value(DateTime.now()),
        ));
  }

  /// return isUpdated
  @override
  Future<bool> update({
    TypedResult? oldAsset,
    int autoUpdateInterval = 0,
    BuildContext? context,
  }) async {
    /// check if need to update
    logStatus(context, "to update: $url");
    final oldMeta = getOldMeta(oldAsset: oldAsset);
    final newMeta = await getNewMeta(useSocks: vPNMan.isCoreActive);
    if (newMeta == null) {
      logStatus(context, "failed to get meta: $url");
      return true;
    }
    await postGetNewMeta(newMeta, oldAsset: oldAsset);
    final isMetaUpdated = getIsMetaUpdated(newMeta, oldMeta);

    /// if meta updated, must have downloaded (could be deleted)
    /// check if installed by checking downloadedFilePath
    int? assetId = oldAsset?.read(db.asset.id);
    String? downloadedFilePath = getDownloadedFilePath(oldAsset: oldAsset);
    File? downloadedFile;
    if (isMetaUpdated) {
      if (downloadedFilePath != null) {
        logStatus(context, "already downloaded: $url");
        downloadedFile = File(downloadedFilePath);
      } else {
        logStatus(context, "already up to date: $url");
        return true;
      }
    } else {
      /// get download url
      logStatus(context, "need download: $url");
      final downloadUrl = getDownloadUrl(newMeta);
      if (downloadUrl == null) {
        logStatus(context, "downloadUrl == null: $url");
        return true;
      }

      /// download
      logStatus(context, "downloading: $downloadUrl");
      downloadedFile = await download(
        downloadUrl,
        useSocks: vPNMan.isCoreActive,
      );
      if (downloadedFile == null) {
        logStatus(context, "download failed: $downloadUrl");
        return false;
      }
      logStatus(context, "downloaded: $downloadUrl");

      /// record newMeta after download
      assetId = await postDownload(
        downloadedFile,
        oldAsset,
        newMeta,
        autoUpdateInterval,
      );
    }

    if (canInstallNow(oldAsset: oldAsset)) {
      /// install only if not using
      logStatus(context, "installing: $url");
      final installOk = await install(downloadedFile);
      if (installOk) {
        await postInstall(assetId!);
        logStatus(context, "installed: $url");
      } else {
        logStatus(context, "install failed: $url");
      }
    } else {
      logStatus(context, "pending install: $url");
    }
    return true;
  }
}
