import '../base/config_injector.dart';
import '../base/plugin.dart';

import 'config_injector.dart';

class CorePluginHysteria2 extends CorePluginBase {
  @override
  String? get coreTypeName => "hysteria2";

  late ConfigInjectorBase _configInjector;
  CorePluginHysteria2() : super(){
    CorePluginBase.implementations["xray"] = this;
    _configInjector = ConfigInjectorHysteria2();
  }
  
  @override
  bool get isToLogStdout => true;

  @override
  ConfigInjectorBase get configInjector => _configInjector;
}
