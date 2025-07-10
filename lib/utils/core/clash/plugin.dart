import '../base/plugin.dart';

import 'config_injector.dart';
import 'dashboard.dart';
import 'data_notifier.dart';

class CorePluginClash extends CorePluginBase {
  CorePluginClash() : super(){
    coreTypeName = "clash";
    dataNotifier = CoreDataNotifierClash();
    configInjector = ConfigInjectorClash();
    dashboardWidgets = DashboardWidgetsClash();
    isToLogStdout = true;

    CorePluginBase.implementations["mihimo"] = this;
  }
}
