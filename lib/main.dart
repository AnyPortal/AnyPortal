import 'dart:io';

// import 'package:flutter/cupertino.dart';
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
import 'utils/core_data_notifier.dart';
import 'utils/db.dart';
import 'utils/launch_at_startup.dart';
import 'utils/method_channel.dart';
import 'utils/prefs.dart';
import 'utils/tray_menu.dart';
import 'utils/copy_assets.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await LoggerManager().init();

  await Future.wait([
    PrefsManager().init(),
    GlobalManager().init(),
    MethodChannelManager().init(),
  ]);

  if (prefs.getBool("app.runElevated")! && !global.isElevated) {
    await PlatformElevation.elevate();
    exit(0);
  }

  await DatabaseManager().init();

  await Future.wait([
    VPNManManager().init(),
    CoreDataNotifierManager().init(),
  ]);

  try {
    await vPNMan.initCore();
  } catch (_) {}

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
    final skipTaskbar = prefs.getBool("app.window.skipTaskbar");
    WindowOptions windowOptions = WindowOptions(
      size: Size(width!, height!),
      skipTaskbar: skipTaskbar,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (!args.contains("--minimized")) {
        await windowManager.show();
        await windowManager.focus();
        if (isMaximized!) await windowManager.maximize();
      }
    });

    /// transparent background
    if (Platform.isWindows || Platform.isMacOS) {
      await Window.initialize();
      var dispatcher = SchedulerBinding.instance.platformDispatcher;
      await Window.setEffect(
        effect: WindowEffect.mica,
        dark: dispatcher.platformBrightness == Brightness.dark,
      );
    }
  }


  // copy assets
  await copyAssetsToDefaultLocation();

  /// theme color
  SystemTheme.fallbackColor = const Color.fromARGB(82, 0, 140, 255);
  await SystemTheme.accentColor.load();

  runApp(const AnyPortal());

  /// find active core and tun
  try {
    await Future.wait([
      vPNMan.updateDetachedCore(),
      vPNMan.updateDetachedTun(),
    ]);
  } catch (_) {}

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    /// connect at launch
    Exception? err;
    if (prefs.getBool('app.connectAtLaunch')!) {
      try {
        if (!await vPNMan.getIsCoreActive()) {
          await vPNMan.start();
        }
      } on Exception catch (e) {
        logger.e("$e");
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

  ThemeData getPlatformThemeData() {
    if (Platform.isWindows || Platform.isMacOS) {
      return ThemeData(
        colorSchemeSeed: SystemTheme.accentColor.accent,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: const CardTheme(
          color: Color.fromARGB(240, 255, 255, 255),
          shadowColor: Color.fromARGB(172, 0, 0, 0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: Color.fromARGB(240, 255, 255, 255),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        }),
      );
    } else {
      return ThemeData(
        colorSchemeSeed: SystemTheme.accentColor.accent,
        useMaterial3: true,
      );
    }
  }

  ThemeData getPlatformDarkThemeData() {
    final isBlackDark = prefs.getBool("app.brightness.dark.black")!;
    if (Platform.isWindows || Platform.isMacOS) {
      return ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: SystemTheme.accentColor.accent,
        useMaterial3: true,
        scaffoldBackgroundColor: isBlackDark ? Colors.black : Colors.transparent,
        cardTheme: const CardTheme(
          color: Color.fromARGB(16, 255, 255, 255),
          shadowColor: Color.fromARGB(64, 0, 0, 0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: isBlackDark ? Colors.black : Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: isBlackDark ? Colors.black : Colors.transparent,
          indicatorColor: const Color.fromARGB(16, 255, 255, 255),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        }),
      );
    } else {
      return ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: SystemTheme.accentColor.accent,
        useMaterial3: true,
        scaffoldBackgroundColor: isBlackDark ? Colors.black : null,
        appBarTheme: AppBarTheme(
          backgroundColor: isBlackDark ? Colors.black : null,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: isBlackDark ? const Color.fromARGB(16, 255, 255, 255) : null,
        ),
      );
    }
  }

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

// class AnyPortal extends StatefulWidget {
//   const AnyPortal({super.key});

//   @override
//   State<AnyPortal> createState() => _AnyPortalState();
// }

// class _AnyPortalState extends State<AnyPortal> {
//   ThemeMode? themeMode = ThemeMode.system; // initial brightness

//   @override
//   Widget build(BuildContext context) {
//     final materialLightTheme = ThemeData(
//       colorSchemeSeed: const Color.fromARGB(82, 0, 140, 255),
//       useMaterial3: true,
//     );
//     final materialDarkTheme = ThemeData(
//       brightness: Brightness.dark,
//       colorSchemeSeed: const Color.fromARGB(82, 0, 140, 255),
//       useMaterial3: true,
//     );

//     const darkDefaultCupertinoTheme =
//         CupertinoThemeData(brightness: Brightness.dark);
//     final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
//       materialTheme: materialDarkTheme.copyWith(
//         cupertinoOverrideTheme: CupertinoThemeData(
//           brightness: Brightness.dark,
//           barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
//           textTheme: CupertinoTextThemeData(
//             primaryColor: Colors.white,
//             navActionTextStyle:
//                 darkDefaultCupertinoTheme.textTheme.navActionTextStyle.copyWith(
//               color: const Color(0xF0F9F9F9),
//             ),
//             navLargeTitleTextStyle: darkDefaultCupertinoTheme
//                 .textTheme.navLargeTitleTextStyle
//                 .copyWith(color: const Color(0xF0F9F9F9)),
//           ),
//         ),
//       ),
//     );
//     final cupertinoLightTheme =
//         MaterialBasedCupertinoThemeData(materialTheme: materialLightTheme);

//     return PlatformProvider(
//       settings: PlatformSettingsData(
//         iosUsesMaterialWidgets: true,
//         iosUseZeroPaddingForAppbarPlatformIcon: true,
//       ),
//       builder: (context) => PlatformTheme(
//         themeMode: themeMode,
//         materialLightTheme: materialLightTheme,
//         materialDarkTheme: materialDarkTheme,
//         cupertinoLightTheme: cupertinoLightTheme,
//         cupertinoDarkTheme: cupertinoDarkTheme,
//         matchCupertinoSystemChromeBrightness: true,
//         onThemeModeChanged: (themeMode) {
//           this.themeMode = themeMode; /* you can save to storage */
//         },
//         builder: (context) => const PlatformApp(
//           // localizationsDelegates: <LocalizationsDelegate<dynamic>>[
//           //   AppLocalizations.delegate,
//           //   DefaultMaterialLocalizations.delegate,
//           //   DefaultWidgetsLocalizations.delegate,
//           //   DefaultCupertinoLocalizations.delegate,
//           // ],
//           // supportedLocales: [
//           //   Locale('en'),
//           //   Locale('zh'),
//           // ],
//           localizationsDelegates: AppLocalizations.localizationsDelegates,
//           supportedLocales: AppLocalizations.supportedLocales,
//           title: 'Flutter Platform Widgets',
//           home: HomePage(
//             title: '',
//           ),
//         ),
//       ),
//       // ),
//     );
//   }
// }
