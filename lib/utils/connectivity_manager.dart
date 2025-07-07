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
      updateEffectiveNetInterface();
    }
    return _getEffectiveDnsStr(await _effectiveNetInterfaceFutureCache);
  }

  String? _getEffectiveDnsStr(NetInterface? effectiveNetInterface) {
    final dns = effectiveNetInterface?.dns;
    return dns?.ipv4.first ?? dns?.ipv6.first;
  }

  Future<NetInterface?> getEffectiveNetInterface(
      {bool ignoreCache = false}) async {
    if (ignoreCache) {
      updateEffectiveNetInterface();
    }
    return _effectiveNetInterfaceFutureCache;
  }

  Future<NetInterface?> updateEffectiveNetInterface() async {
    _preEffectiveNetInterfaceFutureCache = _effectiveNetInterfaceFutureCache;
    _effectiveNetInterfaceFutureCache =
        PlatformNetInterface().getEffectiveNetInterface(
      excludeIPv4Set: {"172.19.0.1"},
      excludeIPv6Set: {"fdfe:dcba:9876::1"},
    );
    return await _effectiveNetInterfaceFutureCache;
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

  Future<void> onEffectiveDnsChanged() async {
    if (prefs.getBool('inject.dns.local')! && vPNMan.isCoreActive) {
      await vPNMan.stopCore();
      await vPNMan.startCore();
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

      updateEffectiveNetInterface().then((_) async {
        return await getEffectiveNetInterface();
      }).then((value) {
        logger.i("effectiveNetInterface: $value");
      });
      getHasEffectiveDnsChanged().then((value) {
        if (value) {
          onEffectiveDnsChanged();
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
