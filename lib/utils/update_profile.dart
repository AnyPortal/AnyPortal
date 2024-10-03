import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;

import '../../../models/profile.dart';
import '../../../utils/db.dart';

Future<bool> updateProfile({
  ProfileData? oldProfile,
  String? name,
  ProfileType? profileType,
  String? url = "",
  int? autoUpdateInterval = 0,
  String? coreCfg = "",
}) async {
    if (oldProfile != null) {
      name ??= oldProfile.name;
      profileType ??= oldProfile.type;
      coreCfg ??= oldProfile.coreCfg;
      final profileId = oldProfile.id;
      switch (profileType) {
        case ProfileType.remote:
          final profileRemote = await (db.select(db.profileRemote)
                ..where((p) => p.profileId.equals(profileId)))
              .getSingle();
          url ??= profileRemote.url;
        case ProfileType.local:
      }
    }

  await db.transaction(() async {
    int profileId = 0;
    if (oldProfile != null) {
      profileId = oldProfile.id;
    } else {
      profileId = await db.into(db.profile).insertOnConflictUpdate(
          ProfileCompanion(
              name: drift.Value(name!),
              lastUpdated: drift.Value(DateTime.now()),
              type: drift.Value(profileType!),
              coreCfg: drift.Value(coreCfg!)));
    }

    switch (profileType!) {
      case ProfileType.remote:
        final response = await http.get(Uri.parse(url!));
        String coreCfg = "{}";
        if (response.statusCode == 200) {
          coreCfg = response.body;
        } else {
          throw Exception('failed to fetch url');
        }

        await db.into(db.profile).insertOnConflictUpdate(ProfileCompanion(
              id: drift.Value(profileId),
              name: drift.Value(name!),
              lastUpdated: drift.Value(DateTime.now()),
              coreCfg: drift.Value(coreCfg),
              type: drift.Value(profileType),
            ));
        await db
            .into(db.profileRemote)
            .insertOnConflictUpdate(ProfileRemoteCompanion(
              profileId: drift.Value(profileId),
              url: drift.Value(url),
              autoUpdateInterval: drift.Value(autoUpdateInterval!),
            ));
      case ProfileType.local:
        await db.into(db.profile).insertOnConflictUpdate(ProfileCompanion(
              id: drift.Value(profileId),
              name: drift.Value(name!),
              lastUpdated: drift.Value(DateTime.now()),
              coreCfg: drift.Value(coreCfg!),
              type: drift.Value(profileType),
            ));
        await db.into(db.profileLocal).insertOnConflictUpdate(
            ProfileLocalCompanion(profileId: drift.Value(profileId)));
    }
  });
  return true;
}
