import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';

import 'platform.dart';

abstract class PlatformLaunchAtLogin {
  Future<bool> isEnabled();
  Future<bool> enable({bool isElevated = false});
  Future<bool> disable();
}

class PlatformLaunchAtLoginWindows extends PlatformLaunchAtLogin {
  String taskName = "AnyPortal";
  @override
  Future<bool> isEnabled() async {
    ProcessResult result = await Process.run("schtasks", [
      "/query",
      "/tn",
      taskName,
    ]);

    return result.exitCode == 0;
  }

  @override
  Future<bool> enable({bool isElevated = false}) async {
    final runLevel = isElevated ? "-RunLevel Highest" : "";

    /// schtasks does not allow to set ExecutionTimeLimit
    final script = """
      \$currentUserId = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
      \$action = New-ScheduledTaskAction -Execute '${Platform.resolvedExecutable}' -Argument '--minimized'
      \$trigger = New-ScheduledTaskTrigger -AtLogOn -User \$currentUserId
      \$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit '00:00:00'
      \$principal = New-ScheduledTaskPrincipal -UserId \$currentUserId -LogonType 3 $runLevel
      \$task = New-ScheduledTask -Action \$action -Principal \$principal -Trigger \$trigger -Settings \$settings
      Register-ScheduledTask $taskName -InputObject \$task
    """;
    return await _runPowerShellScript(script);
  }

  @override
  Future<bool> disable() async {
    ProcessResult result = await Process.run("schtasks", [
      "/delete",
      "/tn",
      taskName,
      "/f",
    ]);

    return result.exitCode == 0;
  }

  Future<bool> _runPowerShellScript(String script) async {
    ProcessResult result =
        await Process.run('C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe', ['-noprofile', '-Command', script]);

    return result.exitCode == 0;
  }
}

class PlatformLaunchAtLoginGeneric extends PlatformLaunchAtLogin {
  @override
  Future<bool> isEnabled() async {
    return await launchAtStartup.isEnabled();
  }

  @override
  Future<bool> enable({bool isElevated = false}) async {
    return await launchAtStartup.enable();
  }

  @override
  Future<bool> disable() async {
    return await launchAtStartup.disable();
  }
}

final platformLaunchAtLogin = platform.isWindows
    ? PlatformLaunchAtLoginWindows()
    : PlatformLaunchAtLoginGeneric();
