import 'dart:io';
import 'global.dart';
import 'package:path/path.dart' as p;

import 'logger.dart';

Future<void> updateLinuxIcon() async {
  final execPath = Platform.resolvedExecutable;
  final iconPath = p.join(Platform.resolvedExecutable,
      "../data/flutter_assets/assets/icon/icon.png");
  final desktopStr = """[Desktop Entry]
Version=1.0
Type=Application
Name=anyportal
Exec=$execPath
Icon=$iconPath
Terminal=false
StartupNotify=true;
""";
  final desktopPath = global.isElevated
      ? "/usr/share/applications/anyportal.desktop"
      : "~/.local/share/applications/anyportal.desktop";
  final desktopFile = File(desktopPath);

  if (await desktopFile.exists()) {
    final existingStr = await desktopFile.readAsString();

    if (existingStr == desktopStr) {
      logger.d('desktop file is already updated');
      return;
    }
  } else {
    await desktopFile.create(recursive: true);
  }

  // Write the new file
  await desktopFile.writeAsString(desktopStr, flush: true);
  logger.i('desktop file updated: $desktopPath');
}
