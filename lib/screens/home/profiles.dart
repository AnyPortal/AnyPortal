import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:fv2ray/utils/db.dart';
import 'package:intl/intl.dart';

import '../../utils/prefs.dart';
import 'profiles/edit.dart';

class ProfileList extends StatefulWidget {
  const ProfileList({
    super.key,
  });

  @override
  State<ProfileList> createState() => _ProfileListState();
}

enum ProfileAction {
  delete,
  edit,
}

class _ProfileListState extends State<ProfileList> {
  int? _selectedProfileId = prefs.getInt('app.selectedProfileId');

  void _addProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        setState(() {
          _loadProfiles();
        });
      }
    });
  }

  void _editProfile(Profile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileScreen(
                profile: profile,
              )),
    );
  }

  List<Profile> _profiles = [];

  Future<void> _loadProfiles() async {
    final profiles = await (db.select(db.profiles)
          ..orderBy([
            (u) => OrderingTerm(
                  expression: u.name,
                )
          ]))
        .get();
    setState(() {
      _profiles = profiles;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void handleProfileAction(Profile profile, ProfileAction action) async {
    switch (action) {
      case ProfileAction.delete:
        await (db.delete(db.profiles)..where((t) => t.id.equals(profile.id)))
            .go();
        _loadProfiles();
      case ProfileAction.edit:
        _editProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: _profiles.map<Widget>((profile) {
                final lastUpdated = DateFormat().format(profile.lastUpdated);
                return RadioListTile(
                  value: profile.id,
                  groupValue: _selectedProfileId,
                  onChanged: (value) {
                    prefs.setInt('app.selectedProfileId', value!);
                    setState(() {
                      _selectedProfileId = value;
                    });
                  },
                  // title:  ListTile(
                  title: Text(profile.name.toString()),
                  subtitle: Text('last updated: $lastUpdated'),
                  secondary: PopupMenuButton<ProfileAction>(
                    onSelected: (value) => handleProfileAction(profile, value),
                    itemBuilder: (context) => ProfileAction.values
                        .map((action) => PopupMenuItem(
                              value: action,
                              child: Text(action.name),
                            ))
                        .toList(),
                  ),
                  // ),
                );
              }).toList() +
              [
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 72,
                  ),
                )
              ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _addProfile,
          tooltip: 'add',
          child: const Icon(Icons.note_add)),
    );
  }
}
