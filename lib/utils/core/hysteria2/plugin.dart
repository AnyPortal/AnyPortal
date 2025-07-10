import '../base/plugin.dart';

import 'config_injector.dart';

class CorePluginHysteria2 extends CorePluginBase {
  CorePluginHysteria2() : super(){
    coreTypeName = "hysteria2";
    configInjector = ConfigInjectorHysteria2();
    isToLogStdout = true;
  }
}
