import 'dart:io';

import 'runtime_platform.dart';

class PlatformElevation {
  static Future<bool> isElevated() async {
    if (RuntimePlatform.isWindows) {
      ProcessResult result = await Process.run('net', ['session']);
      return result.exitCode == 0;
    } else if (RuntimePlatform.isMacOS || RuntimePlatform.isLinux) {
      ProcessResult result = await Process.run('id', ['-u']);
      return result.stdout.trim() == '0';
    } else if (RuntimePlatform.isAndroid) {
      try {
        ProcessResult result = await Process.run('su', ['-c', 'echo 0']);
        return result.stdout.trim() == '0';
      } catch (_) {
        return false;
      }
    }
    return false; // Unsupported platforms
  }

  static Future<void> elevate() async {
    final args = Platform.executableArguments;
    if (RuntimePlatform.isWindows) {
      await Process.run(
        'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
        [
          '-noprofile',
          "Start-Process '${Platform.resolvedExecutable}' -Verb RunAs",
        ],
        runInShell: true,
      );
    } else if (RuntimePlatform.isMacOS) {
      await Process.run('osascript', [
        '-e',
        'do shell script "sudo ${Platform.resolvedExecutable}" with administrator privileges'
      ]);
    } else if (RuntimePlatform.isLinux) {
      await Process.run(
        'pkexec',
        [Platform.resolvedExecutable, ...args],
      );
    }
  }
}
