import 'dart:convert';
import 'dart:io';

import 'package:anyportal/utils/logger.dart';

import 'platform.dart';

class PlatformProcess {
  static Future<int?> getProcessPid(String commandLine) async {
    logger.d("getProcessPid: $commandLine");
    try {
      if (platform.isWindows) {
        return await _getProcessPidWindows(commandLine);
      } else if (platform.isMacOS || platform.isLinux) {
        return await _getProcessPidUnix(commandLine);
      }
    } catch (e) {
      logger.w("Error finding process PID: $e");
    }
    return null;
  }

  static Future<int?> _getProcessPidWindows(String commandLine) async {
    try {
      // Run the PowerShell command to get all processes and their command lines in JSON format
      final result = await Process.run(
        'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
        [
          '-noprofile',
          'Get-WmiObject Win32_Process | Select-Object ProcessId, CommandLine | ConvertTo-Json',
        ],
      );

      // Parse the JSON result into a List of dynamic (Map) objects
      final List<dynamic> processes = jsonDecode(result.stdout);

      // Search through the processes for an exact match on the command line
      for (var process in processes) {
        if (process['CommandLine'] == commandLine) {
          final pid = process['ProcessId'];
          logger.d("_getProcessPidWindows: $pid");
          return pid; // Return the PID
        }
      }
      logger.d("_getProcessPidWindows: null");
      return null; // No matching process found
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
    if (platform.isWindows) {
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
