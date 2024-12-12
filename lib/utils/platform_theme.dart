import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

import 'platform_version.dart';
import 'prefs.dart';

bool getIsTransparentBG() {
  bool isTransparentBG = false;
  if (Platform.isWindows) {
    final windowsVersionNumber = getWindowsVersionNumber();
    isTransparentBG =
        windowsVersionNumber != null && windowsVersionNumber >= 22000;
  } else if (Platform.isMacOS) {
    isTransparentBG = true;
  }
  return isTransparentBG;
}

Color getColorSchemeSeed() {
  return SystemTheme.accentColor.accent;
  // return const Color.fromARGB(82, 0, 140, 255);
}

ThemeData getPlatformThemeData() {
  bool isTransparentBG = getIsTransparentBG();

  if (Platform.isWindows || Platform.isMacOS) {
    return ThemeData(
      // colorSchemeSeed: SystemTheme.accentColor.accent,
      colorSchemeSeed: getColorSchemeSeed(),
      useMaterial3: true,
      scaffoldBackgroundColor: isTransparentBG ? Colors.transparent : null,
      cardTheme: const CardTheme(
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

  if (Platform.isWindows || Platform.isMacOS) {
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
      cardTheme: const CardTheme(
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
