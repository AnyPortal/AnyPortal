import 'dart:async';

import '../../logger.dart';
import '../clash/plugin.dart';
import '../hysteria2/plugin.dart';
import '../naive/plugin.dart';
import '../sing_box/plugin.dart';
import '../v2ray/plugin.dart';

import 'config_injector.dart';
import 'dashboard.dart';
import 'data_notifier.dart';

class CorePluginBase {
  String? coreTypeName;
  List<String> defaultArgs = ["run", "-c", "{config.path}"];
  bool isToLogStdout = true;
  Map<String, String> environment = {};
  CoreDataNotifierBase dataNotifier = CoreDataNotifierBase();
  ConfigInjectorBase configInjector = ConfigInjectorBase();
  DashboardWidgetsBase dashboardWidgets = DashboardWidgetsBase();
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
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: CorePluginManager.init");
  }

  void load(String coreTypeName) {
    switch (coreTypeName) {
      case "v2ray":
      case "xray":
        instances[coreTypeName] = CorePluginV2Ray();
        break;
      case "sing-box":
        instances[coreTypeName] = CorePluginSingBox();
        break;
      case "hysteria2":
        instances[coreTypeName] = CorePluginHysteria2();
        break;
      case "clash":
      case "mihomo":
        instances[coreTypeName] = CorePluginClash();
        break;
      case "naive":
        instances[coreTypeName] = CorePluginNaive();
    }
  }

  void ensureLoaded(String coreTypeName) {
    if (!instances.containsKey(coreTypeName)) {
      load(coreTypeName);
    }
  }

  void switchTo(String coreTypeName) {
    ensureLoaded(coreTypeName);
    instance = instances[coreTypeName]!;
  }
}
