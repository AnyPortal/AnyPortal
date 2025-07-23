import 'dart:io';

import '../logger.dart';
import '../platform_net_interface.dart';

class PlatformNetInterfaceMacOS implements PlatformNetInterface {
  @override
  Future<NetInterface?> getEffectiveNetInterface({
    Set<String> excludeIPv4Set = const {},
    Set<String> excludeIPv6Set = const {},
  }) async {
    try {
      // Get all default IPv4 routes
      final routeResult = await Process.run('netstat', ['-rn', '-f', 'inet']);
      if (routeResult.exitCode != 0) {
        logger.w('Failed to get default routes: ${routeResult.stderr}');
        return null;
      }

      final lines = (routeResult.stdout as String).split('\n');
      final candidates = <Map<String, dynamic>>[];

      bool inInternetSection = false;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed == 'Internet:') {
          inInternetSection = true;
          continue;
        }
        if (trimmed == 'Internet6:') {
          inInternetSection = false;
          continue;
        }
        if (!inInternetSection || trimmed.isEmpty) continue;

        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length < 4) continue;
        final destination = parts[0];
        final netif = parts[3];

        if (destination == 'default') {
          candidates.add({
            'interface': netif,
          });
        }
      }

      if (candidates.isEmpty) {
        logger.w('No default routes found');
        return null;
      }

      String? chosenInterface;
      final iPv4AddressSet = <String>{};
      final iPv6AddressSet = <String>{};

      for (final cand in candidates) {
        final dev = cand['interface'] as String;

        // Get IPs
        final ifconfigResult = await Process.run('ifconfig', [dev]);
        if (ifconfigResult.exitCode != 0) continue;

        final addrLines = (ifconfigResult.stdout as String).split('\n');
        iPv4AddressSet.clear();
        iPv6AddressSet.clear();
        for (final line in addrLines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('inet ')) {
            iPv4AddressSet.add(trimmed.split(' ')[1]);
          } else if (trimmed.startsWith('inet6 ')) {
            iPv6AddressSet.add(trimmed.split(' ')[1]);
          }
        }

        if (excludeIPv4Set.intersection(iPv4AddressSet).isNotEmpty ||
            excludeIPv6Set.intersection(iPv6AddressSet).isNotEmpty) {
          continue; // skip
        } else {
          chosenInterface = dev;
          break;
        }
      }

      if (chosenInterface == null) {
        logger.w('No suitable interface found');
        return null;
      }

      // Get DNS via scutil --dns
      final scutilResult = await Process.run('scutil', ['--dns']);
      if (scutilResult.exitCode != 0) {
        logger.w('Failed to get DNS from scutil: ${scutilResult.stderr}');
        return null;
      }

      final dnsLines = (scutilResult.stdout as String).split('\n');
      final Set<String> dnsIPv4AddressSet = {};
      final Set<String> dnsIPv6AddressSet = {};
      List<String> tempServers = [];
      bool matchingBlock = false;

      for (final line in dnsLines) {
        final trimmed = line.trim();

        if (trimmed.startsWith('resolver #')) {
          // New block — reset
          tempServers = [];
          matchingBlock = false;
        }

        if (trimmed.startsWith('nameserver')) {
          final parts = trimmed.split(' : ');
          if (parts.length >= 2) {
            final ip = parts[1].trim();
            tempServers.add(ip);
          }
        }

        if (trimmed.startsWith('if_index') &&
            trimmed.contains(chosenInterface)) {
          // Found a matching interface
          matchingBlock = true;
        }

        if (matchingBlock && tempServers.isNotEmpty) {
          // Add collected servers
          for (final ip in tempServers) {
            if (ip.contains('%')) {
              /// ipv6 local address to a specific interface, ignore for now
            } else if (ip.contains(':')) {
              dnsIPv6AddressSet.add(ip);
            } else {
              dnsIPv4AddressSet.add(ip);
            }
          }
          tempServers = []; // clear so we don’t double-count
        }
      }

      return NetInterface(
        chosenInterface,
        Address(iPv4AddressSet, iPv6AddressSet),
        Address(dnsIPv4AddressSet, dnsIPv6AddressSet),
      );
    } catch (e) {
      logger.e('getEffectiveDns (macOS) error: $e');
      return null;
    }
  }
}
