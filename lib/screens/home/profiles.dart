import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:fv2ray/utils/db.dart';
import 'package:intl/intl.dart';

import '../profile.dart';

class ProfileList extends StatefulWidget {
  const ProfileList({
    super.key,
  });

  @override
  State<ProfileList> createState() => _ProfileListState();
}

enum ProfileAction {
  delete,
}

class _ProfileListState extends State<ProfileList> {
  void _addProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((res) {
      if (res['ok'] == true) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: _profiles.map((profile) {
            final lastUpdated = DateFormat().format(profile.lastUpdated);
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(profile.name.toString()),
                subtitle: Text('last updated: $lastUpdated'),
                trailing: PopupMenuButton<ProfileAction>(
                  onSelected: (value) => handleProfileAction(profile, value),
                  itemBuilder: (context) => ProfileAction.values
                      .map((action) => PopupMenuItem(
                            value: action,
                            child: Text(action.name),
                          ))
                      .toList(),
                ),
                onTap: () => {_editProfile(profile)},
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _addProfile,
          tooltip: 'add',
          child: const Icon(Icons.note_add)),
    );
  }
}
