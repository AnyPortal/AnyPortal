import 'dart:io';
import 'dart:async';

import 'package:fv2ray/models/log_level.dart';
import 'package:fv2ray/models/send_through_binding_stratagy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_with_defaults.dart';

class PrefsManager {
  Map<String, dynamic> defaults = {
    // 'core.path',
    // 'core.assetPath',
    // 'app.selectedProfileId': 1,
    'app.connectAtLaunch': true,
    'app.window.size.width': 1280.0,
    'app.window.size.height': 720.0,
    'app.window.isMaximized': false,
    'core.useEmbedded': Platform.isAndroid || Platform.isIOS,
    'inject.api': true,
    'inject.api.port': 15490,
    'inject.log': true,
    'inject.log.level': LogLevel.warning.index,
    'inject.socks': Platform.isAndroid || Platform.isIOS,
    'inject.socks.port': 15491,
    'inject.sendThrough': false,
    'inject.sendThrough.bindingInterface': "eth0",
    'inject.sendThrough.bindingIp': "0.0.0.0",
    'inject.sendThrough.bindingStratagy': SendThroughBindingStratagy.ip.index,
    'tun': Platform.isAndroid || Platform.isIOS,
    'tun.perAppProxy': false,
    'tun.selectedApps': "[]",
    'tun.socks.address': "127.0.0.1",
    'tun.socks.port': 15491,
    'tun.socks.username': "",
    'tun.socks.password': "",
    'tun.dns.ipv4': "1.1.1.1",
    'tun.dns.ipv6': "2606:4700:4700::1111",
    'tun.ipv4': true,
    'tun.ipv6': false,
  };

  static final PrefsManager _instance = PrefsManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  PrefsManager._internal();

  // Singleton accessor
  factory PrefsManager() {
    return _instance;
  }

  late final SharedPreferencesWithDefaults _prefs;

  // Async initializer (call once at app startup)
  Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    _prefs = SharedPreferencesWithDefaults(sharedPreferences, defaults);
    _completer.complete(); // Signal that initialization is complete
  }
}

final prefs = PrefsManager()._prefs;
