import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

int? getPlatformVersionNumber() {
  final osVersionInfo = calloc<OSVERSIONINFO>()
    ..ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();

  try {
    if (GetVersionEx(osVersionInfo) != 0) {
      final version = osVersionInfo.ref;
      // return 'Windows ${version.dwMajorVersion}.${version.dwMinorVersion} (Build ${version.dwBuildNumber})';
      return version.dwBuildNumber;
    } else {
      return null;
    }
  } finally {
    calloc.free(osVersionInfo);
  }
}
