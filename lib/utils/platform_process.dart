import 'dart:io';

import 'package:anyportal/utils/logger.dart';

class PlatformProcess {
  static Future<int?> getProcessPid(String commandLine) async {
    try {
      if (Platform.isWindows) {
        return await _getProcessPidWindows(commandLine);
      } else if (Platform.isMacOS || Platform.isLinux) {
        return await _getProcessPidUnix(commandLine);
      }
    } catch (e) {
      logger.w("Error finding process PID: $e");
    }
    return null;
  }

  static Future<int?> _getProcessPidWindows(String commandLine) async {
    // Use 'wmic' to get the list of processes
    final result = await Process.run('wmic', ['process', 'list', 'full']);
    if (result.exitCode == 0) {
      // Split the output into lines
      final lines = result.stdout.toString().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains(commandLine)) {
          // PID will usually be a few lines below the matching command
          for (var j = i; j < lines.length; j++) {
            if (lines[j].startsWith('ProcessId=')) {
              final pid = int.tryParse(lines[j].split('=')[1].trim());
              return pid;
            }
          }
        }
      }
    }
    return null;
  }

  static Future<int?> _getProcessPidUnix(String commandLine) async {
    // Use 'ps' to list processes and search for the commandLine
    final result = await Process.run('ps', ['aux']);
    if (result.exitCode == 0) {
      final lines = result.stdout.toString().split('\n');
      for (var line in lines) {
        if (line.contains(commandLine)) {
          // Parse out the PID (Unix `ps aux` format: USER PID %CPU %MEM ...)
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length > 1) {
            final pid = int.tryParse(parts[1]);
            return pid;
          }
        }
      }
    }
    return null;
  }
}
