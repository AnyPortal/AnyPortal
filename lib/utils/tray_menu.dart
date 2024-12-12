import 'dart:async';
import 'dart:io';

import 'package:anyportal/utils/logger.dart';
import 'package:tray_manager/tray_manager.dart';

import 'global.dart';
import 'platform_system_proxy_user.dart';
import 'prefs.dart';
import 'vpn_manager.dart';

class TrayMenuManager {
  bool isSystemProxy = false;

  Menu menu = Menu();

  Future<void> init() async {
    logger.d("starting: TrayMenuManager.init");
    if (Platform.isWindows) {
      await trayManager.setIcon('windows/runner/resources/app_icon.ico');
    } else if (Platform.isMacOS) {
      await trayManager.setIcon('assets/icon/icon_k.png', isTemplate: true);
    } else {
      await trayManager.setIcon('assets/icon/icon.png');
    }

    await updateContextMenu();
    _completer.complete(); // Signal that initialization is complete
    logger.d("started: TrayMenuManager.init");
  }

  static final TrayMenuManager _instance = TrayMenuManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  TrayMenuManager._internal();

  // Singleton accessor
  factory TrayMenuManager() {
    return _instance;
  }

  updateContextMenu() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return;
    }
    final systemProxyIsEnabled = await platformSystemProxyUser.isEnabled();
    final systemProxyShouldEnable = prefs.getBool('systemProxy')!;
    menu = Menu(
      items: [
        MenuItem.checkbox(
          key: 'toggle_all',
          label: 'Connect',
          checked: await vPNMan.getIsCoreActive(),
        ),
        MenuItem.separator(),
        MenuItem.checkbox(
          disabled: systemProxyIsEnabled == null,
          key: 'toggle_system_proxy',
          label: 'System proxy',
          checked: systemProxyShouldEnable,
        ),
        MenuItem.checkbox(
          disabled: global.isElevated == false,
          key: 'toggle_tun',
          label: 'Tun',
          checked: prefs.getBool("tun"),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'Exit',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
}

final trayMenu = TrayMenuManager();
