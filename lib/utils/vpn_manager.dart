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
import 'core_data_notifier.dart';
import 'db.dart';
import 'global.dart';
import 'logger.dart';
import 'method_channel.dart';
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
  Future<bool> startCore();
  Future<bool> stopCore();
  Future<void> startTun();
  Future<void> stopTun();
  Future<void> startNotificationForeground() async {}
  Future<void> stopNotificationForeground() async {}

  Future<void> notifyCoreDataNotifier() async {
    if (isCoreActive && !coreDataNotifier.on && vPNMan.coreTypeId <= CoreTypeDefault.xray.index) {
      try {
        coreDataNotifier.loadCfg(vPNMan.coreRawCfgMap);
        // should do atomic check
        if (!coreDataNotifier.on) coreDataNotifier.start();
      } catch (e) {
        logger.e("$e");
      }
    } else if (!isCoreActive && coreDataNotifier.on) {
      // should do atomic check
      coreDataNotifier.stop();
    }
  }

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
    notifyCoreDataNotifier();
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

  late int coreTypeId;
  String? corePath;
  List<String> _coreArgList = [];
  String? _coreWorkingDir;
  Map<String, String>? _coreEnvs;

  String? _tunSingBoxCorePath;
  List<String> _tunSingBoxCoreArgList = [];
  String? _tunSingBoxCoreWorkingDir;
  Map<String, String>? _tunSingBoxCoreEnvs;

  late Map<String, dynamic> coreRawCfgMap;

  bool getIsTunProcess() {
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
    final config = File(p.join(
        global.applicationSupportDirectory.path, 'conf', 'core.gen.json'));
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
    coreTypeId = _selectedProfile!.coreTypeId;
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

    // get is exec
    _isExec = core.read(db.core.isExec)!;
    if (_isExec) {
      await prefs.setBool("cache.core.useEmbedded", false);
      corePath = core.read(db.asset.path);
      if (corePath == null) {
        throw ExceptionInvalidCorePath("Core path is null.");
      } else {
        prefs.setString('cache.core.path', corePath!);
      }
      _coreWorkingDir = core.read(db.core.workingDir)!;
      if (_coreWorkingDir!.isEmpty){
        _coreWorkingDir = File(corePath!).parent.path;
      }
      prefs.setString('cache.core.workingDir', _coreWorkingDir!);

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
      await prefs.setString('cache.core.args', jsonEncode(_coreArgList));
    } else {
      await prefs.setBool("cache.core.useEmbedded", true);
    }

    // get core env
    _coreEnvs = (jsonDecode(core.read(db.core.envs)!) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
    await prefs.setString('cache.core.envs', jsonEncode(_coreEnvs));

    // clear core log
    await File(p.join(
      global.applicationSupportDirectory.path,
      'log',
      'core.log',
    )).writeAsString("");
  }

  Future<void> initTunExec() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
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
            prefs.setString('cache.tun.singBox.core.path', _tunSingBoxCorePath!);
          }
          _tunSingBoxCoreWorkingDir = core.read(db.core.workingDir)!;
          if (_tunSingBoxCoreWorkingDir!.isEmpty){
            _tunSingBoxCoreWorkingDir = File(_tunSingBoxCorePath!).parent.path;
          }
          prefs.setString('cache.tun.singBox.core.workingDir', _tunSingBoxCoreWorkingDir!);
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
        await prefs.setString('cache.tun.singBox.core.envs', jsonEncode(_tunSingBoxCoreEnvs));
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
        prefs.setString('cache.tun.singBox.core.args', jsonEncode(_tunSingBoxCoreArgList));

        // clear core log
        await File(p.join(
          global.applicationSupportDirectory.path,
          'log',
          'tun.sing_box.log',
        )).writeAsString("");
      }
    }
  }
}

/// Direct processCore exec, need foreground, typically for desktop
class VPNManagerExec extends VPNManager {
  int? pidCore;
  int? pidTun;

  @override
  Future<void> updateDetachedCore() async {
    final coreCommandLine = "$corePath ${_coreArgList.join(' ')}";
    pidCore = await PlatformProcess.getProcessPid(coreCommandLine);
    await setIsCoreActive(pidCore != null);
  }

  @override
  Future<void> updateDetachedTun() async {
    final tunCommandLine =
        "$_tunSingBoxCorePath ${_tunSingBoxCoreArgList.join(' ')}";
    pidTun = await PlatformProcess.getProcessPid(tunCommandLine);
    await setIsTunActive(pidTun != null);
  }

  @override
  getIsCoreActive() async {
    if (pidCore != null) {
      return true;
    }
    return false;
  }

  @override
  getIsTunActive() async {
    if (pidTun != null) {
      return true;
    }
    return false;
  }

  @override
  startCore() async {
    await initCore();
    final processCore = await Process.start(
      corePath!,
      _coreArgList,
      workingDirectory: _coreWorkingDir,
      environment: _coreEnvs,
    );
    await setIsCoreActive(true);
    pidCore = processCore.pid;
    return true;
  }

  @override
  stopCore() async {
    if (pidCore != null) {
      final res = await PlatformProcess.killProcess(pidCore!);
      if (res) {
        pidCore = null;
        await setIsCoreActive(false);
        return true;
      } else {
        logger.w("stopCore: failed");
        return false;
      }
    } else {
      logger.w("stopCore: pidCore is null");
      return false;
    }
  }



  @override
  startTun() async {
    if (getIsTunProcess() && pidTun == null) {
      await initTunExec();
      final processTun = await Process.start(
        _tunSingBoxCorePath!,
        _tunSingBoxCoreArgList,
        workingDirectory: _tunSingBoxCoreWorkingDir,
        environment: _tunSingBoxCoreEnvs,
      );
      pidTun = processTun.pid;
      await setIsTunActive(true);
    }
  }

  @override
  stopTun() async {
    if (pidTun != null) {
      final res = await PlatformProcess.killProcess(pidTun!);
      if (res) {
        pidTun = null;
        await setIsTunActive(false);
      } else {
        logger.w("stopTun: failed");
      }
    } else {
      logger.w("stopTun: pidTun is null");
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
    mCMan.addHandler("onCoreToggled", (call) async {
      await setIsCoreActive(call.arguments as bool);
    });
    mCMan.addHandler("onTileToggled", (call) async {
      isExpectingActive = call.arguments as bool;
    });
  }

  @override
  void dispose() {
    super.dispose();
    mCMan.removeHandler("onCoreToggled");
    mCMan.removeHandler("onTileToggled");
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
    await initCore();
    if (!prefs.getBool("tun.useEmbedded")!){
      await initTunExec();
    }
    final res = await platform.invokeMethod('vpn.startAll') as bool;
    if (res == true){
      await setIsCoreActive(true);
    }
  }

  @override
  stopAll() async {
    final res = await platform.invokeMethod('vpn.stopAll') as bool;
    if (res == true){
      await setIsCoreActive(false);
    }
  }

  @override
  startTun() async {
    if (!prefs.getBool("tun.useEmbedded")!){
      await initTunExec();
    }
    await platform.invokeMethod('vpn.startTun');
  }

  @override
  stopTun() async {
    await platform.invokeMethod('vpn.stopTun');
  }

  @override
  startCore() async {
    await initCore();
    final res = await platform.invokeMethod('vpn.startCore') as bool;
    if (res == true){
      await setIsCoreActive(true);
    }
    return res;
  }

  @override
  stopCore() async {
    final res = await platform.invokeMethod('vpn.stopCore') as bool;
    if (res == true){
      await setIsCoreActive(false);
    }
    return res;
  }

  @override
  startNotificationForeground() async {
    await platform.invokeMethod('vpn.startNotificationForeground');
  }

  @override
  stopNotificationForeground() async {
    await platform.invokeMethod('vpn.stopNotificationForeground');
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
    logger.d("starting: VPNManManager.init");
    _vPNMan = Platform.isAndroid || Platform.isIOS
        ? VPNManagerMC()
        : VPNManagerExec();
    _completer.complete(); // Signal that initialization is complete
    logger.d("started: VPNManManager.init");
  }

}

final vPNMan = VPNManManager()._vPNMan;
