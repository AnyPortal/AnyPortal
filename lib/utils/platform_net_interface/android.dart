import 'dart:convert';

import 'package:anyportal/utils/method_channel.dart';

import '../platform_net_interface.dart';

class PlatformNetInterfaceAndroid implements PlatformNetInterface {
  @override
  Future<NetInterface?> getEffectiveNetInterface({
    Set<String> excludeIPv4Set = const {},
    Set<String> excludeIPv6Set = const {},
  }) async {
    final linkPropertiesStr = await mCMan.methodChannel
        .invokeMethod("os.getEffectiveLinkProperties") as String?;
    if (linkPropertiesStr == null) return null;
    final lpJson = jsonDecode(linkPropertiesStr) as Map<String, dynamic>;
    final linkProperties = LinkProperties.fromJson(lpJson);
    final iPv4AddressSet = <String>{};
    final iPv6AddressSet = <String>{};
    final Set<String> dnsIPv4AddressSet = {};
    final Set<String> dnsIPv6AddressSet = {};
    for (final s in linkProperties.dnsServers) {
      if (s.contains(":")) {
        dnsIPv6AddressSet.add(s);
      } else {
        dnsIPv4AddressSet.add(s);
      }
    }
    for (final s in linkProperties.linkAddresses) {
      if (s.contains(":")) {
        iPv6AddressSet.add(s);
      } else {
        iPv4AddressSet.add(s);
      }
    }
    return NetInterface(
      linkProperties.interfaceName,
      Address(iPv4AddressSet, iPv6AddressSet),
      Address(dnsIPv4AddressSet, dnsIPv6AddressSet),
    );
  }
}

class LinkProperties {
  final String interfaceName;
  final List<String> dnsServers;
  final List<String> linkAddresses;

  LinkProperties(
      {required this.interfaceName,
      required this.dnsServers,
      required this.linkAddresses});

  factory LinkProperties.fromJson(Map<String, dynamic> json) {
    return LinkProperties(
      interfaceName: json['interfaceName'],
      dnsServers: List<String>.from(json['dnsServers']),
      linkAddresses: List<String>.from(json['linkAddresses']),
    );
  }
}
