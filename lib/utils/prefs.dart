import 'dart:io';
import 'dart:async';

import 'package:fv2ray/models/log_level.dart';
import 'package:fv2ray/models/send_through_binding_stratagy.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PrefsManager {
  static final PrefsManager _instance = PrefsManager._internal();
  late final SharedPreferences _prefs;
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  PrefsManager._internal();

  // Singleton accessor
  factory PrefsManager() {
    return _instance;
  }

  // Async initializer (call once at app startup)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    initDefaults();
    _completer.complete(); // Signal that initialization is complete
  }

    void set(String key, dynamic value){
    if (value == null){
      _prefs.remove(key);
    } else if (value is bool){
      _prefs.setBool(key, value);
    } else if (value is double){
      _prefs.setDouble(key, value);
    } else if (value is int){
      _prefs.setInt(key, value);
    } else if (value is String){
      _prefs.setString(key, value);
    } else if (value is List<String>){
      _prefs.setStringList(key, value);
    } 
  }

  dynamic get(String key){
    return _prefs.get(key);
  }

  Map<String, dynamic> defaults = {
    // 'core.path',
    // 'core.assetPath',
    // 'app.selectedProfileId': 1,
    'app.connectAtLaunch': true,
    'core.useEmbedded': Platform.isAndroid || Platform.isIOS,
    'inject.api': true,
    'inject.api.port': 15490,
    'inject.log': true,
    'inject.log.level': LogLevel.warning.index,
    'inject.socks': Platform.isAndroid || Platform.isIOS,
    'inject.socks.port': 15491,
    'tun.socks.username': "",
    'tun.socks.password': "",
    'inject.sendThrough': false,
    'inject.sendThrough.bindingInterface': "eth0",
    'inject.sendThrough.bindingIp': "0.0.0.0",
    'inject.sendThrough.bindingStratagy': SendThroughBindingStratagy.ip.index,
    'tun.perAppProxy': false,
    'tun.socks.address': "127.0.0.1",
    'tun.socks.port': 15491,
    'tun.dns.ipv4': "1.1.1.1",
    'tun.dns.ipv6': "2606:4700:4700::1111",
    'tun.ipv4': true,
    'tun.ipv6': false,
  };

  void initDefaults() {
    defaults.forEach((key, value) {
      if (_prefs.get(key) == null){
        set(key, value);
      }
    });
  }
}

final prefs = PrefsManager()._prefs;
