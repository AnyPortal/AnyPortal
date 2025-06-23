import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

import '../models/android_trim_memory_level.dart';
import '../utils/method_channel.dart';

class InstalledAppListManager with ChangeNotifier {
  InstalledAppListManager._(){
    mCMan.addHandler("onTrimMemory", handleTrimMemory);
  }

  @override
  void dispose() {
    super.dispose();
    mCMan.removeHandler("onTrimMemory", handleTrimMemory);
  }

  static final InstalledAppListManager instance = InstalledAppListManager._();
  static final platform = mCMan.methodChannel;
  
  /// cached app Map
  /// AppInfo.packageName => AppInfo
  final Map<String, AppInfo> appMap = {};
  bool _isIconFetchedOnce = false;

  List<AppInfo> get appList => appMap.values.toList();
  
  void handleTrimMemory(MethodCall call){
    final level = call.arguments as int;
    if (level >= AndroidTrimMemoryLevel.uiHidden.value){
      clearCache();
    }
  }

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

  void clearCache() {
    _isIconFetchedOnce = false;
    appMap.clear();
  }
}
