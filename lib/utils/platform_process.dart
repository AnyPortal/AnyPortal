import 'dart:io';

import 'package:anyportal/utils/logger.dart';

class PlatformProcess {
  static Future<int?> getProcessPid(String commandLine) async {
    logger.d("getProcessPid: $commandLine");
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
    try {
      // Run the PowerShell command
      final result = await Process.run('powershell', [
        'Get-WmiObject Win32_Process | Where-Object { \$_.CommandLine -like "*$commandLine*" } | Select-Object -ExpandProperty ProcessId'
      ]);

      // If the result is not empty, parse the PID
      if (result.stdout.isNotEmpty) {
        final pid = int.tryParse(result.stdout.trim());
        logger.d("_getProcessPidWindows: $pid");
        return pid;
      } else {
        logger.d("_getProcessPidWindows: null");
        return null; // No process found with the matching command line
      }
    } catch (e) {
      logger.e("Error: $e");
      return null;
    }
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
            logger.d("_getProcessPidUnix: $pid");
            return pid;
          }
        }
      }
    }
    return null;
  }

  static Future<bool> killProcess(int pid) async {
    String command;
    List<String> arguments;

    // Determine the platform and set appropriate command and arguments
    if (Platform.isWindows) {
      command = 'taskkill';
      arguments = ['/F', '/PID', pid.toString()]; // /F forces the termination
    } else {
      command = 'kill';
      arguments = [
        '-9',
        pid.toString()
      ]; // -9 forces termination on Unix-based systems
    }

    try {
      // Run the process to kill it
      ProcessResult result = await Process.run(command, arguments);

      // Check if the exit code is 0, indicating success
      if (result.exitCode == 0) {
        logger.d('killProcess: Process $pid killed successfully');
        return true;
      } else {
        logger.d('killProcess: Failed to kill process $pid: ${result.stderr}');
        return false;
      }
    } catch (e) {
      logger.e('killProcess: Error killing process $pid: $e');
      return false;
    }
  }
}
