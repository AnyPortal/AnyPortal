import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:fv2ray/models/profile.dart';
import 'package:http/http.dart' as http;

import '../../../../models/profile_group.dart';
import '../../../../models/profile_group_remote/fv2ray_rest.dart';
import '../../../../utils/db.dart';

Future<bool> updateProfileGroup({
  ProfileGroupData? oldProfileGroup,
  String? name,
  ProfileGroupType? profileGroupType, 
  String? url,
  int? autoUpdateInterval,
}) async {
  // for profile group remote update
  ProfileGroupRemoteFv2rayREST? profileGroupRemoteFv2rayREST;
  Set<String> newNameSet = {};
  Set<String> oldNameSet = {};
  List<ProfileData> oldProfileList = [];
  int? profileGroupId;

  final coreTypeDataList = await (db.select(db.coreType).get());
  Map<String, int> coreType2Id = {};
  for (var coreTypeData in coreTypeDataList){
    coreType2Id[coreTypeData.name] = coreTypeData.id;
  }

  if (oldProfileGroup != null) {
    name ??= oldProfileGroup.name;
    profileGroupType ?? oldProfileGroup.type;

      profileGroupType = oldProfileGroup.type;
      profileGroupId = oldProfileGroup.id;
      switch (profileGroupType) {
        case ProfileGroupType.remote:
          final profileGroupRemote = await (db.select(db.profileGroupRemote)
                ..where((p) => p.profileGroupId.equals(profileGroupId!)))
              .getSingle();
              url ??= profileGroupRemote.url;
              autoUpdateInterval ??= profileGroupRemote.autoUpdateInterval;
        case ProfileGroupType.local:
      }
  }

  if (profileGroupType == ProfileGroupType.remote) {
    final response = await http.get(Uri.parse(url!));
    String jsonString = "{}";
    if (response.statusCode == 200) {
      jsonString = response.body;
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      profileGroupRemoteFv2rayREST =
          ProfileGroupRemoteFv2rayREST.fromJson(jsonMap);
      newNameSet =
          profileGroupRemoteFv2rayREST.profiles.map((e) => e.name).toSet();
      if (oldProfileGroup != null) {
        profileGroupId = oldProfileGroup.id;
        oldProfileList = await (db.select(db.profile)
              ..where((e) => e.profileGroupId.equals(profileGroupId!)))
            .get();
        oldNameSet = oldProfileList.map((e) => e.name).toSet();
      }
    } else {
      throw Exception('failed to fetch url');
    }
  }

  await db.transaction(() async {
    int profileGroupId = 0;
    if (oldProfileGroup != null) {
      profileGroupId = oldProfileGroup.id;
    } else {
      profileGroupId = await db.into(db.profileGroup).insertOnConflictUpdate(
          ProfileGroupCompanion(
              name: drift.Value(name!),
              updatedAt: drift.Value(DateTime.now()),
              type: drift.Value(profileGroupType!)));
    }

    switch (profileGroupType!) {
      case ProfileGroupType.remote:
        // update profiles
        for (var profile in profileGroupRemoteFv2rayREST!.profiles) {
          // update
          if (oldNameSet.contains(profile.name)) {
            await (db.update(db.profile)
                  ..where((e) => e.name.equals(profile.name)))
                .write(ProfileCompanion(
              name: drift.Value(profile.name),
              coreCfg: drift.Value(jsonEncode(profile.coreConfig)),
              updatedAt: drift.Value(DateTime.now()),
              type: const drift.Value(ProfileType.local),
              profileGroupId: drift.Value(profileGroupId),
              coreTypeId: drift.Value(coreType2Id[profile.coreType]!),
            ));
          } else {
            // add
            await db.into(db.profile).insert(ProfileCompanion(
                  name: drift.Value(profile.name),
                  coreCfg: drift.Value(jsonEncode(profile.coreConfig)),
                  updatedAt: drift.Value(DateTime.now()),
                  type: const drift.Value(ProfileType.local),
                  profileGroupId: drift.Value(profileGroupId),
                  coreTypeId: drift.Value(coreType2Id[profile.coreType]!),
                ));
          }
        }
        for (var profile in oldProfileList) {
          if (!newNameSet.contains(profile.name)) {
            // delete
            await (db.delete(db.profile)..where((e) => e.id.equals(profile.id)))
                .go();
          }
        }

        // update profile group
        await db
            .into(db.profileGroup)
            .insertOnConflictUpdate(ProfileGroupCompanion(
              id: drift.Value(profileGroupId),
              name: drift.Value(name!),
              updatedAt: drift.Value(DateTime.now()),
              type: drift.Value(profileGroupType),
            ));
        await db.into(db.profileGroupRemote).insertOnConflictUpdate(
            ProfileGroupRemoteCompanion(
                profileGroupId: drift.Value(profileGroupId),
                url: drift.Value(url!),
                autoUpdateInterval: drift.Value(autoUpdateInterval!),
                format:
                    const drift.Value(ProfileGroupRemoteFormat.fv2rayRest)));
      case ProfileGroupType.local:
        await db
            .into(db.profileGroup)
            .insertOnConflictUpdate(ProfileGroupCompanion(
              id: drift.Value(profileGroupId),
              name: drift.Value(name!),
              updatedAt: drift.Value(DateTime.now()),
              type: drift.Value(profileGroupType),
            ));
        await db.into(db.profileGroupLocal).insertOnConflictUpdate(
            ProfileGroupLocalCompanion(
                profileGroupId: drift.Value(profileGroupId)));
    }
  });
  return true;
}
