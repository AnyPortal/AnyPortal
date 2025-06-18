import 'package:flutter/material.dart';

import 'package:system_theme/system_theme.dart';

import 'runtime_platform.dart';
import 'platform_version.dart';
import 'prefs.dart';

bool getIsTransparentBG() {
  bool isTransparentBG = false;
  if (RuntimePlatform.isWindows) {
    final windowsVersionNumber = getPlatformVersionNumber();
    isTransparentBG =
        windowsVersionNumber != null && windowsVersionNumber >= 22000;
  } else if (RuntimePlatform.isMacOS) {
    isTransparentBG = true;
  }
  return isTransparentBG;
}

Color getColorSchemeSeed() {
  if (RuntimePlatform.isWeb){
    return const Color.fromARGB(82, 0, 140, 255);
  }
  return SystemTheme.accentColor.accent;
}

ThemeData getPlatformThemeData() {
  bool isTransparentBG = getIsTransparentBG();

  if (RuntimePlatform.isWindows || RuntimePlatform.isMacOS) {
    return ThemeData(
      // colorSchemeSeed: SystemTheme.accentColor.accent,
      colorSchemeSeed: getColorSchemeSeed(),
      useMaterial3: true,
      scaffoldBackgroundColor: isTransparentBG ? Colors.transparent : null,
      cardTheme: const CardThemeData(
        color: Color.fromARGB(240, 255, 255, 255),
        shadowColor: Color.fromARGB(172, 0, 0, 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isTransparentBG ? Colors.transparent : null,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isTransparentBG ? Colors.transparent : null,
        indicatorColor: const Color.fromARGB(240, 255, 255, 255),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  } else {
    return ThemeData(
      // colorSchemeSeed: SystemTheme.accentColor.accent,
      colorSchemeSeed: getColorSchemeSeed(),
      useMaterial3: true,
    );
  }
}

ThemeData getPlatformDarkThemeData() {
  final isBlackDark = prefs.getBool("app.brightness.dark.black")!;
  bool isTransparentBG = getIsTransparentBG();

  if (RuntimePlatform.isWindows || RuntimePlatform.isMacOS) {
    return ThemeData(
      brightness: Brightness.dark,
      // colorSchemeSeed: SystemTheme.accentColor.accent,
      colorSchemeSeed: getColorSchemeSeed(),
      useMaterial3: true,
      scaffoldBackgroundColor: isBlackDark
          ? Colors.black
          : isTransparentBG
              ? Colors.transparent
              : null,
      cardTheme: const CardThemeData(
        color: Color.fromARGB(16, 255, 255, 255),
        shadowColor: Color.fromARGB(64, 0, 0, 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isBlackDark
            ? Colors.black
            : isTransparentBG
                ? Colors.transparent
                : null,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isBlackDark
            ? Colors.black
            : isTransparentBG
                ? Colors.transparent
                : null,
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
      colorSchemeSeed: getColorSchemeSeed(),
      useMaterial3: true,
      scaffoldBackgroundColor: isBlackDark ? Colors.black : null,
      appBarTheme: AppBarTheme(
        backgroundColor: isBlackDark ? Colors.black : null,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isBlackDark ? const Color.fromARGB(16, 255, 255, 255) : null,
      ),
    );
  }
}
