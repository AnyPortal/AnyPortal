import 'dart:io';

import '../logger.dart';
import '../platform_net_interface.dart';

class PlatformNetInterfaceLinux implements PlatformNetInterface {
  @override
  Future<NetInterface?> getEffectiveNetInterface({
    Set<String> excludeIPv4Set = const {},
    Set<String> excludeIPv6Set = const {},
  }) async {
    try {
      // Get all default IPv4 routes
      final routeResult =
          await Process.run('ip', ['-4', 'route', 'show', 'default']);
      if (routeResult.exitCode != 0) {
        logger.w('Failed to get default routes: ${routeResult.stderr}');
        return null;
      }
      final routes = (routeResult.stdout as String)
          .split('\n')
          .where((l) => l.trim().isNotEmpty);

      final candidates = <Map<String, dynamic>>[];

      for (final line in routes) {
        final parts = line.split(' ');
        final devIndex = parts.indexOf('dev');
        if (devIndex == -1 || devIndex + 1 >= parts.length) continue;

        final dev = parts[devIndex + 1];
        int metric = 0;
        final metricIndex = parts.indexOf('metric');
        if (metricIndex != -1 && metricIndex + 1 < parts.length) {
          metric = int.tryParse(parts[metricIndex + 1]) ?? 0;
        }

        candidates.add({
          'interface': dev,
          'metric': metric,
        });
      }

      if (candidates.isEmpty) {
        logger.w('No default routes found');
        return null;
      }

      // Sort by metric
      candidates
          .sort((a, b) => (a['metric'] as int).compareTo(b['metric'] as int));

      String? chosenInterface;
      final iPv4AddressSet = <String>{};
      final iPv6AddressSet = <String>{};
      for (final cand in candidates) {
        final dev = cand['interface'] as String;

        // Get IPs
        final addrResult =
            await Process.run('ip', ['addr', 'show', 'dev', dev]);
        if (addrResult.exitCode != 0) continue;

        final addrLines = (addrResult.stdout as String).split('\n');
        iPv4AddressSet.clear();
        iPv6AddressSet.clear();
        for (final line in addrLines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('inet ')) {
            iPv4AddressSet.add(trimmed.split(' ')[1].split('/')[0]);
          } else if (trimmed.startsWith('inet6 ')) {
            iPv6AddressSet.add(trimmed.split(' ')[1].split('/')[0]);
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

      // Get DNS for this interface
      final resolvectl =
          await Process.run('resolvectl', ['dns', chosenInterface]);
      final Set<String> dnsIPv4AddressSet = {};
      final Set<String> dnsIPv6AddressSet = {};
      if (resolvectl.exitCode == 0) {
        final output = (resolvectl.stdout as String).trim();
        if (output.isNotEmpty) {
          final colonSplit = output.split(':');
          if (colonSplit.length >= 2) {
            final ips = colonSplit[1].trim().split(RegExp(r'\s+'));
            for (final ip in ips) {
              if (ip.contains('%')) {
                /// ipv6 local address to a specific interface, ignore for now
              } else if (ip.contains(':')) {
                dnsIPv6AddressSet.add(ip);
              } else {
                dnsIPv4AddressSet.add(ip);
              }
            }
          }
        }
      } else {
        // fallback to resolv.conf
        final resolvConf = await File('/etc/resolv.conf').readAsLines();
        for (final line in resolvConf) {
          final trimmed = line.trim();
          if (trimmed.startsWith('nameserver')) {
            final parts = trimmed.split(RegExp(r'\s+'));
            if (parts.length >= 2) {
              final ip = parts[1];
              if (ip.contains(':')) {
                dnsIPv6AddressSet.add(ip);
              } else {
                dnsIPv4AddressSet.add(ip);
              }
            }
          }
        }
      }
      return NetInterface(
        chosenInterface,
        Address(iPv4AddressSet, iPv6AddressSet),
        Address(dnsIPv4AddressSet, dnsIPv6AddressSet),
      );
    } catch (e) {
      logger.e('getEffectiveDns (Linux) error: $e');
      return null;
    }
  }
}
