import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:anyportal/utils/prefs.dart';

import 'logger.dart';
import 'platform_net_interface.dart';
import 'vpn_manager.dart';

class ConnectivityManager {
  late Future<NetInterface?> _effectiveNetInterfaceFutureCache;
  late Future<NetInterface?> _preEffectiveNetInterfaceFutureCache;

  Future<String?> getEffectiveDnsStr({bool ignoreCache = false}) async {
    if (ignoreCache) {
      _updateEffectiveNetInterface();
    }
    return _getEffectiveDnsStr(await _effectiveNetInterfaceFutureCache);
  }

  Future<String?> getEffectiveIpStr({bool ignoreCache = false}) async {
    if (ignoreCache) {
      _updateEffectiveNetInterface();
    }
    return _getEffectiveIpStr(await _effectiveNetInterfaceFutureCache);
  }

  String? _getFirstAddressStr(Address? address) {
    if (address == null) return null;
    if (address.ipv4.isNotEmpty) return address.ipv4.first;
    if (address.ipv6.isNotEmpty) return address.ipv6.first;
    return null;
  }

  String? _getEffectiveDnsStr(NetInterface? effectiveNetInterface) {
    return _getFirstAddressStr(effectiveNetInterface?.dns);
  }

  String? _getEffectiveIpStr(NetInterface? effectiveNetInterface) {
    return _getFirstAddressStr(effectiveNetInterface?.ip);
  }

  Future<NetInterface?> getEffectiveNetInterface(
      {bool ignoreCache = false}) async {
    if (ignoreCache) {
      _updateEffectiveNetInterface();
    }
    return _effectiveNetInterfaceFutureCache;
  }

  Future<void> _updateEffectiveNetInterface() async {
    _preEffectiveNetInterfaceFutureCache = _effectiveNetInterfaceFutureCache;
    _effectiveNetInterfaceFutureCache =
        PlatformNetInterface().getEffectiveNetInterface(
      excludeIPv4Set: {"172.19.0.1"},
      excludeIPv6Set: {"fdfe:dcba:9876::1"},
    );
    await _effectiveNetInterfaceFutureCache;
    return;
  }

  Future<bool> getHasEffectiveDnsChanged() async {
    final preEffectiveDnsStr =
        _getEffectiveDnsStr(await _preEffectiveNetInterfaceFutureCache);

    final effectiveDnsStr =
        _getEffectiveDnsStr(await _effectiveNetInterfaceFutureCache);

    final res = effectiveDnsStr != preEffectiveDnsStr;
    if (res) {
      logger.d("preEffectiveDnsStr: $preEffectiveDnsStr");
      logger.d("effectiveDnsStr: $effectiveDnsStr");
    }

    return res;
  }

  Future<bool> getHasEffectiveIpChanged() async {
    final preEffectiveIpStr =
        _getEffectiveIpStr(await _preEffectiveNetInterfaceFutureCache);

    final effectiveIpStr =
        _getEffectiveIpStr(await _effectiveNetInterfaceFutureCache);

    final res = effectiveIpStr != preEffectiveIpStr;
    if (res) {
      logger.d("preEffectiveIpStr: $preEffectiveIpStr");
      logger.d("effectiveIpStr: $effectiveIpStr");
    }

    return res;
  }

  Future<void> onEffectiveDnsChanged() async {
    if (prefs.getBool('inject.dns.local')! && vPNMan.isCoreActive) {
      await vPNMan.restartCore();
    }
  }

  Future<void> onEffectiveIpChanged() async {
    if (prefs.getBool('inject.sendThrough')! && vPNMan.isCoreActive) {
      await vPNMan.restartCore();
    }
  }

  Future<void> init() async {
    logger.d("starting: ConnectivityManager.init");
    _effectiveNetInterfaceFutureCache =
        PlatformNetInterface().getEffectiveNetInterface(
      excludeIPv4Set: {"172.19.0.1"},
      excludeIPv6Set: {"fdfe:dcba:9876::1"},
    );
    _preEffectiveNetInterfaceFutureCache = _effectiveNetInterfaceFutureCache;

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      logger.i("onConnectivityChanged: $result");

      getEffectiveNetInterface(ignoreCache: true).then((value) async {
        logger.i("effectiveNetInterface: $value");

        bool shouldRestartCore = false;
        if (await getHasEffectiveDnsChanged() &&
            prefs.getBool('inject.dns.local')!) {
          shouldRestartCore = true;
        }
        if (await getHasEffectiveIpChanged() &&
            prefs.getBool('inject.sendThrough')!) {
          shouldRestartCore = true;
        }

        if (shouldRestartCore && vPNMan.isCoreActive) {
          await vPNMan.restartCore();
        }
      });
    });
    _completer.complete();
    logger.d("finished: ConnectivityManager.init");
  }

  static final ConnectivityManager _instance = ConnectivityManager._internal();
  final Completer<void> _completer = Completer<void>();

  ConnectivityManager._internal();

  factory ConnectivityManager() {
    return _instance;
  }
}
