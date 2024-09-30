import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

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

abstract class CoreManager {
  // bool _on = false;
  bool? _justOn;
  Future<bool> on();
  Future<void> start() async {
    if (await on()) {
      return;
    }
    await init();

    // clear logs
    await File(p.join(folder.path, 'fv2ray', 'core.log')).writeAsString("");

    return _start();
  }

  Future<void> stop() async {
    if (!await on()) {
      return;
    }
    return _stop();
  }

  void _start();
  void _stop();

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
class CoreManagerExec extends CoreManager {
  Process? process;
  int? pid;

  @override
  Future<bool> on() async {
    if (_justOn != null) return _justOn!;
    final port = prefs.getInt('inject.api.port') ?? 15490;
    pid = await getPidOfPort(port);
    return pid != null;
    // return _on;
  }

  @override
  void _start() async {
    process = await Process.start(_corePath!, _coreArgList,
        environment: _environment);

    _justOn = true;
    // _on = true;
    return;
  }

  @override
  void _stop() {
    if (process != null) {
      process!.kill();
      _justOn = false;
      return;
    }
    if (pid != null) {
      Process.killPid(pid!);
      _justOn = false;
      return;
    }
    // _on = false;
    _justOn = false;
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

class CoreManagerMC extends CoreManager {

  static const platform = MethodChannel('com.github.fv2ray.fv2ray');

  @override
  Future<bool> on() async {
    if (_justOn != null) return _justOn!;
    return await platform.invokeMethod('isTProxyServiceRunning');
  }

  @override
  void _start() async {
    await platform.invokeMethod('startTProxyService');
    _justOn = true;
  }

  @override
  void _stop() async {
    await platform.invokeMethod('stopTProxyService');
    _justOn = false;
  }
}

class CoreManManager {
  static final CoreManManager _instance = CoreManManager._internal();
  final Completer<void> _completer = Completer<void>();
  late CoreManager _coreMan;
  // Private constructor
  CoreManManager._internal();

  // Singleton accessor
  factory CoreManManager() {
    return _instance;
  }

  // Async initializer (call once at app startup)
  Future<void> init() async {
    _coreMan =
        Platform.isAndroid || Platform.isIOS ? CoreManagerMC() : CoreManagerExec();
    _completer.complete(); // Signal that initialization is complete
  }
}

final coreMan = CoreManManager()._coreMan;
