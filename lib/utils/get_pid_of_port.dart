import 'dart:io';

import 'logger.dart';
import 'runtime_platform.dart';

Future<int?> getPidOfPort(int port) async {
  try {
    if (RuntimePlatform.isWindows) {
      // Windows command
      var result = await Process.run('netstat', ['-aon']);
      var output = result.stdout as String;

      // Match lines with the port and extract PID
      var lines = output.split('\n');
      for (var line in lines) {
        var columns = line.trim().split(RegExp(r'\s+'));

        // Ensure line has enough columns (protocol, local address, foreign address, state, PID)
        if (columns.length >= 5) {
          var localAddress = columns[1];
          String pidStr = columns[4];

          // Check if local address ends with ':port'
          if (localAddress.endsWith(':$port')) {
            final pid = int.tryParse(pidStr);
            if (pid == 0) {
              // ignore TIME_WAIT
              continue;
            } else {
              /// Todo: pid may not exist
              // final res = await Process.run('tasklist', ['/FI', '"PID eq $pid"']);
              return pid;
            }
          }
        }
      }
    } else if (RuntimePlatform.isLinux || RuntimePlatform.isMacOS) {
      // macOS/Linux command
      var result = await Process.run('lsof', ['-i', 'tcp:$port']);
      var output = result.stdout as String;

      // Match lines with the port and extract PID
      var lines = output.split('\n');
      for (var line in lines) {
        var columns = line.trim().split(RegExp(r'\s+'));

        // Ensure line has enough columns (command, PID, user, fd, type, device, size, node, name)
        if (columns.length >= 9) {
          var localAddress =
              columns[8]; // Local address:port is usually in the last column
          var pid = columns[1];

          // Check if the local address ends with ':port'
          if (localAddress.endsWith(':$port')) {
            return int.tryParse(pid);
          }
        }
      }
    }
  } catch (e) {
    logger.d('Error: $e');
  }
  return null; // Return null if PID is not found
}
