import 'dart:convert';
import 'dart:io';

import '../logger.dart';
import '../platform_net_interface.dart';

class PlatformNetInterfaceWindows implements PlatformNetInterface {
  // ignore: constant_identifier_names
  static const AF_INET = 2;
  // ignore: constant_identifier_names
  static const AF_INET6 = 23;

  @override
  Future<NetInterface?> getEffectiveNetInterface({
    Set<String> excludeIPv4Set = const {},
    Set<String> excludeIPv6Set = const {},
  }) async {
    final defaultNetRouteListFuture = getWindowsdefaultNetRouteList();
    // final netIPInterfaceListFuture = getWindowsNetIPInterfaceList();
    final netAdapterListFuture = getWindowsNetAdapterList();
    final netIPAddressListFuture = getWindowsNetIPAddressList();

    final dnsClientServerAddressListFuture =
        getWindowsDnsClientServerAddressList();
    final defaultNetRouteList = await defaultNetRouteListFuture;
    final defaultNetRouteMap = getMapOfInterfaceIndex(defaultNetRouteList);

    /// InterfaceIndex => EffectiveMetric = RouteMetric + InterfaceMetric
    Map<int, int> effectiveMetrics = {};
    for (final e in defaultNetRouteMap.entries) {
      final interfaceIndex = e.key;
      final route = e.value;
      final routeMetric = route["RouteMetric"] as int;
      // final netIPInterface = netIPInterfaceMap[interfaceIndex]!;
      // final interfaceMetricNullable = netIPInterface["InterfaceMetric"];
      final interfaceMetricNullable = route["InterfaceMetric"];
      final interfaceMetric =
          interfaceMetricNullable == null ? 0 : interfaceMetricNullable as int;
      effectiveMetrics[interfaceIndex] = routeMetric + interfaceMetric;
    }

    /// find the actual interface from the lowest metric to highest
    final sortedEffectiveMetrics = effectiveMetrics.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final netIPAddressList = await netIPAddressListFuture;
    final netIPAddressListMap = getListMapOfInterfaceIndex(netIPAddressList);
    final netAdapterList = await netAdapterListFuture;
    final netAdapterMap = getMapOfInterfaceIndex(netAdapterList);
    int chosenInterfaceIndex = 0;
    bool chosenInterfaceFound = false;
    final Set<String> iPv4AddressSet = {};
    final Set<String> iPv6AddressSet = {};
    for (final e in sortedEffectiveMetrics) {
      final interfaceIndex = e.key;

      final netAdapter = netAdapterMap[interfaceIndex]!;
      if (netAdapter["Status"] != "Up") {
        continue;
      }

      iPv4AddressSet.clear();
      iPv6AddressSet.clear();
      for (final netIPAddress in netIPAddressListMap[interfaceIndex]!) {
        if (netIPAddress["AddressFamily"] == AF_INET) {
          iPv4AddressSet.add(netIPAddress["IPv4Address"]);
        } else if (netIPAddress["AddressFamily"] == AF_INET6) {
          iPv6AddressSet.add(netIPAddress["IPv6Address"]);
        }
      }

      /// exclude some interfaces
      if (excludeIPv4Set.intersection(iPv4AddressSet).isNotEmpty ||
          excludeIPv6Set.intersection(iPv6AddressSet).isNotEmpty) {
        continue;
      } else {
        chosenInterfaceFound = true;
        chosenInterfaceIndex = interfaceIndex;
        break;
      }
    }
    if (!chosenInterfaceFound) {
      return null;
    }

    /// return the dns of choseInterface
    /// new query too slow at this point, instead just query entire list at the beginning
    // final effectiveDnsClientServerAddressList =
    //     await getWindowsDnsClientServerAddressListOfNetIPInterface(
    //         chosenInterfaceIndex);
    final dnsClientServerAddressList = await dnsClientServerAddressListFuture;
    final dnsClientServerAddressListMap =
        getListMapOfInterfaceIndex(dnsClientServerAddressList);
    final effectiveDnsClientServerAddressList =
        dnsClientServerAddressListMap[chosenInterfaceIndex]!;
    // final netIPInterfaceList = await netIPInterfaceListFuture;
    // Map<int, Map<String, dynamic>> netIPInterfaceMap =
    //     getMapOfInterfaceIndex(netIPInterfaceList);
    final chosenInterfaceAlias =
        defaultNetRouteMap[chosenInterfaceIndex]!["InterfaceAlias"] as String;
    final Set<String> dnsIPv4AddressSet = {};
    final Set<String> dnsIPv6AddressSet = {};
    for (final e in effectiveDnsClientServerAddressList) {
      if (e["AddressFamily"] == AF_INET) {
        dnsIPv4AddressSet
            .addAll((e["ServerAddresses"] as List).cast<String>().toSet());
      } else if (e["AddressFamily"] == AF_INET6) {
        final serverAddresses = (e["ServerAddresses"] as List).cast<String>();
        for (final serverAddress in serverAddresses) {
          if (serverAddress.contains('%')) {
            /// ipv6 local address to a specific interface, ignore for now
            continue;
          } else {
            dnsIPv6AddressSet.add(serverAddress);
          }
        }
      }
    }
    return NetInterface(
      chosenInterfaceAlias,
      Address(iPv4AddressSet, iPv6AddressSet),
      Address(dnsIPv4AddressSet, dnsIPv6AddressSet),
    );
  }

  List<Map<String, dynamic>> getListMap(dynamic decoded) {
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    } else if (decoded is Map) {
      return [decoded as Map<String, dynamic>];
    } else {
      logger.w("getListMap: failed");
      return [];
    }
  }

  Future<ProcessResult> getWindowsPowerShellResult(String cmd) async {
    return await Process.run(
      'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
      ['-noprofile', cmd],
    );
  }

  Future<List<Map<String, dynamic>>> getWindowsPowerShellResultListMap(
      String cmd) async {
    final result = await getWindowsPowerShellResult(cmd);
    return getListMap(jsonDecode(result.stdout));
  }

  Future<List<Map<String, dynamic>>> getWindowsdefaultNetRouteList() async {
    return await getWindowsPowerShellResultListMap(
        'Get-NetRoute -DestinationPrefix 0.0.0.0/0 | ConvertTo-Json');
  }

  Future<List<Map<String, dynamic>>> getWindowsNetIPInterfaceList() async {
    return await getWindowsPowerShellResultListMap(
      'Get-NetIPInterface | ConvertTo-Json',
    );
  }

  Future<List<Map<String, dynamic>>>
      getWindowsDnsClientServerAddressListOfNetIPInterface(
          int interfaceIndex) async {
    return await getWindowsPowerShellResultListMap(
      'Get-DnsClientServerAddress -InterfaceIndex $interfaceIndex | ConvertTo-Json',
    );
  }

  Future<List<Map<String, dynamic>>>
      getWindowsDnsClientServerAddressList() async {
    return await getWindowsPowerShellResultListMap(
      'Get-DnsClientServerAddress | ConvertTo-Json',
    );
  }

  Future<List<Map<String, dynamic>>> getWindowsNetIPAddressList() async {
    return await getWindowsPowerShellResultListMap(
      'Get-NetIPAddress | ConvertTo-Json',
    );
  }

  Future<List<Map<String, dynamic>>> getWindowsNetAdapterList() async {
    return await getWindowsPowerShellResultListMap(
      'Get-NetAdapter | ConvertTo-Json',
    );
  }

  Map<int, Map<String, dynamic>> getMapOfInterfaceIndex(
      List<Map<String, dynamic>> l) {
    final Map<int, Map<String, dynamic>> res = {};
    for (final e in l) {
      // if (!e.containsKey("InterfaceIndex")) continue;
      final interfaceIndex = e["InterfaceIndex"] as int;
      res[interfaceIndex] = e;
    }
    return res;
  }

  Map<int, List<Map<String, dynamic>>> getListMapOfInterfaceIndex(
      List<Map<String, dynamic>> l) {
    final Map<int, List<Map<String, dynamic>>> res = {};
    for (final e in l) {
      // if (!e.containsKey("InterfaceIndex")) continue;
      final interfaceIndex = e["InterfaceIndex"] as int;
      if (!res.containsKey(interfaceIndex)) {
        res[interfaceIndex] = [];
      }
      res[interfaceIndex]!.add(e);
    }
    return res;
  }
}
