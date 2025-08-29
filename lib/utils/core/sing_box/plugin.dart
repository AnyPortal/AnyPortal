import 'package:anyportal/utils/core/sing_box/data_notifier.dart';

import '../base/plugin.dart';
import '../clash/dashboard.dart';

import 'config_injector.dart';

class CorePluginSingBox extends CorePluginBase {
  CorePluginSingBox() : super() {
    coreTypeName = "sing-box";
    dataNotifier = CoreDataNotifierSingBox();
    configInjector = ConfigInjectorSingBox();
    dashboardWidgets = DashboardWidgetsClash();
  }
}
