import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anyportal/models/core.dart';
import 'package:anyportal/utils/platform_system_proxy_user.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'config_injector/core_ray.dart';
import 'config_injector/tun_sing_box.dart';
import 'db.dart';
import 'global.dart';
import 'logger.dart';
import 'platform_process.dart';
import 'prefs.dart';
import 'db/update_profile_with_group_remote.dart';

class ExceptionInvalidCorePath implements Exception {
  String message;
  ExceptionInvalidCorePath(this.message);
}

class ExceptionNoSelectedProfile implements Exception {
  String message;
  ExceptionNoSelectedProfile(this.message);
}

class ExceptionInvalidSelectedProfile implements Exception {
  String message;
  ExceptionInvalidSelectedProfile(this.message);
}

abstract class VPNManager with ChangeNotifier {
  bool isToggling = false;
  bool isCoreActive = false;
  bool isTunActive = false;
  bool isExpectingActive = false;

  Future<void> startAll();
  Future<void> stopAll();
  Future<void> startCore();
  Future<void> stopCore();
  Future<void> startTun();
  Future<void> stopTun();

  startSystemProxy() async {
    if (prefs.getBool("systemProxy")!) {
      String serverAddress = prefs.getString('app.server.address')!;
      if (serverAddress == "0.0.0.0") {
        serverAddress = "127.0.0.1";
      }
      await platformSystemProxyUser.enable({
        'socks': Tuple2(serverAddress, prefs.getInt("app.socks.port")!),
        'http': Tuple2(serverAddress, prefs.getInt("app.http.port")!),
      });
    }
  }

  stopSystemProxy() async {
    await platformSystemProxyUser.disable();
  }

  Future<Null>? delayedTogglingChecker;

  void setIsToggling(bool val) {
    if (isToggling != val) {
      isToggling = val;
      notifyListeners();
    }

    /// with timeout
    const timeoutSec = 5;
    if (isToggling) {
      delayedTogglingChecker =
          Future.delayed(const Duration(seconds: timeoutSec), () {
        if (isToggling) {
          logger.w("toggled for $timeoutSec sec, force stopped");
          updateIsCoreActive();
        }
      });
    }
  }

  Future<bool> getIsCoreActive();
  Future<bool> getIsTunActive();

  Future<void> setIsCoreActive(value) async {
    if (value == isCoreActive) {
      return;
    }
    isCoreActive = value;
    notifyListeners();
    setIsToggling(false);
  }

  Future<void> setIsTunActive(value) async {
    if (value == isTunActive) {
      return;
    }
    isTunActive = value;
  }

  Future<void> updateIsCoreActive() async {
    await setIsCoreActive(await getIsCoreActive());
  }

  Future<void> updateIsTunActive() async {
    await setIsTunActive(await getIsTunActive());
  }

  Future<void> updateDetachedCore() async {
    await updateIsCoreActive();
  }

  Future<void> updateDetachedTun() async {
    await updateIsTunActive();
  }

  Future<void> start() async {
    /// check is toggling
    if (isToggling) return;
    setIsToggling(true);
    isExpectingActive = true;

    /// check is already active
    if (await getIsCoreActive()) {
      setIsToggling(false);
      return;
    }

    /// start
    await startAll();
  }

  Future<void> stop() async {
    /// check is toggling
    if (isToggling) return;
    setIsToggling(true);
    isExpectingActive = false;

    /// check is already inactive
    if (!await getIsCoreActive()) {
      setIsToggling(false);
      return;
    }

    /// stop
    await stopAll();
  }

  int? _selectedProfileId;
  ProfileData? _selectedProfile;
  late bool _isExec;

  String? corePath;
  late List<String> _coreArgList;
  String? _coreWorkingDir;
  Map<String, String>? _coreEnvs;

  String? _tunSingBoxCorePath;
  late List<String> _tunSingBoxCoreArgList;
  String? _tunSingBoxCoreWorkingDir;
  Map<String, String>? _tunSingBoxCoreEnvs;

  late Map<String, dynamic> coreRawCfgMap;

  bool getIsTunExec() {
    return prefs.getBool("tun")! &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  Future<void> initCore() async {
    // get selectedProfile
    _selectedProfileId = prefs.getInt('app.selectedProfileId');
    if (_selectedProfileId == null) {
      throw ExceptionNoSelectedProfile("Please select a profile first.");
    }
    _selectedProfile = await (db.select(db.profile)
          ..where((p) => p.id.equals(_selectedProfileId!)))
        .getSingleOrNull();
    if (_selectedProfile == null) {
      throw ExceptionInvalidSelectedProfile("Please select a profile first.");
    }

    // check update
    updateProfileWithGroupRemote(_selectedProfile!);

    // gen config.json
    final config = File(p.join(global.applicationSupportDirectory.path, 'conf', 'core.gen.json'));
    if (!await config.exists()) {
      await config.create(recursive: true);
    }
    coreRawCfgMap =
        jsonDecode(_selectedProfile!.coreCfg) as Map<String, dynamic>;
    if (_selectedProfile!.coreTypeId == CoreTypeDefault.v2ray.index ||
        _selectedProfile!.coreTypeId == CoreTypeDefault.xray.index) {
      coreRawCfgMap = await getInjectedConfig(coreRawCfgMap);
    }
    await config.writeAsString(jsonEncode(coreRawCfgMap));

    // check core path
    final coreTypeId = _selectedProfile!.coreTypeId;
    final core = await (db.select(db.coreTypeSelected).join([
      leftOuterJoin(db.core, db.coreTypeSelected.coreId.equalsExp(db.core.id)),
      leftOuterJoin(db.coreExec, db.core.id.equalsExp(db.coreExec.coreId)),
      leftOuterJoin(db.coreLib, db.core.id.equalsExp(db.coreLib.coreId)),
      leftOuterJoin(db.coreType, db.core.coreTypeId.equalsExp(db.coreType.id)),
      leftOuterJoin(db.asset, db.coreExec.assetId.equalsExp(db.asset.id)),
    ])
          ..where(db.core.coreTypeId.equals(coreTypeId)))
        .getSingleOrNull();
    if (core == null) {
      throw ExceptionInvalidCorePath(
          "No core of type specified by the profile is selected.");
    }
    _isExec = core.read(db.core.isExec)!;
    if (_isExec) {
      await prefs.setBool("core.useEmbedded", false);
      corePath = core.read(db.asset.path);
      if (corePath == null) {
        throw ExceptionInvalidCorePath("Core path is null.");
      } else {
        prefs.setString('core.path', corePath!);
      }
      _coreWorkingDir ??= File(corePath!).parent.path;
    } else {
      await prefs.setBool("core.useEmbedded", true);
    }

    // get core env
    _coreEnvs = (jsonDecode(core.read(db.core.envs)!) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));

    // get core args
    final replacements = {
      "{config.path}": config.path,
    };
    List<String> rawCoreArgList =
        (jsonDecode(core.read(db.coreExec.args)!) as List<dynamic>)
            .map((e) => e as String)
            .toList();
    if (rawCoreArgList.isEmpty) {
      rawCoreArgList = ["run", "-c", "{config.path}"];
    }
    _coreArgList = rawCoreArgList;
    for (int i = 0; i < _coreArgList.length; ++i) {
      for (var entry in replacements.entries) {
        _coreArgList[i] = _coreArgList[i].replaceAll(entry.key, entry.value);
      }
    }

    // clear core log
    await File(p.join(
      global.applicationSupportDirectory.path,
      'log',
      'core.log',
    )).writeAsString("");
  }

  Future<void> initTunExec() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final coreTypeId = CoreTypeDefault.singBox.index;
      final core = await (db.select(db.coreTypeSelected).join([
        leftOuterJoin(
            db.core, db.coreTypeSelected.coreId.equalsExp(db.core.id)),
        leftOuterJoin(db.coreExec, db.core.id.equalsExp(db.coreExec.coreId)),
        leftOuterJoin(db.coreLib, db.core.id.equalsExp(db.coreLib.coreId)),
        leftOuterJoin(
            db.coreType, db.core.coreTypeId.equalsExp(db.coreType.id)),
        leftOuterJoin(db.asset, db.coreExec.assetId.equalsExp(db.asset.id)),
      ])
            ..where(db.core.coreTypeId.equals(coreTypeId)))
          .getSingleOrNull();

      if (prefs.getBool("tun")!) {
        if (core == null) {
          throw Exception("Tun needs a sing-box core.");
        } else {
          _tunSingBoxCorePath = core.read(db.asset.path);
          if (_tunSingBoxCorePath == null) {
            throw Exception("sing-box path is null.");
          } else {
            prefs.setString('tun.singBox.core.path', _tunSingBoxCorePath!);
          }
          _tunSingBoxCoreWorkingDir ??= File(_tunSingBoxCorePath!).parent.path;
        }

        /// gen config.json
        final tunSingBoxUserConfig = File(p.join(
          global.applicationDocumentsDirectory.path,
          'AnyPortal',
          'conf',
          'tun.sing_box.json',
        ));
        final tunSingBoxConfig = File(p.join(
          global.applicationSupportDirectory.path,
          'conf',
          'tun.sing_box.gen.json',
        ));
        if (!await tunSingBoxConfig.exists()) {
          await tunSingBoxConfig.create(recursive: true);
        }
        Map<String, dynamic> tunSingBoxRawCfgMap =
            jsonDecode(await tunSingBoxUserConfig.readAsString())
                as Map<String, dynamic>;
        tunSingBoxRawCfgMap =
            await getInjectedConfigTunSingBox(tunSingBoxRawCfgMap);
        await tunSingBoxConfig.writeAsString(jsonEncode(tunSingBoxRawCfgMap));

        // get core args
        final replacements = {
          "{config.path}": tunSingBoxConfig.path,
        };

        /// get core env
        _tunSingBoxCoreEnvs =
            (jsonDecode(core.read(db.core.envs)!) as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v as String));
        List<String> rawTunSingBoxArgList =
            (jsonDecode(core.read(db.coreExec.args)!) as List<dynamic>)
                .map((e) => e as String)
                .toList();
        if (rawTunSingBoxArgList.isEmpty) {
          rawTunSingBoxArgList = ["run", "-c", "{config.path}"];
        }
        _tunSingBoxCoreArgList = rawTunSingBoxArgList;
        for (int i = 0; i < _tunSingBoxCoreArgList.length; ++i) {
          for (var entry in replacements.entries) {
            _tunSingBoxCoreArgList[i] =
                _tunSingBoxCoreArgList[i].replaceAll(entry.key, entry.value);
          }
        }
      }
    }
  }
}

/// Direct processCore exec, need foreground, typically for desktop
class VPNManagerExec extends VPNManager {
  Process? processCore;
  Process? processTun;
  int? pidCore;
  int? pidTun;

  @override
  Future<void> updateDetachedCore() async {
    final coreCommandLine = "$corePath ${_coreArgList.join(' ')}";
    pidCore = await PlatformProcess.getProcessPid(coreCommandLine);
    setIsCoreActive(pidCore != null);
  }

  @override
  Future<void> updateDetachedTun() async {
    final tunCommandLine =
        "$_tunSingBoxCorePath ${_tunSingBoxCoreArgList.join(' ')}";
    pidTun = await PlatformProcess.getProcessPid(tunCommandLine);
    setIsTunActive(pidTun != null);
  }

  @override
  getIsCoreActive() async {
    if (processCore != null) {
      return true;
    }
    if (pidCore != null) {
      return true;
    }
    return false;
  }

  @override
  getIsTunActive() async {
    if (processTun != null) {
      return true;
    }
    if (pidTun != null) {
      return true;
    }
    return false;
  }

  @override
  startCore() async {
    await initCore();
    processCore = await Process.start(
      corePath!,
      _coreArgList,
      workingDirectory: _coreWorkingDir,
      environment: _coreEnvs,
    );
  }

  @override
  stopCore() async {
    if (processCore != null) {
      processCore!.kill();
      processCore = null;
      await updateIsCoreActive();
      return;
    }
    if (pidCore != null) {
      Process.killPid(pidCore!);
      pidCore = null;
      await updateIsCoreActive();
      return;
    }
  }

  @override
  startTun() async {
    if (getIsTunExec() && processTun == null) {
      await initTunExec();
      processTun = await Process.start(
        _tunSingBoxCorePath!,
        _tunSingBoxCoreArgList,
        workingDirectory: _tunSingBoxCoreWorkingDir,
        environment: _tunSingBoxCoreEnvs,
      );
    }
  }

  @override
  stopTun() async {
    processTun?.kill();
    processTun = null;
    if (pidTun != null) {
      Process.killPid(pidTun!);
    }
  }

  @override
  startAll() async {
    await startCore();
    await startTun();
    await startSystemProxy();
    await updateIsCoreActive();
    return;
  }

  @override
  stopAll() async {
    await stopSystemProxy();
    await stopTun();
    await stopCore();
    await updateIsCoreActive();
    return;
  }
}

class VPNManagerMC extends VPNManager {
  static const platform = MethodChannel('com.github.anyportal.anyportal');

  VPNManagerMC() {
    platform.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    logger.d("_methodCallHandler: ${call.method}");
    if (call.method == 'onCoreActivated' ||
        call.method == 'onCoreDeactivated') {
      setIsCoreActive(call.method == 'onCoreActivated');
    } else if (call.method == 'onTileToggled') {
      isExpectingActive = call.arguments as bool;
    }
  }

  @override
  Future<bool> getIsCoreActive() async {
    return await platform.invokeMethod('vpn.isCoreActive') as bool;
  }

  @override
  Future<bool> getIsTunActive() async {
    return await platform.invokeMethod('vpn.isTunActive') as bool;
  }

  @override
  startAll() async {
    await platform.invokeMethod('vpn.startAll');
  }

  @override
  stopAll() async {
    await platform.invokeMethod('vpn.stopAll');
  }

  @override
  startTun() async {
    await platform.invokeMethod('vpn.startTun');
  }

  @override
  stopTun() async {
    await platform.invokeMethod('vpn.stopTun');
  }

  @override
  startCore() async {
    await initCore();
    await platform.invokeMethod('vpn.startCore');
  }

  @override
  stopCore() async {
    await platform.invokeMethod('vpn.stopCore');
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
  void init() {
    _vPNMan = Platform.isAndroid || Platform.isIOS
        ? VPNManagerMC()
        : VPNManagerExec();
    _completer.complete(); // Signal that initialization is complete
  }
}

final vPNMan = VPNManManager()._vPNMan;
