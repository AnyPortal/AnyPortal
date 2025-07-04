import 'dart:async';

import 'package:anyportal/utils/core/base/data_notifier.dart';
import 'package:anyportal/utils/core/sing_box/plugin.dart';
import 'package:anyportal/utils/core/v2ray/plugin.dart';

import '../../logger.dart';

class CorePluginBase {
  static Map<String, CorePluginBase> implementations = {};
  String? coreTypeName;

  CorePluginBase() {
    register();
  }

  void register() {
    if (coreTypeName != null) {
      implementations[coreTypeName!] = this;
    }
  }

  Future<String> getInjectedConfig(String cfgStr) async {
    return cfgStr;
  }

  CoreDataNotifierBase dataNotifier = CoreDataNotifierBase();
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
      }
    }
  }
}
