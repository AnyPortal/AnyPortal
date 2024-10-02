import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

import 'config_injector.dart';
import 'db.dart';
import 'prefs.dart';
import 'get_pid_of_port.dart';

class NoCorePathException implements Exception {
  String cause;
  NoCorePathException(this.cause);
}

class NoSelectedProfileException implements Exception {
  String cause;
  NoSelectedProfileException(this.cause);
}

class InvalidSelectedProfileException implements Exception {
  String cause;
  InvalidSelectedProfileException(this.cause);
}

abstract class VPNManager with ChangeNotifier {
  bool isToggling = false;
  bool isActive = false;
  bool isExpectingActive = false;

  Future<bool> _getIsActive();
  Future<void> _start();
  Future<void> _stop();

  void _setIsToggling(bool val) {
    if (isToggling != val) {
      isToggling = val;
      notifyListeners();
    }
  }

  Future<bool> updateIsActive() async {
    final newIsActive = await _getIsActive();
    if (isActive != newIsActive) {
      isActive = newIsActive;
      notifyListeners();
    }
    return isActive;
  }

  void _setIsActive(bool val) {
    if (isActive != val) {
      isActive = val;
      notifyListeners();
    }
  }

  Future<void> start() async {
    if (isToggling) return;
    _setIsToggling(true);
    isExpectingActive = true;
    if (await updateIsActive()) {
      return;
    }
    await init();

    // clear logs
    await File(p.join(folder.path, 'fv2ray', 'core.log')).writeAsString("");

    await _start();
  }

  Future<void> stop() async {
    if (isToggling) return;
    _setIsToggling(true);
    isExpectingActive = false;
    if (!await updateIsActive()) {
      return;
    }
    await _stop();
  }

  late int? _selectedProfileId;
  late ProfileData? _selectedProfile;
  late bool _useEmbedded;
  late String? _corePath;
  late String? _assetPath;
  late List<String> _coreArgList;
  late Map<String, String>? _environment;
  late Map<String, dynamic> rawCfg;
  late Directory folder;

  Future<void> init() async {
    // get selectedProfile
    _selectedProfileId = prefs.getInt('app.selectedProfileId');
    if (_selectedProfileId == null) {
      throw NoSelectedProfileException("Please select a profile first.");
    }
    _selectedProfile = await (db.select(db.profile)
          ..where((p) => p.id.equals(_selectedProfileId!)))
        .getSingleOrNull();
    if (_selectedProfile == null) {
      throw InvalidSelectedProfileException("Please select a profile first.");
    }

    // gen config.json
    folder = await getApplicationDocumentsDirectory();
    final config = File(p.join(folder.path, 'fv2ray', 'config.gen.json'));
    rawCfg = jsonDecode(_selectedProfile!.coreCfg) as Map<String, dynamic>;
    final cfg = await getInjectedConfig(rawCfg);
    await config.writeAsString(jsonEncode(cfg));

    // check core path
    _useEmbedded = prefs.getBool('core.useEmbedded')!;
    _corePath = prefs.getString('core.path');
    if (!_useEmbedded && _corePath == null) {
      throw NoCorePathException("Core path not set. Check `Settings`->`Core`.");
    }

    // get core asset
    _assetPath = prefs.getString('core.assetPath') ?? "";
    if (_assetPath != null) {
      _environment = {
        "v2ray.location.asset": _assetPath!,
        "xray.location.asset": _assetPath!,
      };
    }

    // get core args
    _coreArgList = ["run", "-c", config.path];
  }
}

/// Direct process exec, need foreground, typically for PC
class VPNManagerExec extends VPNManager {
  Process? process;
  int? pid;

  @override
  Future<bool> _getIsActive() async {
    if (process != null) {
      return true;
    } else {
      final port = prefs.getInt('inject.api.port') ?? 15490;
      pid = await getPidOfPort(port);
      return pid != null;
    }
  }

  @override
  _start() async {
    process = await Process.start(_corePath!, _coreArgList,
        environment: _environment);
    await updateIsActive();
    _setIsToggling(false);
    return;
  }

  @override
  _stop() async {
    if (process != null) {
      process!.kill();
      process = null;
      await updateIsActive();
      _setIsToggling(false);
      return;
    }
    if (pid != null) {
      Process.killPid(pid!);
      await updateIsActive();
      _setIsToggling(false);
      return;
    }
    await updateIsActive();
    _setIsToggling(false);
    return;
  }

  Future<bool> isPortOccupied(int port) async {
    try {
      await ServerSocket.bind(InternetAddress.anyIPv4, port);
      return false; // Port is available
    } on SocketException catch (e) {
      log("$e");
      return true; // Port is occupied
    }
    // return false;
    // catch (e) {
    //   rethrow; // Rethrow other exceptions for debugging
    // }
  }
}

class VPNManagerMC extends VPNManager {
  static const platform = MethodChannel('com.github.fv2ray.fv2ray');

  VPNManagerMC() {
    platform.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == 'onVPNConnected' || call.method == 'onVPNDisconnected') {
      final newIsActive = call.method == 'onVPNConnected';
      _setIsActive(newIsActive);
      if (newIsActive == isExpectingActive){
        _setIsToggling(false);
      }
    } else if (call.method == 'onTileToggled') {
      isExpectingActive = call.arguments as bool;
      _setIsToggling(true);
    }
  }

  @override
  Future<bool> _getIsActive() async {
    return await platform.invokeMethod('isTProxyServiceRunning');
  }

  @override
  _start() async {
    await platform.invokeMethod('startTProxyService');
  }

  @override
  _stop() async {
    await platform.invokeMethod('stopTProxyService');
  }
}

class VPNManManager {
  static final VPNManManager _instance = VPNManManager._internal();
  final Completer<void> _completer = Completer<void>();
  late VPNManager _vPNMan;
  // Private constructor
  VPNManManager._internal();

  // Singleton accessor
  factory VPNManManager() {
    return _instance;
  }

  // Async initializer (call once at app startup)
  Future<void> init() async {
    _vPNMan = Platform.isAndroid || Platform.isIOS
        ? VPNManagerMC()
        : VPNManagerExec();
    _completer.complete(); // Signal that initialization is complete
  }
}

final vPNMan = VPNManManager()._vPNMan;
