import '../base/plugin.dart';

import 'config_injector.dart';
import 'dashboard.dart';
import 'data_notifier.dart';

class CorePluginV2Ray extends CorePluginBase {
  CorePluginV2Ray() : super() {
    coreTypeName = "v2ray";
    dataNotifier = CoreDataNotifierV2Ray();
    configInjector = ConfigInjectorV2Ray();
    dashboardWidgets = DashboardWidgetsV2Ray();

    CorePluginBase.implementations["xray"] = this;
  }
}
