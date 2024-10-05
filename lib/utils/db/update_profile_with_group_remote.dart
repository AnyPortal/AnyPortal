import 'dart:async';

import 'package:fv2ray/utils/db/update_profile.dart';
import 'package:fv2ray/utils/db/update_profile_group.dart';

import '../../models/profile.dart';
import '../../models/profile_group.dart';
import '../db.dart';

Future<bool> updateProfileWithGroupRemote(ProfileData profile) async {
  if (profile.type == ProfileType.remote) {
    final profileRemote = await (db.select(db.profileRemote)
          ..where((p) => p.profileId.equals(profile.id)))
        .getSingleOrNull();
    if (profileRemote!.autoUpdateInterval != 0 &&
        profile.updatedAt
            .add(Duration(seconds: profileRemote.autoUpdateInterval))
            .isBefore(DateTime.now())) {
      await updateProfile(
        oldProfile: profile,
      );
      profile = (await (db.select(db.profile)
            ..where((p) => p.id.equals(profile.id)))
          .getSingleOrNull())!;
    }
  } else {
    final selectedProfileGroup = await (db.select(db.profileGroup)
          ..where((p) => p.id.equals(profile.profileGroupId)))
        .getSingleOrNull();
    if (selectedProfileGroup != null &&
        selectedProfileGroup.type == ProfileGroupType.remote) {
      final profileGroupRemote = await (db.select(db.profileGroupRemote)
            ..where((p) => p.profileGroupId.equals(selectedProfileGroup.id)))
          .getSingleOrNull();
      if (profileGroupRemote!.autoUpdateInterval != 0 &&
          selectedProfileGroup.updatedAt
              .add(Duration(seconds: profileGroupRemote.autoUpdateInterval))
              .isBefore(DateTime.now())) {
        await updateProfileGroup(
          oldProfileGroup: selectedProfileGroup,
        );
        profile = (await (db.select(db.profile)
              ..where((p) => p.id.equals(profile.id)))
            .getSingleOrNull())!;
      }
    }
  }
  return true;
}
