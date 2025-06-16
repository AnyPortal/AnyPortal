import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import 'package:anyportal/models/core.dart';
import 'package:anyportal/utils/platform_system_proxy_user.dart';
import 'asset_remote/github.dart';
import 'config_injector/core_ray.dart';
import 'config_injector/tun_sing_box.dart';
import 'core_data_notifier.dart';
import 'db.dart';
import 'db/update_profile_with_group_remote.dart';
import 'global.dart';
import 'logger.dart';
import 'method_channel.dart';
import 'platform.dart';
import 'platform_process.dart';
import 'prefs.dart';

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
  bool isAllActive = false;
  bool isCoreActive = false;
  bool isTunActive = false;
  bool isSystemProxyActive = false;

  bool isExpectingActive = false;
  bool isTogglingAll = false;
  bool isTogglingCore = false;
  bool isTogglingTun = false;
  bool isTogglingSystemProxy = false;

  Future<bool> _startAll();
  Future<bool> _stopAll();
  Future<bool> _startCore();
  Future<bool> _stopCore();

  Future<void> _startSystemProxy() async {
    if (prefs.getBool("systemProxy")!) {
      String serverAddress = prefs.getString('app.server.address')!;
      if (serverAddress == "0.0.0.0") {
        serverAddress = "127.0.0.1";
      }
      final ok = await platformSystemProxyUser.enable({
        'socks': Tuple2(serverAddress, prefs.getInt("app.socks.port")!),
        'http': Tuple2(serverAddress, prefs.getInt("app.http.port")!),
      });
      if (ok) {
        setIsSystemProxyActive(true);
      }
    }
  }

  Future<void> _stopSystemProxy() async {
    final ok = await platformSystemProxyUser.disable();
    if (ok) {
      setIsSystemProxyActive(false);
    }
  }

  Future<bool> _startTun();
  Future<bool> _stopTun();

  Future<void> startNotificationForeground() async {}
  Future<void> stopNotificationForeground() async {}

  Future<void> notifyCoreDataNotifier() async {
    if (isCoreActive &&
        !coreDataNotifier.on &&
        vPNMan.coreTypeId <= CoreTypeDefault.xray.index) {
      try {
        coreDataNotifier.loadCfg(vPNMan.coreRawCfgMap);
        // should do atomic check
        if (!coreDataNotifier.on) coreDataNotifier.start();
      } catch (e) {
        logger.e("notifyCoreDataNotifier: $e");
      }
    } else if (!isCoreActive && coreDataNotifier.on) {
      // should do atomic check
      coreDataNotifier.stop();
    }
  }

  Future<Null>? delayedTogglingChecker;

  void setisTogglingAll(bool val) {
    if (isTogglingAll != val) {
      isTogglingAll = val;
      notifyListeners();
    } else {
      return;
    }

    /// with timeout
    const timeoutSec = 5;
    if (isTogglingAll) {
      delayedTogglingChecker =
          Future.delayed(const Duration(seconds: timeoutSec), () {
        if (isTogglingAll) {
          updateIsCoreActive(force: true, isToNotify: false);
          updateIsAllActive(force: true);
          final errMsg = "all toggled for $timeoutSec sec, force stopped";
          logger.w(errMsg);
          // throw Exception(errMsg);
        }
      });
    }
  }

  void setisTogglingCore(bool val) {
    if (isTogglingCore != val) {
      isTogglingCore = val;
      notifyListeners();
    } else {
      return;
    }

    /// with timeout
    const timeoutSec = 5;
    if (isTogglingCore) {
      delayedTogglingChecker =
          Future.delayed(const Duration(seconds: timeoutSec), () {
        if (isTogglingCore) {
          updateIsCoreActive(force: true);
          final errMsg = "core toggled for $timeoutSec sec, force stopped";
          logger.w(errMsg);
          // throw Exception(errMsg);
        }
      });
    }
  }

  void setisTogglingSystemProxy(bool val) {
    if (isTogglingSystemProxy != val) {
      isTogglingSystemProxy = val;
      notifyListeners();
    } else {
      return;
    }

    /// with timeout
    const timeoutSec = 5;
    if (isTogglingSystemProxy) {
      delayedTogglingChecker =
          Future.delayed(const Duration(seconds: timeoutSec), () {
        if (isTogglingSystemProxy) {
          updateIsSystemProxyActive(force: true);
          final errMsg =
              "system proxy toggled for $timeoutSec sec, force stopped";
          logger.w(errMsg);
          // throw Exception(errMsg);
        }
      });
    }
  }

  void setisTogglingTun(bool val) {
    if (isTogglingTun != val) {
      isTogglingTun = val;
      notifyListeners();
    } else {
      return;
    }

    /// with timeout
    const timeoutSec = 5;
    if (isTogglingTun) {
      delayedTogglingChecker =
          Future.delayed(const Duration(seconds: timeoutSec), () {
        if (isTogglingTun) {
          updateIsTunActive(force: true);
          final errMsg = "tun toggled for $timeoutSec sec, force stopped";
          logger.w(errMsg);
          // throw Exception(errMsg);
        }
      });
    }
  }

  /// there is no actual such thing as "all is active"
  /// as "all" just means starts everything needed when the core starts
  /// a failed tun does not mean that all is not active
  /// therefore getIsAllActive is defined eqivalent to getIsCoreActive
  Future<bool> getIsAllActive() async {return await getIsCoreActive();}
  Future<bool> getIsCoreActive();
  Future<bool> getIsTunActive();
  Future<bool> getIsSystemProxyActive();

  void setIsAllActive(
    bool value, {
    bool force = false,
    bool isToNotify = true,
  }) {
    if (!force && value == isAllActive) {
      if (value == isAllActive) {
        logger.d("isAllActive: no need, already $isAllActive");
        return;
      }
    }
    isAllActive = value;
    setisTogglingAll(false);
    if (isToNotify) {
      notifyListeners();
      notifyCoreDataNotifier();
    }
  }

  void setIsCoreActive(
    bool value, {
    bool force = false,
    bool isToNotify = true,
  }) {
    if (!force && value == isCoreActive) {
      if (value == isCoreActive) {
        logger.d("setIsCoreActive: no need, already $isCoreActive");
        return;
      }
    }
    isCoreActive = value;
    setisTogglingCore(false);
    if (isToNotify) {
      notifyListeners();
      notifyCoreDataNotifier();
    }
  }

  Future<void> setIsTunActive(
    bool value, {
    bool force = false,
    bool isToNotify = true,
  }) async {
    if (!force && value == isTunActive) {
      if (value == isTunActive) {
        logger.d("setIsTunActive: no need, already $isTunActive");
        return;
      }
    }
    isTunActive = value;
    if (isToNotify) {
      setisTogglingTun(false);
      notifyListeners();
    }
  }

  Future<void> setIsSystemProxyActive(
    bool value, {
    bool force = false,
    bool isToNotify = true,
  }) async {
    if (!force && value == isSystemProxyActive) {
      if (value == isSystemProxyActive) {
        logger
            .d("setIsSystemProxyActive: no need, already $isSystemProxyActive");
        return;
      }
    }
    isSystemProxyActive = value;
    if (isToNotify) {
      setisTogglingSystemProxy(false);
      notifyListeners();
    }
  }

  Future<void> updateIsAllActive({
    bool force = false,
    bool isToNotify = true,
  }) async {
    setIsAllActive(
      await getIsAllActive(),
      force: force,
      isToNotify: isToNotify,
    );
  }

  Future<void> updateIsCoreActive({
    bool force = false,
    bool isToNotify = true,
  }) async {
    setIsCoreActive(
      await getIsCoreActive(),
      force: force,
      isToNotify: isToNotify,
    );
  }

  Future<void> updateIsTunActive({
    bool force = false,
    bool isToNotify = true,
  }) async {
    await setIsTunActive(
      await getIsTunActive(),
      force: force,
      isToNotify: isToNotify,
    );
  }

  Future<void> updateIsSystemProxyActive({
    bool force = false,
    bool isToNotify = true,
  }) async {
    await setIsSystemProxyActive(
      await getIsSystemProxyActive(),
      force: force,
      isToNotify: isToNotify,
    );
  }

  Future<void> updateDetachedCore() async {
    await updateIsCoreActive();
  }

  Future<void> updateDetachedTun() async {
    await updateIsTunActive();
  }

  Future<bool> startAll() async {
    /// check is toggling
    if (isTogglingAll) return false;
    setisTogglingAll(true);
    isExpectingActive = true;

    /// check is already active
    if (await getIsAllActive()) {
      setisTogglingAll(false);
      return false;
    }

    /// start
    return await _startAll();
  }

  Future<bool> stopAll() async {
    /// check is toggling
    if (isTogglingAll) return false;
    setisTogglingAll(true);
    isExpectingActive = false;

    /// check is already inactive
    if (!await getIsCoreActive()) {
      setisTogglingAll(false);
      return false;
    }

    /// stop
    return await _stopAll();
  }

  Future<bool> startCore() async {
    /// check is toggling
    if (isTogglingCore) return false;
    setisTogglingCore(true);
    isExpectingActive = true;

    /// check is already active
    if (await getIsCoreActive()) {
      setisTogglingCore(false);
      return false;
    }

    /// start
    return await _startCore();
  }

  Future<bool> stopCore() async {
    /// check is toggling
    if (isTogglingCore) return false;
    setisTogglingCore(true);
    isExpectingActive = false;

    /// check is already inactive
    if (!await getIsCoreActive()) {
      setisTogglingCore(false);
      return false;
    }

    /// stop
    return await _stopCore();
  }

  Future<void> startTun() async {
    /// check is toggling
    if (isTogglingTun) return;
    setisTogglingTun(true);

    /// check is already active
    if (await getIsTunActive()) {
      setisTogglingTun(false);
      return;
    }

    /// start
    await _startTun();
  }

  Future<void> stopTun() async {
    /// check is toggling
    if (isTogglingTun) return;
    setisTogglingTun(true);
    isExpectingActive = false;

    /// check is already inactive
    if (!await getIsTunActive()) {
      setisTogglingTun(false);
      return;
    }

    /// stop
    await _stopTun();
  }

  Future<void> startSystemProxy() async {
    /// check is toggling
    if (isTogglingSystemProxy) return;
    setisTogglingSystemProxy(true);

    /// check is already active
    if (await getIsSystemProxyActive()) {
      setisTogglingSystemProxy(false);
      return;
    }

    /// start
    await _startSystemProxy();
  }

  Future<void> stopSystemProxy() async {
    /// check is toggling
    if (isTogglingSystemProxy) return;
    setisTogglingSystemProxy(true);
    isExpectingActive = false;

    /// check is already inactive
    if (!await getIsCoreActive()) {
      setisTogglingSystemProxy(false);
      return;
    }

    /// stop
    await _stopSystemProxy();
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
        (platform.isWindows || platform.isLinux || platform.isMacOS);
  }

  Future<void> initCore() async {
    logger.d("starting: initCore");
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
    coreRawCfgMap =
        jsonDecode(_selectedProfile!.coreCfg) as Map<String, dynamic>;
    if (_selectedProfile!.coreTypeId == CoreTypeDefault.v2ray.index ||
        _selectedProfile!.coreTypeId == CoreTypeDefault.xray.index) {
      coreRawCfgMap = await getInjectedConfig(coreRawCfgMap);
    }

    final config = File(p.join(
        global.applicationSupportDirectory.path, 'conf', 'core.gen.json'));
    if (!kIsWeb) {
      if (!await config.exists()) {
        await config.create(recursive: true);
      }
      await config.writeAsString(jsonEncode(coreRawCfgMap));
    }

    coreTypeId = _selectedProfile!.coreTypeId;

    // check core path
    final core = await (db.select(db.coreTypeSelected).join([
      leftOuterJoin(db.core, db.coreTypeSelected.coreId.equalsExp(db.core.id)),
      leftOuterJoin(db.coreExec, db.core.id.equalsExp(db.coreExec.coreId)),
      leftOuterJoin(db.coreLib, db.core.id.equalsExp(db.coreLib.coreId)),
      leftOuterJoin(db.coreType, db.core.coreTypeId.equalsExp(db.coreType.id)),
      leftOuterJoin(db.asset, db.coreExec.assetId.equalsExp(db.asset.id)),
    ])
          ..where(db.coreTypeSelected.coreTypeId.equals(coreTypeId)))
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
      if (_coreWorkingDir!.isEmpty) {
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
    logger.d("finished: initCore");
  }

  File getTunSingBoxUserConfigFile() {
    final tunSingBoxUserConfigFileCustomized = File(p.join(
      global.applicationDocumentsDirectory.path,
      'AnyPortal',
      'conf',
      'tun.sing_box.json',
    ));
    final tunSingBoxUserConfigFileExample = File(p.join(
      global.applicationDocumentsDirectory.path,
      'AnyPortal',
      'conf',
      'tun.sing_box.example.json',
    ));
    late File tunSingBoxUserConfigFile;
    if (tunSingBoxUserConfigFileCustomized.existsSync()) {
      tunSingBoxUserConfigFile = tunSingBoxUserConfigFileCustomized;
    } else {
      tunSingBoxUserConfigFile = tunSingBoxUserConfigFileExample;
    }
    return tunSingBoxUserConfigFile;
  }

  Future<void> initTunExec() async {
    if (platform.isWindows ||
        platform.isLinux ||
        platform.isMacOS ||
        platform.isAndroid) {
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
            prefs.setString(
                'cache.tun.singBox.core.path', _tunSingBoxCorePath!);
          }
          _tunSingBoxCoreWorkingDir = core.read(db.core.workingDir)!;
          if (_tunSingBoxCoreWorkingDir!.isEmpty) {
            _tunSingBoxCoreWorkingDir = File(_tunSingBoxCorePath!).parent.path;
          }
          prefs.setString(
              'cache.tun.singBox.core.workingDir', _tunSingBoxCoreWorkingDir!);
        }

        /// gen config.json
        final tunSingBoxUserConfigFile = getTunSingBoxUserConfigFile();
        final tunSingBoxConfigFile = File(p.join(
          global.applicationSupportDirectory.path,
          'conf',
          'tun.sing_box.gen.json',
        ));
        if (!await tunSingBoxConfigFile.exists()) {
          await tunSingBoxConfigFile.create(recursive: true);
        }
        Map<String, dynamic> tunSingBoxRawCfgMap =
            jsonDecode(await tunSingBoxUserConfigFile.readAsString())
                as Map<String, dynamic>;
        tunSingBoxRawCfgMap =
            await getInjectedConfigTunSingBox(tunSingBoxRawCfgMap);
        await tunSingBoxConfigFile
            .writeAsString(jsonEncode(tunSingBoxRawCfgMap));

        // get core args
        final replacements = {
          "{config.path}": tunSingBoxConfigFile.path,
        };

        /// get core env
        _tunSingBoxCoreEnvs =
            (jsonDecode(core.read(db.core.envs)!) as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v as String));
        await prefs.setString(
            'cache.tun.singBox.core.envs', jsonEncode(_tunSingBoxCoreEnvs));
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
        prefs.setString(
            'cache.tun.singBox.core.args', jsonEncode(_tunSingBoxCoreArgList));

        // clear core log
        await File(p.join(
          global.applicationSupportDirectory.path,
          'log',
          'tun.sing_box.log',
        )).writeAsString("");
      }
    }
  }

  Future<void> installPendingAssetRemote() async {
    logger.d("starting: installPendingAssetRemote");
    final assets = await (db.select(db.asset).join([
      leftOuterJoin(
          db.assetRemote, db.asset.id.equalsExp(db.assetRemote.assetId)),
    ])
          ..where(db.assetRemote.downloadedFilePath.isNotNull()))
        .get();
    for (var asset in assets) {
      final assetUrl = asset.read(db.assetRemote.url)!;
      final assetId = asset.read(db.assetRemote.assetId)!;
      final assetRemoteProtocolGithub =
          AssetRemoteProtocolGithub.fromUrl(assetUrl);
      logger.d("installing: $assetUrl");
      final installOk = await assetRemoteProtocolGithub
          .install(File(asset.read(db.assetRemote.downloadedFilePath)!));
      if (installOk) {
        await assetRemoteProtocolGithub.postInstall(assetId);
        logger.d("installed: $assetUrl");
      } else {
        logger.w("install failed: $assetUrl");
      }
    }
    logger.d("finished: installPendingAssetRemote");
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
    setIsCoreActive(pidCore != null);
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
  getIsSystemProxyActive() async {
    final isEnabled = await platformSystemProxyUser.isEnabled();
    if (isEnabled == true) {
      return true;
    }
    return false;
  }

  Future<void> ensureServerAddressPort(String name, int port) async {
    final serverAddress = prefs.getString("app.server.address")!;
    if (await isServerAddressPortInUse(serverAddress, port)) {
      throw Exception("$name: $serverAddress:$port in use");
    }
  }

  Future<bool> isServerAddressPortInUse(String serverAddress, int port) async {
    try {
      final server = await ServerSocket.bind(serverAddress, port);
      await server.close();
      return false; // Port is free
    } catch (e) {
      return true; // Port is in use
    }
  }

  Future<void> ensureServerAddressPorts() async {
    final apiPort = prefs.getInt('inject.api.port')!;
    final httpPort = prefs.getInt('app.http.port')!;
    final socksPort = prefs.getInt('app.socks.port')!;

    final shouldCheckApiPort = prefs.getBool('inject.api')!;
    final shouldCheckHttpPort = httpPort != socksPort;

    await Future.wait([
      if (shouldCheckApiPort) ensureServerAddressPort("API", apiPort),
      if (shouldCheckHttpPort) ensureServerAddressPort("HTTP", httpPort),
      ensureServerAddressPort("SOCKS", socksPort),
    ]);
  }

  @override
  _startCore() async {
    logger.d("starting: _startCore");
    if (!kIsWeb) await installPendingAssetRemote();
    await initCore();
    logger.d("corePath: $corePath");
    logger.d("coreArgList: $_coreArgList");
    logger.d("coreWorkingDir: $_coreWorkingDir");
    logger.d("coreEnvs: $_coreEnvs");

    if (!File(corePath!).existsSync()) {
      logger.w("core path does not exist");
      throw Exception("core path does not exist");
    }

    if (platform.isLinux || platform.isMacOS || platform.isAndroid) {
      final executableTestRes = await Process.run("test", ["-x", corePath!]);
      if (executableTestRes.exitCode != 0) {
        logger.i("core path not executable, fixing");
        await Process.run("chmod", [
          "+x",
          corePath!,
        ]);
      }
    }

    await ensureServerAddressPorts();

    final processCore = await Process.start(
      corePath!,
      _coreArgList,
      workingDirectory: _coreWorkingDir,
      environment: _coreEnvs,
    );
    setIsCoreActive(true);
    pidCore = processCore.pid;
    logger.d("processCore: started: pid: $pidCore");
    processCore.exitCode.then((exitCode) async {
      logger.d("processCore: exitCode: $exitCode");
      pidCore = null;
      setIsCoreActive(false);
    });

    logger.d("finished: _startCore");
    return true;
  }

  @override
  _stopCore() async {
    logger.d("starting: _stopCore");
    if (pidCore != null) {
      final res = await PlatformProcess.killProcess(pidCore!);
      if (res) {
        pidCore = null;
        setIsCoreActive(false);
        logger.d("finished: stopCore");
        return true;
      } else {
        logger.w("_stopCore: failed");
        return false;
      }
    } else {
      logger.w("_stopCore: pidCore is null");
      return true;
    }
  }

  @override
  _startTun() async {
    logger.d("starting: _startTun");
    if (getIsTunProcess() && pidTun == null) {
      await initTunExec();
      logger.d("tunSingBoxCorePath: $_tunSingBoxCorePath");
      logger.d("tunSingBoxCoreArgList: $_tunSingBoxCoreArgList");
      logger.d("tunSingBoxCoreWorkingDir: $_tunSingBoxCoreWorkingDir");
      logger.d("tunSingBoxCoreEnvs: $_tunSingBoxCoreEnvs");

      final processTun = await Process.start(
        _tunSingBoxCorePath!,
        _tunSingBoxCoreArgList,
        workingDirectory: _tunSingBoxCoreWorkingDir,
        environment: _tunSingBoxCoreEnvs,
      );
      pidTun = processTun.pid;
      await setIsTunActive(true);
      processTun.exitCode.then((exitCode) async {
        logger.d("processTun: exited: $exitCode");
        pidTun = null;
        await setIsTunActive(false);
      });
    }
    logger.d("finished: _startTun");
    return true;
  }

  @override
  _stopTun() async {
    logger.d("starting: _stopTun");
    if (pidTun != null) {
      final res = await PlatformProcess.killProcess(pidTun!);
      if (res) {
        pidTun = null;
        await setIsTunActive(false);
      } else {
        pidTun = null;
        logger.w("stopTun: failed");
      }
    } else {
      logger.w("stopTun: pidTun is null");
    }
    logger.d("finished: _stopTun");
    return true;
  }
  @override
  _startAll() async {
    final res = await _startCore();
    if (res) {
      await _startTun();
      await _startSystemProxy();
      setIsCoreActive(true, isToNotify: false);
      setIsAllActive(true);
    }
    return res;
  }

  @override
  _stopAll() async {
    await _stopSystemProxy();
    await _stopTun();
    final res = await _stopCore();
    if (res) {
      setIsCoreActive(false, isToNotify: false);
      setIsAllActive(false);
    }
    return res;
  }
}

class VPNManagerMC extends VPNManager {
  static const platform = MethodChannel('com.github.anyportal.anyportal');

  VPNManagerMC() {
    mCMan.addHandler("onCoreToggled", (call) async {
      setIsCoreActive(call.arguments as bool);
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
  Future<bool> getIsSystemProxyActive() async {
    return await platform.invokeMethod('vpn.isSystemProxyActive') as bool;
  }

  @override
  _startAll() async {
    await initCore();
    await installPendingAssetRemote();
    if (!prefs.getBool("tun.useEmbedded")!) {
      await initTunExec();
    }
    final res = await platform.invokeMethod('vpn.startAll') as bool;
    if (res == true) {
      setIsCoreActive(true, isToNotify: false);
      setIsAllActive(true, isToNotify: false);
      await updateIsSystemProxyActive(isToNotify: false);
      await updateIsTunActive(isToNotify: false);
      notifyListeners();
    }
    return res;
  }

  @override
  _stopAll() async {
    final res = await platform.invokeMethod('vpn.stopAll') as bool;
    if (res == true) {
      setIsCoreActive(false, isToNotify: false);
      setIsAllActive(false, isToNotify: false);
      await updateIsSystemProxyActive(isToNotify: false);
      await updateIsTunActive(isToNotify: false);
      notifyListeners();
    }
    return res;
  }

  @override
  _startTun() async {
    if (!prefs.getBool("tun.useEmbedded")!) {
      await initTunExec();
    }
    final res = await platform.invokeMethod('vpn.startTun') as bool;
    if (res == true) {
      await setIsTunActive(true);
    }
    return res;
  }

  @override
  _stopTun() async {
    final res = await platform.invokeMethod('vpn.stopTun') as bool;
    if (res == true) {
      await setIsTunActive(false);
    }
    return res;
  }

  @override
  _startCore() async {
    await initCore();
    await installPendingAssetRemote();
    final res = await platform.invokeMethod('vpn.startCore') as bool;
    if (res == true) {
      setIsCoreActive(true);
    }
    return res;
  }

  @override
  _stopCore() async {
    final res = await platform.invokeMethod('vpn.stopCore') as bool;
    if (res == true) {
      setIsCoreActive(false);
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
    _vPNMan = platform.isAndroid || platform.isIOS
        ? VPNManagerMC()
        : VPNManagerExec();
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: VPNManManager.init");
  }
}

final vPNMan = VPNManManager()._vPNMan;
