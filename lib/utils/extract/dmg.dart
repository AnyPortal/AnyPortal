import 'dart:io';

import 'package:path/path.dart' as p;

import '../logger.dart';

Future<bool> extractDmgThere(String path, String subpath) async {
  return await extractFolderFromDmg(path, subpath, p.withoutExtension(path));
}

Future<bool> extractFolderFromDmg(
    String dmgPath, String folderName, String outputPath) async {
  // Step 1: Attach the DMG
  var result = await Process.run('hdiutil', ['attach', dmgPath]);
  if (result.exitCode != 0) {
    logger.d('Failed to mount DMG: ${result.stderr}');
    return false;
  }

  // Parse the mount path
  String? mountPoint;
  for (var line in result.stdout.toString().split('\n')) {
    if (line.contains('/Volumes/')) {
      mountPoint = line.split('\t').last.trim();
      break;
    }
  }

  if (mountPoint == null) {
    logger.d('Failed to find mount point');
    return false;
  }

  // Step 2: Copy the folder
  var copyResult =
      await Process.run('cp', ['-R', '$mountPoint/$folderName', outputPath]);
  if (copyResult.exitCode != 0) {
    logger.d('Failed to extract folder: ${copyResult.stderr}');
    return false;
  } else {
    logger.d('Folder extracted to: $outputPath');
  }

  // Step 3: Detach the DMG
  await Process.run('hdiutil', ['detach', mountPoint]);
  return true;
}

void main() async {
  await extractFolderFromDmg(
      '/path/to/file.dmg', 'FolderName', '/desired/output/path');
}
