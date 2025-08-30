import '../base/plugin.dart';
import '../clash/dashboard.dart';

import 'config_injector.dart';
import 'data_notifier.dart';

class CorePluginSingBox extends CorePluginBase {
  CorePluginSingBox() : super() {
    coreTypeName = "sing-box";
    dataNotifier = CoreDataNotifierSingBox();
    configInjector = ConfigInjectorSingBox();
    dashboardWidgets = DashboardWidgetsClash();
  }
}
