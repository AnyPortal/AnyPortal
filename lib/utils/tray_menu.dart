import 'dart:async';

import 'package:tray_manager/tray_manager.dart';

import '../extensions/localization.dart';

import 'global.dart';
import 'logger.dart';
import 'platform_system_proxy_user.dart';
import 'prefs.dart';
import 'runtime_platform.dart';
import 'vpn_manager.dart';

class TrayMenuManager {
  bool isSystemProxy = false;

  Menu menu = Menu();

  Future<void> init() async {
    logger.d("starting: TrayMenuManager.init");
    if (RuntimePlatform.isWindows) {
      await trayManager.setIcon('windows/runner/resources/app_icon.ico');
    } else if (RuntimePlatform.isMacOS) {
      await trayManager.setIcon('assets/icon/icon_k.png', isTemplate: true);
    } else {
      await trayManager.setIcon('assets/icon/icon.png');
    }

    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: TrayMenuManager.init");
  }

  static final TrayMenuManager _instance = TrayMenuManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  TrayMenuManager._internal();

  // Singleton accessor
  factory TrayMenuManager() {
    return _instance;
  }

  Future<void> updateContextMenu() async {
    if (RuntimePlatform.isAndroid || RuntimePlatform.isIOS) {
      return;
    }

    final systemProxyIsEnabled = await platformSystemProxyUser.isEnabled();
    final systemProxyShouldEnable = prefs.getBool('systemProxy')!;
    final systemProxyErr =
        systemProxyShouldEnable && systemProxyIsEnabled == false;

    final tunIsEnabled = vPNMan.isTunActive;
    final tunShouldEnable = prefs.getBool('tun')!;
    final tunErr = tunShouldEnable && !tunIsEnabled;

    final context = global.navigatorKey.currentContext;
    if (context == null) {
      logger.e("updateContextMenu: context == null");
      return;
    } else if (!context.mounted) {
      logger.e("updateContextMenu: context not mounted");
      return;
    } else {
      final loc = context.loc;
      String systemProxyItem = loc.system_proxy;
      if (systemProxyErr) {
        systemProxyItem += ' (!)';
      }

      String tunItem = 'Tun';
      if (tunErr) {
        tunItem += ' (!)';
      }
      menu = Menu(
        items: [
          MenuItem.checkbox(
            key: 'toggle_all',
            label: loc.connect,
            checked: await vPNMan.getIsCoreActive(),
          ),
          MenuItem.separator(),
          MenuItem.checkbox(
            disabled: systemProxyIsEnabled == null,
            key: 'toggle_system_proxy',
            label: systemProxyItem,
            checked: systemProxyShouldEnable,
          ),
          MenuItem.checkbox(
            disabled: global.isElevated == false,
            key: 'toggle_tun',
            label: tunItem,
            checked: prefs.getBool("tun"),
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit',
            label: loc.exit,
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
    }
  }
}

final trayMenu = TrayMenuManager();
