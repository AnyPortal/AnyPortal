import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../../../models/profile_group.dart';
import '../../../../models/profile_group_remote/anyportal_rest.dart';
import '../../../../utils/db.dart';
import '../../extensions/localization.dart';
import '../../models/profile.dart' hide Profile;
import '../show_snack_bar_now.dart';
import '../with_context.dart';

Future<bool> updateProfileGroup({
  ProfileGroupData? oldProfileGroup,
  String? name,
  ProfileGroupType? profileGroupType,
  ProfileGroupRemoteProtocol? profileGroupRemoteProtocol,
  String? url,
  int? autoUpdateInterval,
  int? coreTypeId,
}) async {
  /// for profile group remote update
  String scheme = "";
  Set<String> newKeySet = {};
  Set<String> oldKeySet = {};
  List<ProfileData> oldProfileList = [];
  Map<String, ProfileData> oldProfileMap = {};
  int? profileGroupId;

  List<Profile> newProfiles = [];
  Set<FileSystemEntity> newFileSystemEntitySet = {};

  final coreTypeDataList = await (db.select(db.coreType).get());
  Map<String, int> coreType2Id = {};
  for (var coreTypeData in coreTypeDataList) {
    coreType2Id[coreTypeData.name] = coreTypeData.id;
  }

  if (oldProfileGroup != null) {
    name ??= oldProfileGroup.name;
    profileGroupType ?? oldProfileGroup.type;

    profileGroupType = oldProfileGroup.type;
    profileGroupId = oldProfileGroup.id;
    switch (profileGroupType) {
      case ProfileGroupType.remote:
        final profileGroupRemote = await (db.select(
          db.profileGroupRemote,
        )..where((p) => p.profileGroupId.equals(profileGroupId!))).getSingle();
        url ??= profileGroupRemote.url;
        autoUpdateInterval ??= profileGroupRemote.autoUpdateInterval;
        profileGroupRemoteProtocol ??= profileGroupRemote.protocol;
        coreTypeId = profileGroupRemote.coreTypeId;
      case ProfileGroupType.local:
    }
  }

  if (profileGroupType == ProfileGroupType.remote) {
    if (oldProfileGroup != null) {
      profileGroupId = oldProfileGroup.id;
      oldProfileList = await (db.select(
        db.profile,
      )..where((e) => e.profileGroupId.equals(profileGroupId!))).get();
      oldKeySet = oldProfileList.map((e) => e.key).toSet();
      oldProfileMap = {for (final p in oldProfileList) p.key: p};
    }

    final uri = Uri.parse(url!);
    switch (profileGroupRemoteProtocol) {
      case ProfileGroupRemoteProtocol.anyportalRest:
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final jsonString = response.body;
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          ProfileGroupRemoteAnyPortalREST profileGroupRemoteAnyPortalREST =
              ProfileGroupRemoteAnyPortalREST.fromJson(jsonMap);
          newProfiles = profileGroupRemoteAnyPortalREST.profiles;
          newKeySet = newProfiles.map((e) => e.key).toSet();
        } else {
          withContext((context) {
            showSnackBarNow(
              context,
              Text(context.loc.failed_to_fetch_url(url!)),
            );
          });
          throw Exception("failed to fetch: $url");
        }
        break;
      case ProfileGroupRemoteProtocol.file:
        try {
          final dir = Directory.fromUri(uri);
          await for (final e in dir.list(
            recursive: false,
            followLinks: false,
          )) {
            newFileSystemEntitySet.add(e);
            newKeySet.add(basenameWithoutExtension(e.path));
          }
        } catch (e) {
          withContext((context) {
            showSnackBarNow(context, Text("failed to process $url: $e"));
          });
          throw Exception("failed to process $url: $e");
        }
        break;
      case _:
        withContext((context) {
          showSnackBarNow(context, Text("scheme not supported: $scheme"));
        });
        throw Exception("scheme not supported: $scheme");
    }
  }

  await db.transaction(() async {
    int profileGroupId = 0;
    if (oldProfileGroup != null) {
      profileGroupId = oldProfileGroup.id;
    } else {
      profileGroupId = await db
          .into(db.profileGroup)
          .insertOnConflictUpdate(
            ProfileGroupCompanion(
              name: drift.Value(name!),
              updatedAt: drift.Value(DateTime.now()),
              type: drift.Value(profileGroupType!),
            ),
          );
    }

    switch (profileGroupType!) {
      case ProfileGroupType.remote:

        /// update profiles
        switch (profileGroupRemoteProtocol) {
          case ProfileGroupRemoteProtocol.file:
            for (final e in newFileSystemEntitySet) {
              final eStat = (await e.stat());
              if (eStat.type != FileSystemEntityType.file) continue;
              final f = File(e.path);
              String ext = extension(e.path);
              if (ext.isNotEmpty) {
                ext = ext.substring(1);
              }

              /// update
              final key = basenameWithoutExtension(e.path);
              if (oldProfileMap.containsKey(key)) {
                if (oldProfileMap[key]!.updatedAt == eStat.modified) continue;
                await (db.update(db.profile)..where(
                      (e) =>
                          (e.profileGroupId.equals(profileGroupId) &
                          e.key.equals(key)),
                    ))
                    .write(
                      ProfileCompanion(
                        name: drift.Value(key),
                        key: drift.Value(key),
                        coreCfg: drift.Value(await f.readAsString()),
                        coreCfgFmt: drift.Value(ext),
                        updatedAt: drift.Value(eStat.modified),
                        type: const drift.Value(ProfileType.local),
                        profileGroupId: drift.Value(profileGroupId),
                        coreTypeId: drift.Value(coreTypeId!),
                      ),
                    );
              } else {
                /// add
                await db
                    .into(db.profile)
                    .insert(
                      ProfileCompanion(
                        name: drift.Value(key),
                        key: drift.Value(key),
                        coreCfg: drift.Value(await f.readAsString()),
                        coreCfgFmt: drift.Value(ext),
                        updatedAt: drift.Value(eStat.modified),
                        type: const drift.Value(ProfileType.local),
                        profileGroupId: drift.Value(profileGroupId),
                        coreTypeId: drift.Value(coreTypeId!),
                      ),
                    );
              }
              for (var profile in oldProfileList) {
                if (!newKeySet.contains(profile.key)) {
                  /// delete
                  await (db.delete(
                    db.profile,
                  )..where((e) => e.id.equals(profile.id))).go();
                }
              }
            }
          case ProfileGroupRemoteProtocol.anyportalRest:
            for (final profile in newProfiles) {
              final coreConfigStr =
                  profile.format == "json" && profile.coreConfig is Map
                  ? jsonEncode(profile.coreConfig)
                  : profile.coreConfig;

              /// update
              if (oldKeySet.contains(profile.key)) {
                await (db.update(db.profile)..where(
                      (e) =>
                          (e.profileGroupId.equals(profileGroupId) &
                          e.key.equals(profile.key)),
                    ))
                    .write(
                      ProfileCompanion(
                        name: drift.Value(profile.name),
                        key: drift.Value(profile.key),
                        coreCfg: drift.Value(coreConfigStr),
                        coreCfgFmt: drift.Value(profile.format),
                        updatedAt: drift.Value(DateTime.now()),
                        type: const drift.Value(ProfileType.local),
                        profileGroupId: drift.Value(profileGroupId),
                        coreTypeId: drift.Value(coreType2Id[profile.coreType]!),
                      ),
                    );
              } else {
                /// add
                await db
                    .into(db.profile)
                    .insert(
                      ProfileCompanion(
                        name: drift.Value(profile.name),
                        key: drift.Value(profile.key),
                        coreCfg: drift.Value(profile.coreConfig),
                        coreCfgFmt: drift.Value(profile.format),
                        updatedAt: drift.Value(DateTime.now()),
                        type: const drift.Value(ProfileType.local),
                        profileGroupId: drift.Value(profileGroupId),
                        coreTypeId: drift.Value(coreType2Id[profile.coreType]!),
                      ),
                    );
              }
            }
            for (var profile in oldProfileList) {
              if (!newKeySet.contains(profile.key)) {
                /// delete
                await (db.delete(
                  db.profile,
                )..where((e) => e.id.equals(profile.id))).go();
              }
            }

            break;
          case _:
            withContext((context) {
              showSnackBarNow(
                context,
                Text("protocol not supported: $profileGroupRemoteProtocol"),
              );
            });
            throw Exception(
              "protocol not supported: $profileGroupRemoteProtocol",
            );
        }

        // update profile group
        await db
            .into(db.profileGroup)
            .insertOnConflictUpdate(
              ProfileGroupCompanion(
                id: drift.Value(profileGroupId),
                name: drift.Value(name!),
                updatedAt: drift.Value(DateTime.now()),
                type: drift.Value(profileGroupType),
              ),
            );
        await db
            .into(db.profileGroupRemote)
            .insertOnConflictUpdate(
              ProfileGroupRemoteCompanion(
                profileGroupId: drift.Value(profileGroupId),
                url: drift.Value(url!),
                autoUpdateInterval: drift.Value(autoUpdateInterval!),
                protocol: drift.Value(
                  profileGroupRemoteProtocol!,
                ),
                coreTypeId: drift.Value(coreTypeId ?? 0),
              ),
            );
      case ProfileGroupType.local:
        await db
            .into(db.profileGroup)
            .insertOnConflictUpdate(
              ProfileGroupCompanion(
                id: drift.Value(profileGroupId),
                name: drift.Value(name!),
                updatedAt: drift.Value(DateTime.now()),
                type: drift.Value(profileGroupType),
              ),
            );
        await db
            .into(db.profileGroupLocal)
            .insertOnConflictUpdate(
              ProfileGroupLocalCompanion(
                profileGroupId: drift.Value(profileGroupId),
              ),
            );
    }
  });
  return true;
}
