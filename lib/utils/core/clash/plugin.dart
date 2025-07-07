import '../base/config_injector.dart';
import '../base/data_notifier.dart';
import '../base/plugin.dart';

import 'config_injector.dart';
import 'data_notifier.dart';

class CorePluginClash extends CorePluginBase {
  late CoreDataNotifierBase _dataNotifier;
  late ConfigInjectorBase _configInjector;
  CorePluginClash() : super(){
    CorePluginBase.implementations["mihimo"] = this;
    _dataNotifier = CoreDataNotifierClash();
    _configInjector = ConfigInjectorClash();
  }

  @override
  String? get coreTypeName => "clash";

  @override
  CoreDataNotifierBase get dataNotifier => _dataNotifier;

  @override
  ConfigInjectorBase get configInjector => _configInjector;
}
