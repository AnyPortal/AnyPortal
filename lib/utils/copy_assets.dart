import 'dart:developer';
import 'dart:io';
import 'dart:typed_data'; // For handling binary data
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

import 'global.dart'; // For system directories

Future<void> copyAssetToDesiredLocation(String assetPath, String desiredPath) async {
  try {
    // Load the asset as raw binary data
    ByteData data = await rootBundle.load(assetPath);

    // Create a Uint8List from the ByteData for writing
    Uint8List bytes = data.buffer.asUint8List();

    // Write the binary data to the desired location
    File targetFile = File(desiredPath);
    await targetFile.writeAsBytes(bytes);

    log("Asset copied successfully to: $desiredPath");
  } catch (e) {
    log("Error copying asset: $e");
  }
}

Future<void> copyAssetsToDefaultLocation({bool overwrite = false}) async {
  // For default location, you can use path_provider to get a suitable directory
  String src = "assets/conf/tun.sing_box.example.json";
  String dst = p.join(global.applicationDocumentsDirectory.path, "AnyPortal", "conf", "tun.sing_box.json");

  if (overwrite || !await File(dst).exists()) {
    await File(dst).create(recursive: true);
    await copyAssetToDesiredLocation(src, dst);
  }
}
