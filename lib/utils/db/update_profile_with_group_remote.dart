import 'dart:async';
import 'dart:io';

import '../../models/profile.dart';
import '../../models/profile_group.dart';
import '../db.dart';

import 'update_profile.dart';
import 'update_profile_group.dart';

Future<bool> updateProfileWithGroupRemote(ProfileData profile) async {
  if (profile.type == ProfileType.remote) {
    final profileRemote = await (db.select(
      db.profileRemote,
    )..where((p) => p.profileId.equals(profile.id))).getSingleOrNull();
    if (profileRemote == null) return false;

    bool shouldUpdate = false;
    final uri = Uri.parse(profileRemote.url);
    switch (uri.scheme) {
      case "http":
      case "https":
        shouldUpdate =
            profileRemote.autoUpdateInterval != 0 &&
            profile.updatedAt
                .add(Duration(seconds: profileRemote.autoUpdateInterval))
                .isBefore(DateTime.now());
      case "file":
        final f = File.fromUri(uri);
        final updatedAt = (await f.stat()).modified;
        if (profile.updatedAt != updatedAt) {
          shouldUpdate = true;
        }
    }

    if (shouldUpdate) {
      await updateProfile(
        oldProfile: profile,
      );
      profile = (await (db.select(
        db.profile,
      )..where((p) => p.id.equals(profile.id))).getSingleOrNull())!;
    }
  } else {
    final selectedProfileGroup = await (db.select(
      db.profileGroup,
    )..where((p) => p.id.equals(profile.profileGroupId))).getSingleOrNull();
    if (selectedProfileGroup != null &&
        selectedProfileGroup.type == ProfileGroupType.remote) {
      final profileGroupRemote =
          await (db.select(
                db.profileGroupRemote,
              )..where((p) => p.profileGroupId.equals(selectedProfileGroup.id)))
              .getSingleOrNull();
      if (profileGroupRemote!.protocol == ProfileGroupRemoteProtocol.file ||
          (profileGroupRemote.autoUpdateInterval != 0 &&
              selectedProfileGroup.updatedAt
                  .add(Duration(seconds: profileGroupRemote.autoUpdateInterval))
                  .isBefore(DateTime.now()))) {
        await updateProfileGroup(
          oldProfileGroup: selectedProfileGroup,
          coreTypeId: selectedProfileGroup.coreTypeId,
        );
        profile = (await (db.select(
          db.profile,
        )..where((p) => p.id.equals(profile.id))).getSingleOrNull())!;
      }
    }
  }
  return true;
}
