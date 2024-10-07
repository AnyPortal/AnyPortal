import 'dart:io';

class PlatformElevation {
  static Future<bool> isElevated() async {
    if (Platform.isWindows) {
      ProcessResult result = await Process.run('net', ['session']);
      return result.exitCode == 0;
    } else if (Platform.isMacOS || Platform.isLinux) {
      ProcessResult result = await Process.run('id', ['-u']);
      return result.stdout.trim() == '0';
    }
    return false; // Unsupported platforms
  }

  static Future<void> elevate() async {
    if (Platform.isWindows) {
      await Process.run('powershell',
          ['-noprofile', 'Start-Process', Platform.resolvedExecutable, '-Verb', 'runAs']);
    } else if (Platform.isMacOS) {
      await Process.run('osascript', [
        '-e',
        'do shell script "sudo ${Platform.resolvedExecutable}" with administrator privileges'
      ]);
    } else if (Platform.isLinux) {
      await Process.run('pkexec', [
        Platform.resolvedExecutable, // Replace with your app's path
      ]);
    }
  }
}
