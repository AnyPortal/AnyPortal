import 'dart:async';
import 'dart:io';

import 'package:anyportal/utils/db.dart';
import 'package:drift/drift.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cron/cron.dart';

import 'asset_remote/app.dart';
import 'asset_remote/github.dart';
import 'db/update_profile.dart';
import 'db/update_profile_group.dart';
import 'logger.dart';
import 'prefs.dart';

void checkAllRemotes() {
  logger.d("starting: checkAllRemotes");
  checkAllAssetRemotes();
  checkAllProfileGroupRemotes();
  checkAllProfileRemotes();
  checkAppRemote();
  logger.d("finished: checkAllRemotes");
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    checkAllRemotes();
    return true;
  });
}

Future<bool> checkAllAssetRemotes() async {
  final assetRemotes = await (db.select(db.asset).join([
    innerJoin(db.assetRemote, db.asset.id.equalsExp(db.assetRemote.assetId)),
  ])).get();
  for (var assetRemote in assetRemotes) {
    final autoUpdateInterval =
        assetRemote.read(db.assetRemote.autoUpdateInterval)!;
    if (autoUpdateInterval > 0 &&
        assetRemote
            .read(db.asset.updatedAt)!
            .add(Duration(seconds: autoUpdateInterval))
            .isAfter(DateTime.now())) {
      AssetRemoteProtocolGithub.fromUrl(
        assetRemote.read(db.assetRemote.url)!,
      ).update(
        oldAsset: assetRemote,
        autoUpdateInterval: autoUpdateInterval,
      );
    }
  }
  return true;
}

Future<bool> checkAllProfileGroupRemotes() async {
  final profileGroupRemotes = await (db.select(db.profileGroup).join([
    innerJoin(db.profileGroupRemote,
        db.profileGroup.id.equalsExp(db.profileGroupRemote.profileGroupId)),
  ])).get();
  for (var profileGroupRemote in profileGroupRemotes) {
    final autoUpdateInterval =
        profileGroupRemote.read(db.profileGroupRemote.autoUpdateInterval)!;
    if (autoUpdateInterval > 0 &&
        profileGroupRemote
            .read(db.profileGroup.updatedAt)!
            .add(Duration(seconds: autoUpdateInterval))
            .isAfter(DateTime.now())) {
      await updateProfileGroup(
        oldProfileGroup: profileGroupRemote.readTable(db.profileGroup),
      );
    }
  }
  return true;
}

Future<bool> checkAllProfileRemotes() async {
  final profileRemotes = await (db.select(db.profile).join([
    innerJoin(
        db.profileRemote, db.profile.id.equalsExp(db.profileRemote.profileId)),
  ])).get();
  for (var profileRemote in profileRemotes) {
    final autoUpdateInterval =
        profileRemote.read(db.profileRemote.autoUpdateInterval)!;
    if (autoUpdateInterval > 0 &&
        profileRemote
            .read(db.profile.updatedAt)!
            .add(Duration(seconds: autoUpdateInterval))
            .isAfter(DateTime.now())) {
      await updateProfile(
        oldProfile: profileRemote.readTable(db.profile),
      );
    }
  }
  return true;
}

Future<bool> checkAppRemote() async {
  if (prefs.getBool("app.autoUpdate")!) {
    final autoUpdateInterval = 86400;
    final checkedAt = prefs.getInt("app.autoUpdate.checkedAt")!;
    if (checkedAt + autoUpdateInterval <
        DateTime.now().millisecondsSinceEpoch / 1000) {
      final ok = await AssetRemoteProtocolApp.init().update();
      if (ok) {
        prefs.setInt("app.autoUpdate.checkedAt",
            (DateTime.now().millisecondsSinceEpoch / 1000).toInt());
      }
    }
  }
  return true;
}

class PlatformTaskScheduler {
  final cron = Cron();

  void init() {
    /// check all remote assets every 15 mins
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().initialize(workmanagerCallbackDispatcher);
      Workmanager().registerPeriodicTask(
          "anyportal-periodic-task", "anyportalPeriodicTask",
          // When no frequency is provided the default 15 minutes is set.
          // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
          constraints: Constraints(
            networkType: NetworkType.connected,
          ));
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // checkAllRemotes();
      final delayedMinutes = DateTime.now().minute % 15;
      cron.schedule(Schedule.parse('*/15 * * * *'), () async {
        await Future.delayed(Duration(minutes: delayedMinutes));
        checkAllRemotes();
      });
    }
  }
}

class PlatformTaskSchedulerManager {
  late PlatformTaskScheduler taskScheduler;

  Future<void> init() async {
    logger.d("starting: PlatformTaskSchedulerManager.init");
    taskScheduler = PlatformTaskScheduler();
    taskScheduler.init();
    _completer.complete();
    logger.d("finished: PlatformTaskSchedulerManager.init");
  }

  static final PlatformTaskSchedulerManager _instance =
      PlatformTaskSchedulerManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  PlatformTaskSchedulerManager._internal();

  // Singleton accessor
  factory PlatformTaskSchedulerManager() {
    return _instance;
  }
}

final taskScheduler = PlatformTaskSchedulerManager().taskScheduler;
