import 'dart:io';
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:tuple/tuple.dart';

import 'logger.dart';

class PlatformSystemProxyUser {
  Future<bool?> isEnabled() async {
    return null;
  }

  Future<void> enable(Map<String, Tuple2<String, int>> proxies) async {
    return;
  }

  Future<void> disable() async {
    return;
  }
}

// Windows-specific implementation
class PlatformSystemProxyUserWindows extends PlatformSystemProxyUser {
  final _registryPath =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings';

  @override
  Future<bool?> isEnabled() async {
    try {
      final shell = Shell();
      final result =
          await shell.run('reg query "$_registryPath" /v ProxyEnable');
      return result.outText.contains('0x1');
    } catch (e) {
      logger.e("PlatformSystemProxyUserWindows.isEnabled: $e");
      return null;
    }
  }

  @override
  Future<void> enable(Map<String, Tuple2<String, int>> proxies) async {
    try {
      final shell = Shell();
      await shell
          .run('reg add "$_registryPath" /v ProxyEnable /t REG_DWORD /d 1 /f');

      for (var entry in proxies.entries) {
        String protocol = entry.key;
        if (protocol == "http") {
          Tuple2<String, int> hostPort = entry.value;
          String proxyAddress = '${hostPort.item1}:${hostPort.item2}';
          await shell.run(
              'reg add "$_registryPath" /v ProxyServer /t REG_SZ /d "$proxyAddress" /f');
        }
      }
    } catch (e) {
      logger.e("PlatformSystemProxyUserWindows.enable: $e");
    }
  }

  @override
  Future<void> disable() async {
    try {
      final shell = Shell();
      await shell
          .run('reg add "$_registryPath" /v ProxyEnable /t REG_DWORD /d 0 /f');
    } catch (e) {
      logger.e("PlatformSystemProxyUserWindows.disable: $e");
    }
  }
}

// macOS-specific implementation
class PlatformSystemProxyUserMacOS extends PlatformSystemProxyUser {
  Map<String, String> interfaceToService = {};
  String? defaultInterface;
  String? networkService;

  Future<void> updateNetworkService() async {
    await Future.wait([
      updateInterfaceToServiceMap(),
      updateDefaultInterface(),
    ]);
    if (defaultInterface != null &&
        interfaceToService.containsKey(defaultInterface)) {
      networkService = interfaceToService[defaultInterface];
    }
  }

  Future<void> updateInterfaceToServiceMap() async {
    interfaceToService = await getInterfaceToServiceMap();
  }

  Future<void> updateDefaultInterface() async {
    defaultInterface = await getDefaultInterface();
  }

  Future<Map<String, String>> getInterfaceToServiceMap() async {
    final Map<String, String> interfaceToService = {};

    try {
      final shell = Shell();
      final result = await shell.run('networksetup -listnetworkserviceorder');

      // Extract relevant lines with regex
      final regex = RegExp(r'\(\d+\)\s(.+?)\n\(.+,\sDevice:\s(.+?)\)');
      for (final match in regex.allMatches(result.outText)) {
        final service = match.group(1)?.trim();
        final device = match.group(2)?.trim();
        if (service != null && device != null) {
          interfaceToService[device] = service;
        }
      }
    } catch (e) {
      logger.e('getActiveNetworkService: $e');
    }

    return interfaceToService;
  }

  Future<String?> getDefaultInterface() async {
    try {
      // Run the 'route get 0.0.0.0' command
      final shell = Shell();
      final result = await shell.run('route get 0.0.0.0');

      // Find the line with the "interface" key
      final interfaceLine = result.outText.split('\n').firstWhere(
            (line) => line.trim().startsWith('interface:'),
            orElse: () => '',
          );

      if (interfaceLine.isNotEmpty) {
        // Extract and return the interface name
        return interfaceLine.split(':').last.trim();
      } else {
        logger.d('getDefaultInterface: No interface line found in the output.');
        return null;
      }
    } catch (e) {
      logger.e('getDefaultInterface: $e');
      return null;
    }
  }

  @override
  Future<bool?> isEnabled() async {
    await updateNetworkService();
    if (networkService == null) {
      logger.w('PlatformSystemProxyUserMacOS.isEnabled: no networkService');
      return null;
    }
    try {
      final shell = Shell();
      final result = await shell
          .run('networksetup -getsocksfirewallproxy $networkService');
      return result.outText.contains('Enabled: Yes');
    } catch (e) {
      logger.e('PlatformSystemProxyUserMacOS.isEnabled: $e');
      return null;
    }
  }

  @override
  Future<void> enable(Map<String, Tuple2<String, int>> proxies) async {
    try {
      final shell = Shell();
      await shell
          .run('networksetup -setsocksfirewallproxystate $networkService on');
      await shell.run('networksetup -setwebproxystate $networkService on');

      for (var entry in proxies.entries) {
        String protocol = entry.key;
        Tuple2<String, int> hostPort = entry.value;

        if (protocol.toLowerCase() == 'socks') {
          await shell.run(
              'networksetup -setsocksfirewallproxy $networkService ${hostPort.item1} ${hostPort.item2}');
        } else if (protocol.toLowerCase() == 'http') {
          await shell.run(
              'networksetup -setwebproxy $networkService ${hostPort.item1} ${hostPort.item2}');
        } else {
          throw UnsupportedError("Unsupported protocol: $protocol");
        }
      }
    } catch (e) {
      logger.e('PlatformSystemProxyUserMacOS.enable: $e');
    }
  }

  @override
  Future<void> disable() async {
    try {
      final shell = Shell();
      await shell
          .run('networksetup -setsocksfirewallproxystate $networkService off');
      await shell.run('networksetup -setwebproxystate $networkService off');
    } catch (e) {
      logger.e('PlatformSystemProxyUserMacOS.disable: $e');
    }
  }
}

// Linux-specific implementation
class PlatformSystemProxyUserLinux extends PlatformSystemProxyUser {
  String? desktop;
  // Detect GNOME, KDE, or fallback to CLI
  Future<String?> _detectGui() async {
    // logger.w(Platform.environment.toString());
    if (Platform.environment.containsKey("ORIGINAL_XDG_CURRENT_DESKTOP")) {
      desktop =
          Platform.environment["ORIGINAL_XDG_CURRENT_DESKTOP"]!.toLowerCase();
    } else if (Platform.environment.containsKey("XDG_CURRENT_DESKTOP")) {
      desktop = Platform.environment["XDG_CURRENT_DESKTOP"]!.toLowerCase();
    } else {
      return null;
    }

    if (desktop == null) {
      return null;
    } else if (desktop!.contains('gnome')) {
      return 'gnome';
    } else if (desktop!.contains('kde')) {
      return 'kde';
    } else {
      return null;
    }
  }

  @override
  Future<bool?> isEnabled() async {
    desktop = await _detectGui();
    try {
      final shell = Shell();

      if (desktop == 'gnome') {
        final result =
            await shell.run('gsettings get org.gnome.system.proxy mode');
        return result.outText.contains("'manual'");
      } else if (desktop == 'kde') {
        final result = await shell.run(
            'kwriteconfig5 --file kioslaverc --group "Proxy Settings" --key "ProxyType"');
        return result.outText.trim() == '1';
      }
      return null;
    } catch (e) {
      logger.e('PlatformSystemProxyUserLinux.isEnabled: $e');
      return null;
    }
  }

  @override
  Future<void> enable(Map<String, Tuple2<String, int>> proxies) async {
    try {
      final shell = Shell();

      if (desktop == 'gnome') {
        await shell.run('gsettings set org.gnome.system.proxy mode "manual"');

        for (var entry in proxies.entries) {
          String protocol = entry.key;
          Tuple2<String, int> hostPort = entry.value;

          if (protocol.toLowerCase() == 'socks') {
            await shell.run(
                'gsettings set org.gnome.system.proxy.socks host "${hostPort.item1}"');
            await shell.run(
                'gsettings set org.gnome.system.proxy.socks port ${hostPort.item2}');
          } else if (protocol.toLowerCase() == 'http') {
            await shell.run(
                'gsettings set org.gnome.system.proxy.http host "${hostPort.item1}"');
            await shell.run(
                'gsettings set org.gnome.system.proxy.http port ${hostPort.item2}');
          } else {
            throw UnsupportedError("Unsupported protocol: $protocol");
          }
        }
      } else if (desktop == 'kde') {
        /// kde support protocols one at a time
        bool hasSocks = false;
        for (var entry in proxies.entries) {
          String protocol = entry.key;
          Tuple2<String, int> hostPort = entry.value;

          if (protocol.toLowerCase() == 'socks') {
            hasSocks = true;
            await shell.run(
                'kwriteconfig5 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 1');
            await shell.run(
                'kwriteconfig5 --file kioslaverc --group "Proxy Settings" --key "socksProxy" "${hostPort.item1}:${hostPort.item2}"');
          } else if (protocol.toLowerCase() == 'http' && !hasSocks) {
            await shell.run(
                'kwriteconfig5 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 2');
            await shell.run(
                'kwriteconfig5 --file kioslaverc --group "Proxy Settings" --key "httpProxy" "${hostPort.item1}:${hostPort.item2}"');
          } else {
            throw UnsupportedError("Unsupported protocol: $protocol");
          }
        }
      }
    } catch (e) {
      logger.e('PlatformSystemProxyUserLinux.enable: $e');
    }
  }

  @override
  Future<void> disable() async {
    try {
      final shell = Shell();

      if (desktop == 'gnome') {
        await shell.run('gsettings set org.gnome.system.proxy mode "none"');
      } else if (desktop == 'kde') {
        await shell.run(
            'kwriteconfig5 --file kioslaverc --group "Proxy Settings" --key "ProxyType" 0');
      }
    } catch (e) {
      logger.e('PlatformSystemProxyUserLinux.disable: $e');
    }
  }
}

class PlatformSystemProxyUserAndroid extends PlatformSystemProxyUser {
  static const platform = MethodChannel('com.github.anyportal.anyportal');

  @override
  Future<bool?> isEnabled() async {
    return await platform.invokeMethod('vpn.getIsSystemProxyEnabled') as bool;
  }

  @override
  Future<void> enable(Map<String, Tuple2<String, int>> proxies) async {
    await platform.invokeMethod('vpn.startSystemProxy') as int;
    return;
  }

  @override
  Future<void> disable() async {
    await platform.invokeMethod('vpn.stopSystemProxy') as int;
    return;
  }
}

final platformSystemProxyUser = Platform.isWindows
    ? PlatformSystemProxyUserWindows()
    : Platform.isLinux
        ? PlatformSystemProxyUserLinux()
        : Platform.isMacOS
            ? PlatformSystemProxyUserMacOS()
            : Platform.isAndroid
                ? PlatformSystemProxyUserAndroid()
                : PlatformSystemProxyUser();
