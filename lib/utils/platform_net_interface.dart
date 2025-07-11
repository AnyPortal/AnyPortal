import 'dart:io';

import 'logger.dart';
import 'platform_net_interface/linux.dart';
import 'platform_net_interface/macos.dart';
import 'platform_net_interface/windows.dart';
import 'runtime_platform.dart';

class PlatformNetInterface {
  factory PlatformNetInterface() {
    if (RuntimePlatform.isWindows) {
      return PlatformNetInterfaceWindows();
    } else if (Platform.isLinux) {
      return PlatformNetInterfaceLinux();
    } else if (Platform.isMacOS) {
      return PlatformNetInterfaceMacOS();
    } else {
      logger.w('PlatformNetInterface: unsupported OS');
      return PlatformNetInterface._();
    }
  }

  PlatformNetInterface._();

  Future<NetInterface?> getEffectiveNetInterface({
    Set<String> excludeIPv4Set = const {},
    Set<String> excludeIPv6Set = const {},
  }) async {
    return null;
  }
}

class NetInterface {
  String name;
  Address ip;
  Address dns;

  NetInterface(this.name, this.ip, this.dns);

  @override
  String toString() {
    return 'NetInterface(name: $name, ip: $ip, dns: $dns)';
  }
}

class Address {
  Set<String> ipv4;
  Set<String> ipv6;

  Address(this.ipv4, this.ipv6);

  @override
  String toString() {
    return 'Address(ipv4: $ipv4, ipv6: $ipv6)';
  }
}
