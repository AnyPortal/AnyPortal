import '../base/plugin.dart';

import 'config_injector.dart';

class CorePluginNaive extends CorePluginBase {
  CorePluginNaive() : super() {
    coreTypeName = "naive";
    defaultArgs = ["{config.path}"];
    configInjector = ConfigInjectorNaive();
  }
}
