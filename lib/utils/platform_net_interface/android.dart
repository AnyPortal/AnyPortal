import 'package:anyportal/utils/method_channel.dart';

import '../platform_net_interface.dart';

class PlatformNetInterfaceAndroid implements PlatformNetInterface {
  @override
  Future<NetInterface?> getEffectiveNetInterface({
    Set<String> excludeIPv4Set = const {},
    Set<String> excludeIPv6Set = const {},
  }) async {
    final linkPropertiesMap = await mCMan.methodChannel
        .invokeMapMethod("os.getEffectiveLinkProperties");
    if (linkPropertiesMap == null) return null;
    final linkProperties = LinkProperties.fromMap(linkPropertiesMap);
    final iPv4AddressSet = <String>{};
    final iPv6AddressSet = <String>{};
    final Set<String> dnsIPv4AddressSet = {};
    final Set<String> dnsIPv6AddressSet = {};
    for (final s in linkProperties.dnsServers) {
      if (s.contains('%')) {
        /// ipv6 local address to a specific interface, ignore for now
      } else if (s.contains(":")) {
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

  factory LinkProperties.fromMap(Map map) {
    return LinkProperties(
      interfaceName: map['interfaceName'],
      dnsServers: List<String>.from(map['dnsServers']),
      linkAddresses: List<String>.from(map['linkAddresses']),
    );
  }
}
