import '../base/data_notifier.dart';
import '../base/plugin.dart';

import 'config_injector.dart' as config_injector;
import 'data_notifier.dart';

class CorePluginV2Ray extends CorePluginBase {
  late CoreDataNotifierBase _dataNotifier;
  CorePluginV2Ray() : super(){
    CorePluginBase.implementations["xray"] = this;
    _dataNotifier = CoreDataNotifierV2Ray();
  }

  @override
  String? get coreTypeName => "v2ray";

  @override
  Future<String> getInjectedConfig(String cfgStr) =>
      config_injector.getInjectedConfig(cfgStr);

  @override
  CoreDataNotifierBase get dataNotifier => _dataNotifier;
}
