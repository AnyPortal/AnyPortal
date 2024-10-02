import 'dart:io';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:tray_manager/tray_manager.dart';

Future<void> initSystemTray() async {
  if (Platform.isWindows) {
    await trayManager.setIcon('windows/runner/resources/app_icon.ico');
  } else if (Platform.isMacOS) {
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    if (dispatcher.platformBrightness == Brightness.dark) {
      await trayManager.setIcon('assets/icon/icon_k.png');
    } else {
      await trayManager.setIcon('assets/icon/icon_w.png');
    }
  } else {
    await trayManager.setIcon('assets/icon/icon.png');
  }

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
