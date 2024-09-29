import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fv2ray/utils/core_manager.dart';

import 'screens/home.dart';
import 'screens/home/settings/tun.dart';
import 'utils/db.dart';
import 'utils/launch_at_startup.dart';
import 'utils/prefs.dart';
import 'utils/tray.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbManager = DatabaseManager();
  await dbManager.init(); // Initialize the database

  final prefsManager = PrefsManager();
  await prefsManager.init();

  if (Platform.isAndroid || Platform.isIOS) {
    await tProxyConfInit();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    initSystemTray();
    initLaunchAtStartup();
  }

  final coreManManager = CoreManManager();
  await coreManManager.init();

  if (prefs.getBool('app.connectAtLaunch')!) {
    try {
      if (!await coreMan.on()) {
        await coreMan.start();
      }
    } on Exception catch (_) {}
  }

  runApp(const Fv2ray());
}

class Fv2ray extends StatelessWidget {
  const Fv2ray({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fv2ray',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromARGB(82, 0, 140, 255),
        useMaterial3: true,
      ),
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
