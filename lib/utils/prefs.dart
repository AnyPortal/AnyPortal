import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/log_level.dart';
import '../models/send_through_binding_stratagy.dart';

import 'logger.dart';
import 'runtime_platform.dart';
import 'shared_preferences_with_defaults.dart';

class PrefsManager {
  Map<String, dynamic> defaults = {
    // 'app.selectedProfileId': 1,
    'app.autoUpdate': false,
    'app.autoUpdate.checkedAt': 0,
    'app.brightness.dark': true,
    'app.brightness.dark.black': false,
    'app.brightness.followSystem': true,
    'app.dashboard.floatingActionButton': true,
    'app.locale.followSystem': true,
    'app.locale': "en_US",
    'app.connectAtLaunch': RuntimePlatform.isWindows ||
        RuntimePlatform.isLinux ||
        RuntimePlatform.isMacOS,
    'app.connectAtStartup': false,
    // 'app.github.downloadedFilePath': null,
    // 'app.github.meta': '{"tag_name":"v0.0.1+1"}'
    'app.github.meta': '{}',
    // 'app.github.token': "",
    'app.http.port': 15492,
    'app.notification.foreground': RuntimePlatform.isAndroid,
    'app.window.size.width': 1280.0,
    'app.window.size.height': 720.0,
    'app.window.isMaximized': false,
    'app.window.closeToTray': RuntimePlatform.isWindows ||
        RuntimePlatform.isLinux ||
        RuntimePlatform.isMacOS,
    'app.runElevated': false,
    'app.server.address': "127.0.0.1",
    'app.socks.port': 15491,
    'inject.api': true,
    'inject.api.port': 15490,
    'inject.dns.local': false,
    'inject.log': true,
    'inject.log.level': LogLevel.warning.index,
    'inject.socks': true,
    'inject.http': true,
    'inject.sendThrough': false,
    'inject.sendThrough.bindingInterface': "eth0",
    'inject.sendThrough.bindingIp': "0.0.0.0",
    'inject.sendThrough.bindingStratagy': SendThroughBindingStratagy.ip.index,
    'systemProxy': false,
    'tun': RuntimePlatform.isAndroid || RuntimePlatform.isIOS,
    'tun.perAppProxy': false,
    'tun.socks.username': "",
    'tun.socks.password': "",
    'tun.dns.ipv4': "1.1.1.1",
    'tun.dns.ipv6': "2606:4700:4700::1111",
    'tun.ipv4': true,
    'tun.ipv6': false,
    'tun.inject.log': true,
    'tun.inject.log.level': LogLevel.warning.index,
    'tun.inject.http': true,
    'tun.inject.socks': true,
    'tun.inject.excludeCorePath': RuntimePlatform.isWindows ||
        RuntimePlatform.isLinux ||
        RuntimePlatform.isMacOS,
    'tun.useEmbedded': RuntimePlatform.isAndroid || RuntimePlatform.isIOS,

    'android.tun.perAppProxy.allowed': true,
    'android.tun.allowedApplications': "[]",
    'android.tun.disallowedApplications': "[]",
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
    logger.d("starting: PrefsManager.init");
    final sharedPreferences = await SharedPreferences.getInstance();
    _prefs = SharedPreferencesWithDefaults(sharedPreferences, defaults);
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: PrefsManager.init");
  }
}

final prefs = PrefsManager()._prefs;
