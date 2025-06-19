import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'generated/l10n/app_localizations.dart';
import 'screens/home.dart';
import 'screens/home/settings/tun_hev_socks5_tunnel.dart';
import 'utils/arg_parser.dart';
import 'utils/asset_remote/app.dart';
import 'utils/copy_assets.dart';
import 'utils/core_data_notifier.dart';
import 'utils/db.dart';
import 'utils/global.dart';
import 'utils/launch_at_startup.dart';
import 'utils/locale_manager.dart';
import 'utils/logger.dart';
import 'utils/method_channel.dart';
import 'utils/platform_elevation.dart';
import 'utils/platform_task_scheduler.dart';
import 'utils/platform_theme.dart';
import 'utils/prefs.dart';
import 'utils/runtime_platform.dart';
import 'utils/theme_manager.dart';
import 'utils/tray_menu.dart';
import 'utils/vpn_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await ArgParserManager().init(args);
  await LoggerManager().init(
    logLevelName: cliArg.option("log-level"),
    overrideExisting: true,
  );

  await Future.wait([
    PrefsManager().init(),
    GlobalManager().init(),
    MethodChannelManager().init(),
  ]);

  if (prefs.getBool("app.runElevated")! && !global.isElevated) {
    await PlatformElevation.elevate();
    exit(0);
  }

  await Future.wait([
    DatabaseManager().init(),
    ThemeManager().init(),
    LocaleManager().init(),
  ]);

  await Future.wait([
    VPNManManager().init(),
    CoreDataNotifierManager().init(),
    PlatformTaskSchedulerManager().init(),
  ]);

  try {
    await vPNMan.initCore();
  } catch (e) {
    logger.w("vPNMan.initCore: ${e.toString()}");
  }

  if (RuntimePlatform.isAndroid || RuntimePlatform.isIOS) {
    await tProxyConfInit();
  } else if (RuntimePlatform.isWindows ||
      RuntimePlatform.isLinux ||
      RuntimePlatform.isMacOS) {
    /// auto launch at login
    initLaunchAtStartup();

    /// minimize to tray
    await TrayMenuManager().init();
    await windowManager.ensureInitialized();
    final width = prefs.getDouble("app.window.size.width");
    final height = prefs.getDouble("app.window.size.height");
    final isMaximized = prefs.getBool("app.window.isMaximized");
    WindowOptions windowOptions = WindowOptions(
      size: Size(width!, height!),
      skipTaskbar: false,
    );
    // override the default close handler
    await windowManager.setPreventClose(true);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (!cliArg.flag("minimized")) {
        await windowManager.show();
        await windowManager.focus();
        if (isMaximized!) await windowManager.maximize();
      }
    });

    /// transparent background
    if (RuntimePlatform.isWindows || RuntimePlatform.isMacOS) {
      await Window.initialize();
      var dispatcher = SchedulerBinding.instance.platformDispatcher;
      await Window.setEffect(
        effect: getIsTransparentBG() ? WindowEffect.mica : WindowEffect.solid,
        dark: dispatcher.platformBrightness == Brightness.dark,
      );
    }
  }

  if (!RuntimePlatform.isWeb) {
    /// copy assets
    await copyAssetsToDefaultLocation();

    /// theme color
    SystemTheme.fallbackColor = const Color.fromARGB(82, 0, 140, 255);
    await SystemTheme.accentColor.load();
  }

  /// app
  logger.d("starting: runApp");
  runApp(const AnyPortal());
  logger.d("finished: runApp");

  /// find active core and tun
  try {
    await Future.wait([
      vPNMan.updateDetachedCore(),
      vPNMan.updateDetachedTun(),
    ]);
  } catch (e) {
    logger.w("vPNMan.initCore: ${e.toString()}");
  }

  if (RuntimePlatform.isWindows ||
      RuntimePlatform.isLinux ||
      RuntimePlatform.isMacOS) {
    /// connect at launch
    Exception? err;
    if (prefs.getBool('app.connectAtLaunch')!) {
      try {
        if (!await vPNMan.getIsCoreActive()) {
          await vPNMan.startAll();
        }
      } on Exception catch (e) {
        logger.w("$e");
        err = e;
      } finally {
        if (err != null) {
          vPNMan.setisTogglingAll(false);
        }
      }
    }
  }

  if (prefs.getBool("app.autoUpdate")!) {
    final assetRemoteProtocolApp = AssetRemoteProtocolApp();
    if (await assetRemoteProtocolApp.init()) {
      await assetRemoteProtocolApp.update(
        context: global.navigatorKey.currentContext,
        shouldInstall: true,
      );
    }
  }
}

class AnyPortal extends StatelessWidget {
  const AnyPortal({super.key});

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([themeManager, localeManager]),
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'AnyPortal',
            navigatorKey: global.navigatorKey,
            theme: getPlatformThemeData(),
            locale: localeManager.locale,
            darkTheme: getPlatformDarkThemeData(),
            themeMode: themeManager.isDark ? ThemeMode.dark : ThemeMode.light,
            home: HomePage(
              title: 'AnyPortal',
            ),
            localizationsDelegates: [
              LocaleNamesLocalizationsDelegate(),
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        });
  }
}
