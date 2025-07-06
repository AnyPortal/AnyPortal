import 'package:anyportal/utils/core/base/config_injector.dart';

import '../base/data_notifier.dart';
import '../base/plugin.dart';

import 'config_injector.dart';
import 'data_notifier.dart';

class CorePluginV2Ray extends CorePluginBase {
  late CoreDataNotifierBase _dataNotifier;
  late ConfigInjectorBase _configInjector;
  CorePluginV2Ray() : super(){
    CorePluginBase.implementations["xray"] = this;
    _dataNotifier = CoreDataNotifierV2Ray();
    _configInjector = ConfigInjectorV2Ray();
  }

  @override
  String? get coreTypeName => "v2ray";

  @override
  CoreDataNotifierBase get dataNotifier => _dataNotifier;
  
  @override
  ConfigInjectorBase get configInjector => _configInjector;
}
