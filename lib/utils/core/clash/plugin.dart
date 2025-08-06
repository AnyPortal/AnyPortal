import '../base/plugin.dart';

import 'config_injector.dart';
import 'dashboard.dart';
import 'data_notifier.dart';

class CorePluginClash extends CorePluginBase {
  CorePluginClash() : super() {
    coreTypeName = "clash";
    defaultArgs = ["-f", "{config.path}"];
    dataNotifier = CoreDataNotifierClash();
    configInjector = ConfigInjectorClash();
    dashboardWidgets = DashboardWidgetsClash();
    isToLogStdout = true;
  }
}
