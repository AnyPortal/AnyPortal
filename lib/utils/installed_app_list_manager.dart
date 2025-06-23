import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppListManager {
  InstalledAppListManager._();
  static final InstalledAppListManager instance = InstalledAppListManager._();

  final Map<String, AppInfo> appMap = {};
  List<AppInfo> get appList => appMap.values.toList();

  Future<void> update({
    bool excludeSystemApps = false,
    bool withIcon = false,
  }) async {
    final appList = await InstalledApps.getInstalledApps(
      excludeSystemApps,
      withIcon,
    );
    for (final newApp in appList){
      if (appMap.containsKey(newApp.packageName)){
        final oldApp = appMap[newApp.packageName];
        if (oldApp!.icon!.isNotEmpty && newApp.icon!.isEmpty){
          newApp.icon = oldApp.icon;
        }
      }
      appMap[newApp.packageName] = newApp;
    }
    return;
  }
}
