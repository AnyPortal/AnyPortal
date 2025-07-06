import 'dart:async';

import 'package:anyportal/utils/core/base/config_injector.dart';
import 'package:anyportal/utils/core/base/data_notifier.dart';
import 'package:anyportal/utils/core/clash/plugin.dart';
import 'package:anyportal/utils/core/sing_box/plugin.dart';
import 'package:anyportal/utils/core/v2ray/plugin.dart';

import '../../logger.dart';
import '../hysteria2/plugin.dart';

class CorePluginBase {
  static Map<String, CorePluginBase> implementations = {};
  String? coreTypeName;
  bool isToLogStdout = false;
  Map<String, String> environment = {};

  CorePluginBase() {
    register();
  }

  void register() {
    if (coreTypeName != null) {
      implementations[coreTypeName!] = this;
    }
  }

  CoreDataNotifierBase dataNotifier = CoreDataNotifierBase();
  ConfigInjectorBase configInjector = ConfigInjectorBase();
}

class CorePluginManager {
  static final CorePluginManager _instance = CorePluginManager._internal();
  final Completer<void> _completer = Completer<void>();
  late CorePluginBase instance;
  static Map<String, CorePluginBase> instances = {};
  // Private constructor
  CorePluginManager._internal();

  // Singleton accessor
  factory CorePluginManager() {
    return _instance;
  }

  // Async initializer (call once at app startup)
  Future<void> init() async {
    logger.d("starting: CorePluginManager.init");
    instance = CorePluginBase();
    CorePluginV2Ray();
    CorePluginSingBox();
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: CorePluginManager.init");
  }

  void switchTo(String coreTypeName) {
    if (instances.containsKey(coreTypeName)) {
      instance = instances[coreTypeName]!;
    } else {
      switch (coreTypeName) {
        case "v2ray":
        case "xray":
          instance = CorePluginV2Ray();
          instances[coreTypeName] = instance;
          break;
        case "sing-box":
          instance = CorePluginSingBox();
          instances[coreTypeName] = instance;
          break;
        case "hysteria2":
          instance = CorePluginHysteria2();
          instances[coreTypeName] = instance;
          break;
        case "clash":
        case "mihomo":
          instance = CorePluginClash();
          instances[coreTypeName] = instance;
          break;
      }
    }
  }
}
