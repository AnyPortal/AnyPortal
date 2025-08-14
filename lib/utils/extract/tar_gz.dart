import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../logger.dart';

Future<bool> extractTarGzThere(String path) async {
  return await extractTarGz(path, p.withoutExtension(p.withoutExtension(path)));
}

Future<bool> extractTarGz(String path, String destDir) async {
  final d = Directory(destDir);
  if (await d.exists()) {
    try {
      await d.delete(recursive: true);
    } catch (e) {
      logger.e("failed to delete $destDir");
      return false;
    }
  }

  final input = File(path);
  final bytes = await input.readAsBytes();

  // Decode GZip first
  final gzipDecoder = GZipDecoder();
  final tarData = gzipDecoder.decodeBytes(bytes);

  // Then decode the TAR
  final tarArchive = TarDecoder().decodeBytes(tarData);

  for (final file in tarArchive.files) {
    final filename = p.join(destDir, file.name);

    if (file.isFile) {
      final outFile = File(filename);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    } else {
      // It's a directory
      await Directory(filename).create(recursive: true);
    }
  }

  return true;
}
