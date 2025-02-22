import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'logger.dart';
// ...
// Use an InputFileStream to access the zip file without storing it in memory.

Future<bool> extractAsFolder(String path) async {
  return await extractTo(path, p.withoutExtension(path));
}

Future<bool> extractTo(String path, String destDir) async {
  if (await File(destDir).exists()){
    try {
      File(destDir).delete(recursive: true);
    } catch (e) {
      logger.e("failed to delete $destDir");
      return false;
    }
  }

  // Read the Zip file from disk.
  final bytes = File(path).readAsBytesSync();

  // Decode the Zip file.
  final archive = ZipDecoder().decodeBytes(bytes);

  // Extract the contents of the Zip archive.
  for (final file in archive) {
    final filename = file.name;
    final dest = p.join(destDir, filename);
    if (file.isFile) {
      final data = file.content as List<int>;
      File(dest)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(dest).createSync(recursive: true);
    }
  }

  return true;
}