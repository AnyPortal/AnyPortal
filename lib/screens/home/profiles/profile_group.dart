import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:fv2ray/models/profile.dart';
import 'package:http/http.dart' as http;

import '../../../models/profile_group.dart';
import '../../../models/profile_group_remote/fv2ray_rest.dart';
import '../../../utils/db.dart';

class ProfileGroupScreen extends StatefulWidget {
  final ProfileGroupData? profileGroup;

  const ProfileGroupScreen({
    super.key,
    this.profileGroup,
  });

  @override
  State<ProfileGroupScreen> createState() => _ProfileGroupScreenState();
}

class _ProfileGroupScreenState extends State<ProfileGroupScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _autoUpdateIntervalController = TextEditingController(text: '0');

  // ignore: prefer_final_fields
  ProfileGroupType _profileGroupType = ProfileGroupType.remote;

  Future<void> _loadProfileGroup() async {
    if (widget.profileGroup != null) {
      _nameController.text = widget.profileGroup!.name;
      _profileGroupType = widget.profileGroup!.type;
      final profileGroupId = widget.profileGroup!.id;
      switch (_profileGroupType) {
        case ProfileGroupType.remote:
          final profileGroupRemote = await (db.select(db.profileGroupRemote)
                ..where((p) => p.profileGroupId.equals(profileGroupId)))
              .getSingle();
          _urlController.text = profileGroupRemote.url;
        case ProfileGroupType.local:
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileGroup();
  }

  // Method to handle form submission
  void _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    bool ok = false;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        // Get the values from the controllers
        String name = _nameController.text;
        String url = _urlController.text;
        int autoUpdateInterval = int.parse(_autoUpdateIntervalController.text);

        // for profile group remote update
        ProfileGroupRemoteFv2rayREST? profileGroupRemoteFv2rayREST;
        Set<String> newNameSet = {};
        Set<String> oldNameSet = {};
        List<ProfileData> oldProfileList = [];
        int? profileGroupId;

        if (_profileGroupType == ProfileGroupType.remote) {
          final response = await http.get(Uri.parse(url));
          String jsonString = "{}";
          if (response.statusCode == 200) {
            jsonString = response.body;
            final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
            profileGroupRemoteFv2rayREST =
                ProfileGroupRemoteFv2rayREST.fromJson(jsonMap);
            newNameSet = profileGroupRemoteFv2rayREST.profiles
                .map((e) => e.name)
                .toSet();
            if (widget.profileGroup != null) {
              profileGroupId = widget.profileGroup!.id;
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
          if (widget.profileGroup != null) {
            profileGroupId = widget.profileGroup!.id;
          } else {
            profileGroupId = await db
                .into(db.profileGroup)
                .insertOnConflictUpdate(ProfileGroupCompanion(
                    name: drift.Value(name),
                    lastUpdated: drift.Value(DateTime.now()),
                    type: drift.Value(_profileGroupType)));
          }

          switch (_profileGroupType) {
            case ProfileGroupType.remote:
              // update profiles
              for (var profile in profileGroupRemoteFv2rayREST!.profiles) {
                // update
                if (oldNameSet.contains(profile.name)){
                  await (db.update(db.profile)..where((e) => e.name.equals(profile.name))).write(ProfileCompanion(
                      name: drift.Value(profile.name),
                      coreCfg: drift.Value(jsonEncode(profile.config)),
                      lastUpdated: drift.Value(DateTime.now()),
                      type: const drift.Value(ProfileType.local),
                      profileGroupId: drift.Value(profileGroupId),
                    )
                  );
                } else {
                  // add
                  await db.into(db.profile).insert(
                    ProfileCompanion(
                      name: drift.Value(profile.name),
                      coreCfg: drift.Value(jsonEncode(profile.config)),
                      lastUpdated: drift.Value(DateTime.now()),
                      type: const drift.Value(ProfileType.local),
                      profileGroupId: drift.Value(profileGroupId),
                    )
                  );
                }
              }
              for (var profile in oldProfileList) {
                if (!newNameSet.contains(profile.name)) {
                  // delete
                  await (db.delete(db.profile)
                        ..where((e) => e.id.equals(profile.id)))
                      .go();
                }
              }

              // update profile group
              await db
                  .into(db.profileGroup)
                  .insertOnConflictUpdate(ProfileGroupCompanion(
                    id: drift.Value(profileGroupId),
                    name: drift.Value(name),
                    lastUpdated: drift.Value(DateTime.now()),
                    type: drift.Value(_profileGroupType),
                  ));
              await db
                  .into(db.profileGroupRemote)
                  .insertOnConflictUpdate(ProfileGroupRemoteCompanion(
                    profileGroupId: drift.Value(profileGroupId),
                    url: drift.Value(url),
                    autoUpdateInterval: drift.Value(autoUpdateInterval),
                    format: const drift.Value(ProfileGroupRemoteFormat.fv2rayRest)
                  ));
            case ProfileGroupType.local:
              await db
                  .into(db.profileGroup)
                  .insertOnConflictUpdate(ProfileGroupCompanion(
                    id: drift.Value(profileGroupId),
                    name: drift.Value(name),
                    lastUpdated: drift.Value(DateTime.now()),
                    type: drift.Value(_profileGroupType),
                  ));
              await db.into(db.profileGroupLocal).insertOnConflictUpdate(
                  ProfileGroupLocalCompanion(
                      profileGroupId: drift.Value(profileGroupId)));
          }
        });
      }
      ok = true;
    } catch (e) {
      final snackBar = SnackBar(
        content: Text("$e"),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (ok) {
      if (mounted) Navigator.pop(context, {'ok': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'name',
          border: OutlineInputBorder(),
        ),
      ),
      DropdownButtonFormField<ProfileGroupType>(
        decoration: const InputDecoration(
          labelText: 'type',
          border: OutlineInputBorder(),
        ),
        items: ProfileGroupType.values.map((ProfileGroupType t) {
          return DropdownMenuItem<ProfileGroupType>(
              value: t, child: Text(t.name));
        }).toList(),
        onChanged: widget.profileGroup != null
            ? null
            : (value) {
                setState(() {
                  _profileGroupType = value!;
                });
              },
        value: _profileGroupType,
      ),
      if (_profileGroupType == ProfileGroupType.remote)
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'url',
            hintText: 'https://url/to/config/json/',
            border: OutlineInputBorder(),
          ),
        ),
      Center(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          ),
          child: const Text('Save and update'),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Edit Profile Group"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView.separated(
            itemCount: fields.length,
            itemBuilder: (context, index) => fields[index],
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }
}
