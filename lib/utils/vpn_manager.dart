import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anyportal/models/core.dart';
import 'package:anyportal/utils/tray_menu.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

import 'config_injector/core_ray.dart';
import 'config_injector/tun_sing_box.dart';
import 'db.dart';
import 'global.dart';
import 'logger.dart';
import 'platform_elevation.dart';
import 'platform_process.dart';
import 'prefs.dart';
import 'db/update_profile_with_group_remote.dart';

class NoCorePathException implements Exception {
  String message;
  NoCorePathException(this.message);
}

class NoSelectedProfileException implements Exception {
  String message;
  NoSelectedProfileException(this.message);
}

class InvalidSelectedProfileException implements Exception {
  String message;
  InvalidSelectedProfileException(this.message);
}

class IsActiveRecord {
  bool isActive;
  DateTime datetime;
  String source;

  IsActiveRecord(this.isActive, this.datetime, this.source);
}

abstract class VPNManager with ChangeNotifier {
  bool isToggling = false;
  IsActiveRecord isCoreActiveRecord =
      IsActiveRecord(false, DateTime.now(), "init");
  bool isExpectingActive = false;

  Future<IsActiveRecord> _getCoreIsActiveRecord();
  Future<void> _startAll();
  Future<void> _stopAll();
  Future<void> startTun();
  Future<void> stopTun();

  void setIsToggling(bool val) {
    if (isToggling != val) {
      isToggling = val;
      notifyListeners();
    }
  }

  Future<IsActiveRecord> updateIsCoreActiveRecord() async {
    _setIsCoreActive(await _getCoreIsActiveRecord());
    return isCoreActiveRecord;
  }

  void _setIsCoreActive(IsActiveRecord r) {
    if (r.datetime.isBefore(isCoreActiveRecord.datetime)) {
      return;
    }
    if (r.isActive == isCoreActiveRecord.isActive) {
      isCoreActiveRecord = r;
      return;
    }
    isCoreActiveRecord = r;
    notifyListeners();
    trayMenu.updateContextMenu();
    return;
  }

  Future<void> start() async {
    /// check is toggling
    if (isToggling) return;
    setIsToggling(true);
    isExpectingActive = true;

    /// check is already active
    if ((await updateIsCoreActiveRecord()).isActive) {
      setIsToggling(false);
      return;
    }

    /// prepare
    await init();
    await File(p.join(folder.path, 'log', 'core.log')).writeAsString("");

    /// start
    await _startAll();
  }

  Future<void> stop() async {
    /// check is toggling
    if (isToggling) return;
    setIsToggling(true);
    isExpectingActive = false;

    /// check is already inactive
    if (!(await updateIsCoreActiveRecord()).isActive) {
      setIsToggling(false);
      return;
    }

    /// stop
    await _stopAll();
  }

  Future<bool> isTunActive();

  int? _selectedProfileId;
  ProfileData? _selectedProfile;
  late bool _isExec;
  String? corePath;
  String? _workingDir;
  String? _assetPath;
  late List<String> _coreArgList;
  Map<String, String>? _environment;
  late Map<String, dynamic> coreRawCfgMap;
  late Directory folder;

  String? _tunSingBoxCorePath;
  String? _tunSingBoxWorkingDir;
  final List<String> _tunSingBoxCoreArgList = [
    "run",
    "-c",
    p.join(
      global.applicationSupportDirectory.path,
      'conf',
      'tun.sing_box.gen.json',
    )
  ];

  bool getIsExecTun() {
    logger.d(prefs.getBool("tun"));
    return prefs.getBool("tun")! &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

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

    // check update
    updateProfileWithGroupRemote(_selectedProfile!);

    // gen config.json
    folder = global.applicationSupportDirectory;
    final config = File(p.join(folder.path, 'conf', 'core.gen.json'));
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
      throw Exception("No core of type specified by the profile is selected.");
    }
    _isExec = core.read(db.core.isExec)!;
    if (_isExec) {
      await prefs.setBool("core.useEmbedded", false);
      corePath = core.read(db.asset.path);
      if (corePath == null) {
        throw Exception("Core path is null.");
      } else {
        prefs.setString('core.path', corePath!);
      }
      _workingDir ??= File(corePath!).parent.path;
    } else {
      await prefs.setBool("core.useEmbedded", true);
    }

    // check sing-box path if tun is enabled
    if (getIsExecTun()) {
      if (!await PlatformElevation.isElevated()) {
        throw Exception("Permission denied: Tun");
      }

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
      if (core == null) {
        throw Exception("Tun needs a sing-box core.");
      }
      _isExec = core.read(db.core.isExec)!;
      if (_isExec) {
        _tunSingBoxCorePath = core.read(db.asset.path);
        if (_tunSingBoxCorePath == null) {
          throw Exception("sing-box path is null.");
        } else {
          prefs.setString('tun.singBox.core.path', _tunSingBoxCorePath!);
        }
        _tunSingBoxWorkingDir ??= File(_tunSingBoxCorePath!).parent.path;
      }

      // gen config.json
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

/// Direct processCore exec, need foreground, typically for desktop
class VPNManagerExec extends VPNManager {
  Process? processCore;
  Process? processTun;
  int? corePid;
  int? tunPid;

  @override
  Future<IsActiveRecord> _getCoreIsActiveRecord() async {
    final now = DateTime.now();
    if (processCore != null) {
      return IsActiveRecord(true, now, "processCore");
    } else {
      final coreCommandLine = "$corePath ${_coreArgList.join(' ')}";
      corePid = await PlatformProcess.getProcessPid(coreCommandLine);
      return IsActiveRecord(corePid != null, now, "port");
    }
  }

  _startCore() async {
    processCore = await Process.start(
      corePath!,
      _coreArgList,
      workingDirectory: _workingDir,
      environment: _environment,
    );
  }

  _stopCore() async {
    if (processCore != null) {
      processCore!.kill();
      processCore = null;
      await updateIsCoreActiveRecord();
      setIsToggling(false);
      return;
    }
    if (corePid != null) {
      Process.killPid(corePid!);
      await updateIsCoreActiveRecord();
      setIsToggling(false);
      return;
    }
  }

  @override
  isTunActive() async {
    if (processTun != null) {
      return true;
    } else {
      final tunCommandLine =
          "$_tunSingBoxCorePath ${_tunSingBoxCoreArgList.join(' ')}";
      tunPid = await PlatformProcess.getProcessPid(tunCommandLine);
      return tunPid != null;
    }
  }

  @override
  startTun() async {
    if (getIsExecTun() && processTun == null) {
      processTun = await Process.start(
        _tunSingBoxCorePath!,
        _tunSingBoxCoreArgList,
        workingDirectory: _tunSingBoxWorkingDir,
      );
    }
  }

  @override
  stopTun() async {
    processTun?.kill();
    processTun = null;
    if (tunPid != null) {
      Process.killPid(tunPid!);
    }
  }

  @override
  _startAll() async {
    await _startCore();
    await startTun();
    await updateIsCoreActiveRecord();
    setIsToggling(false);
    return;
  }

  @override
  _stopAll() async {
    await stopTun();
    await _stopCore();
    await updateIsCoreActiveRecord();
    setIsToggling(false);
    return;
  }

  Future<bool> isPortOccupied(int port) async {
    try {
      await ServerSocket.bind(InternetAddress.anyIPv4, port);
      return false; // Port is available
    } on SocketException catch (e) {
      logger.d("$e");
      return true; // Port is occupied
    }
    // return false;
    // catch (e) {
    //   rethrow; // Rethrow other exceptions for debugging
    // }
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
      final newIsCoreActive = call.method == 'onCoreActivated';
      _setIsCoreActive(
          IsActiveRecord(newIsCoreActive, DateTime.now(), call.method));
      // if (newIsCoreActive == isExpectingActive){
      // logger.d"setIsToggling: false");
      setIsToggling(false);
      // }
    } else if (call.method == 'onTileToggled') {
      isExpectingActive = call.arguments as bool;
      // logger.d"isExpectingActive: ${call.arguments}");
      /// cannot promise onTileToggled reach before onCoreActivated/onCoreDeactivated
      // setIsToggling(true);
    }
  }

  @override
  Future<IsActiveRecord> _getCoreIsActiveRecord() async {
    final now = DateTime.now();
    final newIsCoreActive =
        await platform.invokeMethod('vpn.isCoreActive') as bool;
    return IsActiveRecord(newIsCoreActive, now, "vpn.isCoreActive");
  }

  @override
  _startAll() async {
    await platform.invokeMethod('vpn.startAll');
  }

  @override
  _stopAll() async {
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
  isTunActive() async {
    return await platform.invokeMethod('vpn.isTunActive') as bool;
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
