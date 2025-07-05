import '../base/plugin.dart';

import 'config_injector.dart' as config_injector;

class CorePluginHysteria2 extends CorePluginBase {
  @override
  String? get coreTypeName => "hysteria2";

  @override
  bool get isToLogStdout => true;

  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) =>
      config_injector.getInjectedConfig(cfgStr, coreCfgFmt);

}
