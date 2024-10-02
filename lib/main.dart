// import 'dart:developer';
import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fv2ray/utils/vpn_manager.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home.dart';
import 'screens/home/settings/tun.dart';
import 'utils/core_data_notifier.dart';
import 'utils/db.dart';
import 'utils/launch_at_startup.dart';
import 'utils/prefs.dart';
import 'utils/tray.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseManager().init();
  await PrefsManager().init();
  await VPNManManager().init();
  await CoreDataNotifierManager().init();

  if (Platform.isAndroid || Platform.isIOS) {
    await tProxyConfInit();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // auto launch at login
    initLaunchAtStartup();

    // minimize to tray
    initSystemTray();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (!args.contains("--minimized")) {
        await windowManager.show();
        await windowManager.focus();
      }
    });

    // transparent background
    await Window.initialize();
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    await Window.setEffect(
      effect: WindowEffect.mica,
      dark: dispatcher.platformBrightness == Brightness.dark,
    );
  }

  // theme color
  SystemTheme.fallbackColor = const Color.fromARGB(82, 0, 140, 255);
  await SystemTheme.accentColor.load();

  // connect at launch
  if (prefs.getBool('app.connectAtLaunch')!) {
    try {
      if (!await vPNMan.updateIsActive()) {
        await vPNMan.start();
      }
    } catch (_) {}
  }

  runApp(const Fv2ray());
}

class Fv2ray extends StatelessWidget {
  const Fv2ray({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      if (Platform.isWindows || Platform.isMacOS) {
        return ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: SystemTheme.accentColor.accent,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
          cardTheme: const CardTheme(
            color: Color.fromARGB(16, 255, 255, 255),
            shadowColor: Color.fromARGB(64, 0, 0, 0),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: Color.fromARGB(16, 255, 255, 255),
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
        );
      }
    }

    return MaterialApp(
      title: 'Fv2ray',
      theme: getPlatformThemeData(),
      darkTheme: getPlatformDarkThemeData(),
      home: const HomePage(title: 'Flutter Demo Home Page'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

// class Fv2ray extends StatefulWidget {
//   const Fv2ray({super.key});

//   @override
//   State<Fv2ray> createState() => _Fv2rayState();
// }

// class _Fv2rayState extends State<Fv2ray> {
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
