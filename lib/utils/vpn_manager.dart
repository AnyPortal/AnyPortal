import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import '../../extensions/localization.dart';
import '../models/core.dart';
import '../screens/home/profiles.dart';
import '../screens/home/settings/cores.dart';
import '../screens/profile.dart';

import 'asset_remote/github.dart';
import 'core/base/plugin.dart';
import 'core/sing_box/plugin.dart';
import 'db.dart';
import 'db/update_profile_with_group_remote.dart';
import 'global.dart';
import 'logger.dart';
import 'method_channel.dart';
import 'platform_process.dart';
import 'platform_system_proxy_user.dart';
import 'prefs.dart';
import 'runtime_platform.dart';
import 'show_snack_bar_now.dart';
import 'tun/sing_box/config_injector.dart';
import 'with_context.dart';

abstract class VPNManager with ChangeNotifier {
  /// it's possible to toggle core alone, so distinguish beween all and core
  bool isAllActive = false;
  bool isCoreActive = false;
  bool isTunActive = false;
  bool isSystemProxyActive = false;

  /// it's possible to toggle core alone, so distinguish beween all and core
  bool isTogglingAll = false;
  bool isTogglingCore = false;
  bool isTogglingTun = false;
  bool isTogglingSystemProxy = false;

  Future<bool> _startAll();
  Future<bool> _stopAll();
  Future<bool> _startCore();
  Future<bool> _stopCore();

  Future<bool> prepareCore() async {
    // clear core log
    await File(p.join(
      global.applicationSupportDirectory.path,
      'log',
      'core.log',
    )).writeAsString("");

    if (!RuntimePlatform.isWeb) await installPendingAssetRemote();
    final ok = await initCore();
    return ok;
  }

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
    final dataNotifier = CorePluginManager().instance.dataNotifier;
    if (isCoreActive && !dataNotifier.on) {
      try {
        dataNotifier.init(cfgStr: vPNMan.coreCfgRaw);
        dataNotifier.start();
      } catch (e) {
        logger.e("notifyCoreDataNotifier: $e");
      }
    } else if (!isCoreActive && dataNotifier.on) {
      dataNotifier.stop();
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
          withContext((context) {
            showSnackBarNow(context, Text(errMsg));
          });
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
          withContext((context) {
            showSnackBarNow(context, Text(errMsg));
          });
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
          withContext((context) {
            showSnackBarNow(context, Text(errMsg));
          });
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
          withContext((context) {
            showSnackBarNow(context, Text(errMsg));
          });
        }
      });
    }
  }

  /// there is no actual such thing as "all is active"
  /// as "all" just means starts everything needed when the core starts
  /// a failed tun does not mean that all is not active
  /// therefore getIsAllActive is defined eqivalent to getIsCoreActive
  Future<bool> getIsAllActive() async {
    return await getIsCoreActive();
  }

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
        logger.d("setIsAllActive: no need, already $isAllActive");
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

  void setIsTunActive(
    bool value, {
    bool force = false,
    bool isToNotify = true,
  }) {
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

  void setIsSystemProxyActive(
    bool value, {
    bool force = false,
    bool isToNotify = true,
  }) {
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
    setIsTunActive(
      await getIsTunActive(),
      force: force,
      isToNotify: isToNotify,
    );
  }

  Future<void> updateIsSystemProxyActive({
    bool force = false,
    bool isToNotify = true,
  }) async {
    setIsSystemProxyActive(
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

  Future<void> updateDetachedSystemProxy() async {
    await updateIsSystemProxyActive();
  }

  Future<void> updateDetachedAll() async {
    await Future.wait([
      updateDetachedCore(),
      updateDetachedTun(),
      updateDetachedSystemProxy(),
    ]);
    await updateIsAllActive();
  }

  Future<bool> startAll() async {
    /// check is toggling
    if (isTogglingAll) return false;
    setisTogglingAll(true);

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
  late String coreTypeName;
  String? corePath;
  List<String> _coreArgList = [];
  String? _coreWorkingDir;
  Map<String, String>? _coreEnvs;

  String? _tunSingBoxCorePath;
  List<String> _tunSingBoxCoreArgList = [];
  String? _tunSingBoxCoreWorkingDir;
  Map<String, String>? _tunSingBoxCoreEnvs;

  late String coreCfgRaw;
  late String coreCfgFmt;

  Future<bool> initCore() async {
    logger.d("starting: initCore");
    // get selectedProfile
    _selectedProfileId = prefs.getInt('app.selectedProfileId');
    if (_selectedProfileId == null) {
      withContext((context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileList()),
        );
        showSnackBarNow(context, Text(context.loc.please_select_a_profile));
      });
      return false;
    }
    _selectedProfile = await (db.select(db.profile)
          ..where((p) => p.id.equals(_selectedProfileId!)))
        .getSingleOrNull();
    if (_selectedProfile == null) {
      withContext((context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileList()),
        );
        showSnackBarNow(context, Text(context.loc.please_select_a_profile));
      });
      return false;
    }

    // check update
    updateProfileWithGroupRemote(_selectedProfile!);

    coreTypeId = _selectedProfile!.coreTypeId;

    /// check core type exists
    final coreTypeData = await (db.select(db.coreType)
          ..where((coreType) => coreType.id.equals(coreTypeId)))
        .getSingleOrNull();
    if (coreTypeData == null) {
      withContext((context) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(profile: _selectedProfile)),
        );
        showSnackBarNow(context, Text("Inbalid core type"));
      });
    }
    coreTypeName = coreTypeData!.name;

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
      withContext((context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoresScreen()),
        );
        showSnackBarNow(
          context,
          Text(context.loc.please_select_a_core_type_name_core(coreTypeName)),
        );
      });
      return false;
    }

    // gen config.json
    coreCfgRaw = _selectedProfile!.coreCfg;
    coreCfgFmt = _selectedProfile!.coreCfgFmt;
    CorePluginManager().switchTo(coreTypeName);
    String coreCfg = await CorePluginManager()
        .instance
        .configInjector
        .getInjectedConfig(coreCfgRaw, coreCfgFmt);
    final coreCfgFile = File(p.join(global.applicationSupportDirectory.path,
        'conf', 'core.gen.$coreCfgFmt'));
    if (!RuntimePlatform.isWeb) {
      if (!await coreCfgFile.exists()) {
        await coreCfgFile.create(recursive: true);
      }
      await coreCfgFile.writeAsString(coreCfg);
    }

    // get is exec
    _isExec = core.read(db.core.isExec)!;
    if (!_isExec) {
      await prefs.setBool("cache.core.useEmbedded", true);
    } else {
      await prefs.setBool("cache.core.useEmbedded", false);
      corePath = core.read(db.asset.path);
      if (corePath == null) {
        withContext((context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CoresScreen()),
          );
          showSnackBarNow(context,
              Text(context.loc.please_specify_v2ray_core_executable_path));
        });
        return false;
      } else {
        corePath = File(corePath!).resolveSymbolicLinksSync();
        prefs.setString('cache.core.path', corePath!);
      }
      _coreWorkingDir = core.read(db.core.workingDir)!;
      if (_coreWorkingDir!.isEmpty) {
        _coreWorkingDir = File(corePath!).parent.path;
      }
      prefs.setString('cache.core.workingDir', _coreWorkingDir!);

      // get core args
      final argsStr = core.read(db.coreExec.args)!;
      List<String> rawCoreArgList = [];
      if (argsStr != "") {
        rawCoreArgList = (jsonDecode(argsStr) as List<dynamic>)
            .map((e) => e as String)
            .toList();
      } else {
        rawCoreArgList = CorePluginManager().instance.defaultArgs;
      }

      final replacements = {
        "{config.path}": coreCfgFile.path,
      };
      _coreArgList = [...rawCoreArgList];
      for (int i = 0; i < _coreArgList.length; ++i) {
        for (var entry in replacements.entries) {
          _coreArgList[i] = _coreArgList[i].replaceAll(entry.key, entry.value);
        }
      }
      await prefs.setString('cache.core.args', jsonEncode(_coreArgList));
    }

    // get core env
    _coreEnvs = (jsonDecode(core.read(db.core.envs)!) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
    await prefs.setString('cache.core.envs', jsonEncode(_coreEnvs));

    logger.d("finished: initCore");
    return true;
  }

  File getTunSingBoxUserConfigFile() {
    final tunSingBoxUserConfigFileCustomized = File(p.join(
      global.applicationDocumentsDirectory.path,
      'AnyPortal',
      'conf',
      'tun2socks.sing_box.json',
    ));
    final tunSingBoxUserConfigFileExample = File(p.join(
      global.applicationDocumentsDirectory.path,
      'AnyPortal',
      'conf',
      'tun2socks.sing_box.example.json',
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
    if (RuntimePlatform.isWindows ||
        RuntimePlatform.isLinux ||
        RuntimePlatform.isMacOS ||
        RuntimePlatform.isAndroid) {
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
          withContext((context) {
            showSnackBarNow(context,
                Text(context.loc.tun_needs_additionally_a_sing_box_core));
          });
          return;
        } else {
          _tunSingBoxCorePath = core.read(db.asset.path);
          if (_tunSingBoxCorePath == null) {
            withContext((context) {
              showSnackBarNow(context, Text(context.loc.sing_box_path_is_null));
            });
            return;
          } else {
            _tunSingBoxCorePath =
                File(_tunSingBoxCorePath!).resolveSymbolicLinksSync();
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
          'tun2socks.sing_box.gen.json',
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

        /// get core env
        _tunSingBoxCoreEnvs =
            (jsonDecode(core.read(db.core.envs)!) as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v as String));
        await prefs.setString(
            'cache.tun.singBox.core.envs', jsonEncode(_tunSingBoxCoreEnvs));

        // get core args
        final argsStr = core.read(db.coreExec.args)!;
        List<String> rawTunSingBoxArgList = [];
        if (argsStr != "") {
          rawTunSingBoxArgList = (jsonDecode(argsStr) as List<dynamic>)
              .map((e) => e as String)
              .toList();
        } else {
          rawTunSingBoxArgList = CorePluginSingBox().defaultArgs;
        }

        final replacements = {
          "{config.path}": tunSingBoxConfigFile.path,
        };
        _tunSingBoxCoreArgList = [...rawTunSingBoxArgList];
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
          'tun2socks.sing_box.log',
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
    setIsTunActive(pidTun != null);
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

  Future<bool> ensureServerAddressPort(String portName, int port) async {
    final serverAddress = prefs.getString("app.server.address")!;
    if (await isServerAddressPortInUse(serverAddress, port)) {
      withContext((context) {
        showSnackBarNow(
            context, Text("$portName: $serverAddress:$port in use"));
      });
      return false;
    }
    return true;
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

  /// return true if all ports clear
  Future<bool> ensureServerAddressPorts() async {
    final apiPort = prefs.getInt('inject.api.port')!;
    final httpPort = prefs.getInt('app.http.port')!;
    final socksPort = prefs.getInt('app.socks.port')!;

    final shouldCheckApiPort = prefs.getBool('inject.api')!;
    final shouldCheckHttpPort = httpPort != socksPort;

    if (!await ensureServerAddressPort("SOCKS", socksPort)) {
      return false;
    }
    if (shouldCheckApiPort) {
      if (!await ensureServerAddressPort("API", apiPort)) {
        return false;
      }
    }
    if (shouldCheckHttpPort) {
      if (!await ensureServerAddressPort("HTTP", httpPort)) {
        return false;
      }
    }
    return true;
  }

  @override
  _startCore() async {
    logger.d("starting: _startCore");
    final ok = await prepareCore();
    if (!ok) return false;
    logger.d("corePath: $corePath");
    logger.d("coreArgList: $_coreArgList");
    logger.d("coreWorkingDir: $_coreWorkingDir");
    logger.d("coreEnvs: $_coreEnvs");

    if (!File(corePath!).existsSync()) {
      withContext((context) {
        showSnackBarNow(context, Text(context.loc.core_path_does_not_exist));
      });
      logger.w("core path does not exist");
    }

    if (RuntimePlatform.isLinux ||
        RuntimePlatform.isMacOS ||
        RuntimePlatform.isAndroid) {
      final executableTestRes = await Process.run("test", ["-x", corePath!]);
      if (executableTestRes.exitCode != 0) {
        logger.i("core path not executable, fixing");
        await Process.run("chmod", [
          "+x",
          corePath!,
        ]);
      }
    }

    if (!await ensureServerAddressPorts()) return false;

    final Map<String, String> environment = {
      ...CorePluginManager().instance.environment
    };
    if (_coreEnvs != null) {
      environment.addAll(_coreEnvs!);
    }

    final processCore = await Process.start(
      corePath!,
      _coreArgList,
      workingDirectory: _coreWorkingDir,
      environment: environment,
    );

    IOSink? outputFileIOSink;
    if (CorePluginManager().instance.isToLogStdout) {
      outputFileIOSink = File(p.join(
        global.applicationSupportDirectory.path,
        'log',
        'core.log',
      )).openWrite();

      processCore.stdout.transform(SystemEncoding().decoder).listen((data) {
        outputFileIOSink?.write(data);
      });

      processCore.stderr.transform(SystemEncoding().decoder).listen((data) {
        outputFileIOSink?.write(data);
      });
    }

    setIsCoreActive(true);
    pidCore = processCore.pid;
    logger.d("processCore: started: pid: $pidCore");
    processCore.exitCode.then((exitCode) async {
      logger.d("processCore: exitCode: $exitCode");
      pidCore = null;
      setIsCoreActive(false);
      if (CorePluginManager().instance.isToLogStdout) {
        outputFileIOSink?.close();
      }
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
    if (prefs.getBool("tun")! && pidTun == null) {
      /// should start but not started yet

      /// check permission
      if (!global.isElevated) {
        withContext((context) {
          showSnackBarNow(
              context,
              Text(context.loc
                  .warning_you_need_to_be_elevated_user_to_enable_tun(
                      RuntimePlatform.isWindows
                          ? context.loc.administrator
                          : "root")));
        });
        setisTogglingTun(false);
        return false;
      }

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
      setIsTunActive(true);
      processTun.exitCode.then((exitCode) async {
        logger.d("processTun: exited: $exitCode");
        pidTun = null;
        setIsTunActive(false);
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
        setIsTunActive(false);
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
  static final platform = mCMan.methodChannel;

  void handleAllStatusChange(MethodCall call) {
    final isActive = call.arguments as bool;
    // logger.d("handleAllStatusChange: $isActive");
    setIsAllActive(isActive);
  }

  void handleCoreStatusChange(MethodCall call) {
    final isActive = call.arguments as bool;
    // logger.d("handleCoreStatusChange: $isActive");
    setIsCoreActive(isActive);
  }

  void handleTunStatusChange(MethodCall call) {
    final isActive = call.arguments as bool;
    // logger.d("handleTunStatusChange: $isActive");
    setIsTunActive(isActive);
  }

  void handleSystemProxyStatusChange(MethodCall call) {
    final isActive = call.arguments as bool;
    // logger.d("handleSystemProxyStatusChange: $isActive");
    setIsSystemProxyActive(isActive);
  }

  VPNManagerMC() {
    mCMan.addHandler("onAllStatusChange", handleAllStatusChange);
    mCMan.addHandler("onCoreStatusChange", handleCoreStatusChange);
    mCMan.addHandler("onTunStatusChange", handleTunStatusChange);
    mCMan.addHandler(
        "onSystemProxyStatusChange", handleSystemProxyStatusChange);
  }

  @override
  void dispose() {
    super.dispose();
    mCMan.removeHandler("onAllStatusChange", handleAllStatusChange);
    mCMan.removeHandler("onCoreStatusChange", handleCoreStatusChange);
    mCMan.removeHandler("onTunStatusChange", handleTunStatusChange);
    mCMan.removeHandler(
        "onSystemProxyStatusChange", handleSystemProxyStatusChange);
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
    final ok = await prepareCore();
    if (!ok) return false;

    if (prefs.getBool("tun")! && !prefs.getBool("tun.useEmbedded")!) {
      await initTunExec();
    }
    final res = await platform.invokeMethod('vpn.startAll') as bool;
    // if (res == true) {
    //   setIsCoreActive(true, isToNotify: false);
    //   setIsAllActive(true, isToNotify: false);
    //   await updateIsSystemProxyActive(isToNotify: false);
    //   await updateIsTunActive(isToNotify: false);
    //   notifyListeners();
    // }
    return res;
  }

  @override
  _stopAll() async {
    final res = await platform.invokeMethod('vpn.stopAll') as bool;
    // if (res == true) {
    //   setIsCoreActive(false, isToNotify: false);
    //   setIsAllActive(false, isToNotify: false);
    //   await updateIsSystemProxyActive(isToNotify: false);
    //   await updateIsTunActive(isToNotify: false);
    //   notifyListeners();
    // }
    return res;
  }

  @override
  _startTun() async {
    if (!prefs.getBool("tun.useEmbedded")!) {
      if (!global.isElevated) {
        withContext((context) {
          showSnackBarNow(
              context,
              Text(context.loc
                  .warning_you_need_to_be_elevated_user_to_enable_tun(
                      RuntimePlatform.isWindows
                          ? context.loc.administrator
                          : "root")));
        });
        setisTogglingTun(false);
        return false;
      }
      await initTunExec();
    }
    final res = await platform.invokeMethod('vpn.startTun') as bool;
    // if (res == true) {
    //   setIsTunActive(true);
    // }
    return res;
  }

  @override
  _stopTun() async {
    final res = await platform.invokeMethod('vpn.stopTun') as bool;
    // if (res == true) {
    //   setIsTunActive(false);
    // }
    return res;
  }

  @override
  _startCore() async {
    final ok = await prepareCore();
    if (!ok) return false;

    final res = await platform.invokeMethod('vpn.startCore') as bool;
    // if (res == true) {
    //   setIsCoreActive(true);
    // }
    return res;
  }

  @override
  _stopCore() async {
    final res = await platform.invokeMethod('vpn.stopCore') as bool;
    // if (res == true) {
    //   setIsCoreActive(false);
    // }
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
    _vPNMan = RuntimePlatform.isAndroid || RuntimePlatform.isIOS
        ? VPNManagerMC()
        : VPNManagerExec();
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: VPNManManager.init");
  }
}

final vPNMan = VPNManManager()._vPNMan;
