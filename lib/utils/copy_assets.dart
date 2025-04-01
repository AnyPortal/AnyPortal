import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'global.dart';
import 'logger.dart';

Future<void> copyAssetsToDefaultLocation() async {
  // For default location, you can use path_provider to get a suitable directory
  String src = "assets/conf/tun.sing_box.example.json";
  String dst = p.join(global.applicationDocumentsDirectory.path, "AnyPortal", "conf", "tun.sing_box.example.json");

  await copyAssetIfDifferent(src, dst);
}

Future<void> copyAssetIfDifferent(String src, String dst) async {
  // Get the bytes of the asset file
  final byteData = await rootBundle.load(src);
  final assetBytes = byteData.buffer.asUint8List();

  final dstFile = File(dst);

  if (await dstFile.exists()) {
    // Read existing file
    final existingBytes = await dstFile.readAsBytes();
    final assetHash = sha256.convert(assetBytes);
    final existingHash = sha256.convert(existingBytes);

    // Compare hashes, overwrite if different
    if (existingHash == assetHash) {
      logger.d('File already exists and is the same, skipping copy.');
      return;
    }
  }

  // Write the new file
  await dstFile.writeAsBytes(assetBytes, flush: true);
  logger.i('File copied: ${dstFile.path}');
}
