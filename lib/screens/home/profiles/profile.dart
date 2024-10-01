import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../models/profile.dart';
import '../../../utils/db.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileData? profile;

  const ProfileScreen({
    super.key,
    this.profile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _autoUpdateIntervalController = TextEditingController(text: '0');
  final _coreCfgController = TextEditingController(text: '{}');

  // ignore: prefer_final_fields
  ProfileType _profileType = ProfileType.remote;

  Future<void> _loadProfile() async {
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _profileType = widget.profile!.type;
      _coreCfgController.text = widget.profile!.coreCfg;
      final profileId = widget.profile!.id;
      switch (_profileType) {
        case ProfileType.remote:
          final profileRemote = await (db.select(db.profileRemote)
                ..where((p) => p.profileId.equals(profileId)))
              .getSingle();
          _urlController.text = profileRemote.url;
        case ProfileType.local:
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

        await db.transaction(() async {
          int profileId = 0;
          if (widget.profile != null) {
            profileId = widget.profile!.id;
          } else {
            profileId = await db.into(db.profile).insertOnConflictUpdate(
                ProfileCompanion(
                    name: drift.Value(name),
                    lastUpdated: drift.Value(DateTime.now()),
                    type: drift.Value(_profileType),
                    coreCfg: drift.Value(_coreCfgController.text)));
          }

          switch (_profileType) {
            case ProfileType.remote:
              final response = await http.get(Uri.parse(url));
              String coreCfg = "{}";
              if (response.statusCode == 200) {
                coreCfg = response.body;
              } else {
                throw Exception('failed to fetch url');
              }

              await db
                  .into(db.profile)
                  .insertOnConflictUpdate(ProfileCompanion(
                    id: drift.Value(profileId),
                    name: drift.Value(name),
                    lastUpdated: drift.Value(DateTime.now()),
                    coreCfg: drift.Value(coreCfg),
                    type: drift.Value(_profileType),
                  ));
              await db
                  .into(db.profileRemote)
                  .insertOnConflictUpdate(ProfileRemoteCompanion(
                    profileId: drift.Value(profileId),
                    url: drift.Value(url),
                    autoUpdateInterval: drift.Value(autoUpdateInterval),
                  ));
            case ProfileType.local:
              await db
                  .into(db.profile)
                  .insertOnConflictUpdate(ProfileCompanion(
                    id: drift.Value(profileId),
                    name: drift.Value(name),
                    lastUpdated: drift.Value(DateTime.now()),
                    coreCfg: drift.Value(_coreCfgController.text),
                    type: drift.Value(_profileType),
                  ));
              await db.into(db.profileLocal).insertOnConflictUpdate(
                  ProfileLocalCompanion(profileId: drift.Value(profileId)));
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
      DropdownButtonFormField<ProfileType>(
        decoration: const InputDecoration(
          labelText: 'type',
          border: OutlineInputBorder(),
        ),
        items: ProfileType.values.map((ProfileType t) {
          return DropdownMenuItem<ProfileType>(value: t, child: Text(t.name));
        }).toList(),
        onChanged: widget.profile != null
            ? null
            : (value) {
                setState(() {
                  _profileType = value!;
                });
              },
        value: _profileType,
      ),
      if (_profileType == ProfileType.remote)
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'url',
            hintText: 'https://url/to/config/json/',
            border: OutlineInputBorder(),
          ),
        ),
      // if (_profileType == ProfileType.remote)
      //   TextFormField(
      //     controller: _autoUpdateIntervalController,
      //     decoration: const InputDecoration(
      //       labelText: 'auto update interval (minutes), 0 to disable',
      //       border: OutlineInputBorder(),
      //     ),
      //     keyboardType: TextInputType.number,
      //   ),
      if (_profileType == ProfileType.local)
        TextFormField(
          controller: _coreCfgController,
          decoration: const InputDecoration(
            labelText: 'json',
            border: OutlineInputBorder(),
          ),
          maxLines: 16,
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
        title: const Text("Edit profile"),
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
