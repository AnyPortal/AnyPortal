import 'dart:io';

import 'package:anyportal/utils/asset_remote/app.dart';
import 'package:anyportal/utils/global.dart';
import 'package:anyportal/utils/logger.dart';
import 'package:anyportal/utils/platform_elevation.dart';
import 'package:anyportal/utils/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anyportal/utils/vpn_manager.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home.dart';
import 'screens/home/settings/tun_hev_socks5_tunnel.dart';
import 'utils/arg_parser.dart';
// import 'utils/asset_remote/app.dart';
import 'utils/core_data_notifier.dart';
import 'utils/db.dart';
import 'utils/launch_at_startup.dart';
import 'utils/method_channel.dart';
import 'utils/platform_task_scheduler.dart';
import 'utils/platform_theme.dart';
import 'utils/prefs.dart';
import 'utils/tray_menu.dart';
import 'utils/copy_assets.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await ArgParserManager().init(args);
  await LoggerManager().init(logLevelName: cliArg.option("log-level"));

  await Future.wait([
    PrefsManager().init(),
    GlobalManager().init(),
    MethodChannelManager().init(),
  ]);

  if (prefs.getBool("app.runElevated")! && !global.isElevated) {
    await PlatformElevation.elevate();
    exit(0);
  }

  if (prefs.getBool("app.autoUpdate")!){
    String? downloadedFilePath = prefs.getString("app.github.downloadedFilePath");
    if (downloadedFilePath != null) {
      prefs.remove("app.github.downloadedFilePath");
      await AssetRemoteProtocolApp.init().install(File(downloadedFilePath));
      exit(0);
    }
  }

  await DatabaseManager().init();

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

  if (Platform.isAndroid || Platform.isIOS) {
    await tProxyConfInit();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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

    bool isTransparentBG = getIsTransparentBG();

    /// transparent background
    if (Platform.isWindows || Platform.isMacOS) {
      await Window.initialize();
      var dispatcher = SchedulerBinding.instance.platformDispatcher;
      await Window.setEffect(
        effect: isTransparentBG ? WindowEffect.mica : WindowEffect.solid,
        dark: dispatcher.platformBrightness == Brightness.dark,
      );
    }
  }

  /// copy assets
  await copyAssetsToDefaultLocation();

  /// theme color
  SystemTheme.fallbackColor = const Color.fromARGB(82, 0, 140, 255);
  await SystemTheme.accentColor.load();

  /// app
  logger.d("starting: runApp");
  runApp(const AnyPortal());
  logger.d("started: runApp");

  /// find active core and tun
  try {
    await Future.wait([
      vPNMan.updateDetachedCore(),
      vPNMan.updateDetachedTun(),
    ]);
  } catch (e) {
    logger.w("vPNMan.initCore: ${e.toString()}");
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    /// connect at launch
    Exception? err;
    if (prefs.getBool('app.connectAtLaunch')!) {
      try {
        if (!await vPNMan.getIsCoreActive()) {
          await vPNMan.start();
        }
      } on Exception catch (e) {
        logger.w("$e");
        err = e;
      } finally {
        if (err != null) {
          vPNMan.setIsToggling(false);
        }
      }
    }
  }
}

class AnyPortal extends StatelessWidget {
  const AnyPortal({super.key});

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    themeManager.isDark = prefs.getBool('app.brightness.followSystem')!
        ? dispatcher.platformBrightness == Brightness.dark
        : prefs.getBool('app.brightness.dark')!;
    return ListenableBuilder(
        listenable: themeManager,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'AnyPortal',
            theme: getPlatformThemeData(),
            darkTheme: getPlatformDarkThemeData(),
            themeMode: themeManager.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(title: 'Flutter Demo Home Page'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        });
  }
}
