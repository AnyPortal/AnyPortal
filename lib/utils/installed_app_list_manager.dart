import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppListManager {
  InstalledAppListManager._();
  static final InstalledAppListManager instance = InstalledAppListManager._();

  final Map<String, AppInfo> appMap = {};
  List<AppInfo> get appList => appMap.values.toList();
  bool _isIconFetchedOnce = false;

  /// Only the first `ensureIcon = true` will trigger batch icon fetch.
  /// Any newly installed package after first fetch (no matter `ensureIcon`),
  /// will fetch full package info including icon no matter `ensureIcon`.
  Future<void> updateInstalledApps({
    bool excludeSystemApps = false,
    bool ensureIcon = false,
  }) async {
    bool isIconFirstFetch = ensureIcon && !_isIconFetchedOnce;
    final newAppList = await InstalledApps.getInstalledApps(
      excludeSystemApps,
      isIconFirstFetch,
    );
    if (isIconFirstFetch) _isIconFetchedOnce = true;

    final newAppPackageNames = <String>{};
    for (final newApp in newAppList) {
      newAppPackageNames.add(newApp.packageName);
      if (appMap.containsKey(newApp.packageName)) {
        final oldApp = appMap[newApp.packageName]!;
        if (newApp.installedTimestamp == oldApp.installedTimestamp) {
          if (isIconFirstFetch) {
            oldApp.icon = newApp.icon;
          }
        } else {
          updateAppInfo(newApp.packageName);
        }
      } else {
        if (!_isIconFetchedOnce) {
          appMap[newApp.packageName] = newApp;
        } else {
          updateAppInfo(newApp.packageName);
        }
      }
    }
    final removedApps = appMap.keys.toSet().difference(newAppPackageNames);
    for (final removedApp in removedApps) {
      appMap.remove(removedApp);
    }
    return;
  }

  Future<void> updateAppInfo(String packageName) async {
    final newAppFull =
        await InstalledApps.getAppInfo(packageName, BuiltWith.flutter);
    if (newAppFull != null) appMap[packageName] = newAppFull;
  }
}
