
import 'package:anyportal/utils/core/sing_box/data_notifier.dart';

import '../base/config_injector.dart';
import '../base/data_notifier.dart';
import '../base/plugin.dart';

import 'config_injector.dart';

class CorePluginSingBox extends CorePluginBase {
  late CoreDataNotifierBase _dataNotifier;
  late ConfigInjectorBase _configInjector;
  CorePluginSingBox() : super() {
    _dataNotifier = CoreDataNotifierSingBox();
    _configInjector = ConfigInjectorSingBox();
  }

  @override
  String? get coreTypeName => "sing-box";

  @override
  CoreDataNotifierBase get dataNotifier => _dataNotifier;
  
  @override
  ConfigInjectorBase get configInjector => _configInjector;
}
