
import 'package:anyportal/utils/core/sing_box/data_notifier.dart';

import '../base/data_notifier.dart';
import '../base/plugin.dart';

import 'config_injector.dart' as config_injector;

class CorePluginSingBox extends CorePluginBase {
  late CoreDataNotifierBase _dataNotifier;
  CorePluginSingBox() : super() {
    _dataNotifier = CoreDataNotifierSingBox();
  }

  @override
  String? get coreTypeName => "sing-box";

  @override
  Future<String> getInjectedConfig(String cfgStr) =>
      config_injector.getInjectedConfig(cfgStr);

  @override
  CoreDataNotifierBase get dataNotifier => _dataNotifier;
}
