import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;

import '../../../../models/profile.dart';
import '../../../../utils/db.dart';
import '../show_snack_bar_now.dart';
import '../with_context.dart';

Future<bool> updateProfile({
  ProfileData? oldProfile,
  String? name,
  String? key,
  ProfileType? profileType,
  String? url = "",
  int? autoUpdateInterval = 0,
  int? coreTypeId,
  String? coreCfg = "",
  String? coreCfgFmt = "json",
  int? profileGroupId = 0,
}) async {
  if (oldProfile != null) {
    name ??= oldProfile.name;
    key ??= oldProfile.key;
    profileType ??= oldProfile.type;
    coreCfg ??= oldProfile.coreCfg;
    final profileId = oldProfile.id;
    switch (profileType) {
      case ProfileType.remote:
        final profileRemote = await (db.select(
          db.profileRemote,
        )..where((p) => p.profileId.equals(profileId))).getSingle();
        url ??= profileRemote.url;
      case ProfileType.local:
    }
  } else {
    key = name;
  }

  await db.transaction(() async {
    int profileId = 0;
    if (oldProfile != null) {
      profileId = oldProfile.id;
    } else {
      profileId = await db
          .into(db.profile)
          .insertOnConflictUpdate(
            ProfileCompanion(
              name: drift.Value(name!),
              key: drift.Value(key!),
              updatedAt: drift.Value(DateTime.now()),
              type: drift.Value(profileType!),
              coreTypeId: drift.Value(coreTypeId),
              coreCfg: drift.Value(coreCfg!),
              coreCfgFmt: drift.Value(coreCfgFmt!),
              profileGroupId: drift.Value(profileGroupId!),
            ),
          );
    }

    switch (profileType!) {
      case ProfileType.remote:
        String coreCfg = "{}";
        DateTime? updatedAt;

        final uri = Uri.parse(url!);
        switch (uri.scheme) {
          case "http":
          case "https":
            final response = await http.get(uri);
            if (response.statusCode == 200) {
              coreCfg = response.body;
            } else {
              withContext((context) {
                showSnackBarNow(context, Text("failed to fetch: $url"));
              });
              throw Exception("failed to fetch: $url");
            }
          case "file":
            try {
              final f = File.fromUri(uri);
              coreCfg = await f.readAsString();
              updatedAt = (await f.stat()).modified;
            } catch (e) {
              withContext((context) {
                showSnackBarNow(context, Text("failed to read file: $e"));
              });
              throw Exception("failed to read file: $e");
            }
          case _:
            withContext((context) {
              showSnackBarNow(
                context,
                Text("unsupported scheme: ${uri.scheme}"),
              );
            });
            throw Exception("unsupported scheme: ${uri.scheme}");
        }

        await db
            .into(db.profile)
            .insertOnConflictUpdate(
              ProfileCompanion(
                id: drift.Value(profileId),
                name: drift.Value(name!),
                key: drift.Value(key!),
                updatedAt: drift.Value(updatedAt ?? DateTime.now()),
                coreCfg: drift.Value(coreCfg),
                type: drift.Value(profileType),
                coreTypeId: drift.Value(coreTypeId),
                coreCfgFmt: drift.Value(coreCfgFmt!),
                profileGroupId: drift.Value(profileGroupId!),
              ),
            );
        await db
            .into(db.profileRemote)
            .insertOnConflictUpdate(
              ProfileRemoteCompanion(
                profileId: drift.Value(profileId),
                url: drift.Value(url),
                autoUpdateInterval: drift.Value(autoUpdateInterval!),
              ),
            );
      case ProfileType.local:
        await db
            .into(db.profile)
            .insertOnConflictUpdate(
              ProfileCompanion(
                id: drift.Value(profileId),
                name: drift.Value(name!),
                key: drift.Value(key!),
                updatedAt: drift.Value(DateTime.now()),
                coreCfg: drift.Value(coreCfg!),
                type: drift.Value(profileType),
                coreTypeId: drift.Value(coreTypeId),
                coreCfgFmt: drift.Value(coreCfgFmt!),
                profileGroupId: drift.Value(profileGroupId!),
              ),
            );
        await db
            .into(db.profileLocal)
            .insertOnConflictUpdate(
              ProfileLocalCompanion(profileId: drift.Value(profileId)),
            );
    }
  });
  return true;
}
