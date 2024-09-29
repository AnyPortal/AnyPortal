import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

Future<void> initSystemTray() async {
  await trayManager.setIcon(
  Platform.isWindows
    ? 'windows/runner/resources/app_icon.ico'
    : 'assets/icon/icon.png',
  );
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'exit',
        label: 'Exit',
      ),
    ],
  );
  await trayManager.setContextMenu(menu);
}