import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:fv2ray/models/profile_group.dart';
import 'package:fv2ray/screens/home/profiles/profile_group.dart';
import 'package:fv2ray/utils/db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import '../../utils/prefs.dart';
import 'profiles/profile.dart';

class ProfileList extends StatefulWidget {
  const ProfileList({
    super.key,
  });

  @override
  State<ProfileList> createState() => _ProfileListState();
}

enum ProfilesAction {
  addProfile,
  addProfileGroup,
}

extension ToLCString on ProfilesAction {
  String toShortString(context) {
    switch (this) {
      case ProfilesAction.addProfile:
        return AppLocalizations.of(context)!.addProfile;
      case ProfilesAction.addProfileGroup:
        return AppLocalizations.of(context)!.addProfileGroup;
    }
  }
}

enum ProfileAction {
  delete,
  edit,
}

enum ProfileGroupAction {
  delete,
  edit,
}

class _ProfileListState extends State<ProfileList> {
  int? _selectedProfileId = prefs.getInt('app.selectedProfileId');
  var _highlightProfilesPopupMenuButton = false;

  void setHighlightProfilesPopupMenuButton() async {
    for (var i = 0; i < 5; ++i) {
      if (mounted) {
        setState(() {
          _highlightProfilesPopupMenuButton = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        return;
      }
    }
  }

  void handleProfilesAction(action) {
    switch (action) {
      case ProfilesAction.addProfile:
        _addProfile();
      case ProfilesAction.addProfileGroup:
        _addProfileGroup();
    }
  }

  void _addProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadProfiles();
      }
    });
  }

  void _addProfileGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileGroupScreen()),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadProfiles();
      }
    });
  }

  void _editProfile(ProfileData profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileScreen(
                profile: profile,
              )),
    ).then((res) {
      if (res != null && res['ok'] == true) {
        _loadProfiles();
      }
    });
  }

  void _editProfileGroup(int profileGroupId) async {
    final profileGroup = await (db.select(db.profileGroup)
          ..where((p) => p.id.equals(profileGroupId)))
        .getSingle();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileGroupScreen(
                  profileGroup: profileGroup,
                )),
      ).then((res) {
        if (res != null && res['ok'] == true) {
          _loadProfiles();
        }
      });
    }
  }

  Map<int, List<ProfileData>> _groupedProfiles = {};
  Map<int, ProfileGroupData> _profileGroups = {};

  final TreeNode _root = TreeNode.root();

  Future<void> _loadProfiles() async {
    final profiles = await (db.select(db.profile)
          ..orderBy([
            (u) => OrderingTerm(
                  expression: u.name,
                )
          ]))
        .get();
    final profileGroups = await (db.select(db.profileGroup)
          ..orderBy([
            (u) => OrderingTerm(
                  expression: u.name,
                )
          ]))
        .get();

    _groupedProfiles = {};
    for (var profile in profiles) {
      if (!_groupedProfiles.containsKey(profile.profileGroupId)) {
        _groupedProfiles[profile.profileGroupId] = [];
      }
      _groupedProfiles[profile.profileGroupId]!.add(profile);
    }
    _profileGroups = {};
    for (var profileGroup in profileGroups) {
      _profileGroups[profileGroup.id] = profileGroup;
    }

    _root.clear();

    for (var profileGroupId in _profileGroups.keys) {
      final profiles = _groupedProfiles[profileGroupId];
      if (profiles != null) {
        _root.add(TreeNode(
          data: profileGroupId,
          key: "$profileGroupId",
        )..addAll(profiles.map((profile) {
            return TreeNode(data: profile, key: "${profile.id}");
          }).toList()));
      }
    }

    if (profiles.isEmpty) {
      setHighlightProfilesPopupMenuButton();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void handleProfileAction(ProfileData profile, ProfileAction action) async {
    switch (action) {
      case ProfileAction.delete:
        await (db.delete(db.profile)..where((e) => e.id.equals(profile.id)))
            .go();
        _loadProfiles();
      case ProfileAction.edit:
        _editProfile(profile);
    }
  }

  void handleProfileGroupAction(
      int profileGroupId, ProfileGroupAction action) async {
    switch (action) {
      case ProfileGroupAction.delete:
        await db.transaction(() async {
          (db.delete(db.profile)
                ..where((e) => e.profileGroupId.equals(profileGroupId)))
              .go();
          // do not delete the default local group
          if (profileGroupId != 1) {
            (db.delete(db.profileGroup)
                  ..where((e) => e.id.equals(profileGroupId)))
                .go();
          }
        });
        _loadProfiles();
      case ProfileGroupAction.edit:
        _editProfileGroup(profileGroupId);
    }
  }

  String getProfileGroupTitle(ProfileGroupData profileGroup) {
    if (profileGroup.id == 1) {
      return "Standalone";
    }
    return profileGroup.name;
  }

  String getProfileGroupSubTitle(ProfileGroupData profileGroup) {
    if (profileGroup.id == 1) {
      return "Manually created profiles";
    }
    if (profileGroup.type == ProfileGroupType.local) {
      return "Local profile group";
    }
    return "${profileGroup.lastUpdated}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Expanded(child: Text(AppLocalizations.of(context)!.profiles)),
            SmoothHighlight(
                enabled: _highlightProfilesPopupMenuButton,
                color: Colors.grey,
                child: PopupMenuButton(
                  itemBuilder: (context) => ProfilesAction.values
                      .map((action) => PopupMenuItem(
                            value: action,
                            child: Text(action.toShortString(context)),
                          ))
                      .toList(),
                  onSelected: (value) => handleProfilesAction(value),
                )),
          ]),
                  ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: CustomScrollView(slivers: [
              SliverTreeView.simple(
                tree: _root,
                showRootNode: false,
                expansionIndicatorBuilder: (context, node) =>
                    ChevronIndicator.rightDown(
                  alignment: Alignment.centerLeft,
                  tree: node,
                ),
                indentation: const Indentation(style: IndentStyle.squareJoint),
                // onTreeReady: (controller) {
                //   if (true) controller.expandAllChildren(_root);
                // },
                builder: (context, node) {
                  if (node.level == 2) {
                    final profile = node.data as ProfileData;
                    return RadioListTile(
                        value: profile.id,
                        groupValue: _selectedProfileId,
                        onChanged: (value) {
                          prefs.setInt('app.selectedProfileId', value!);
                          prefs.setString('app.selectedProfileName', profile.name);
                          setState(() {
                            _selectedProfileId = value;
                          });
                        },
                        title: Text(profile.name.toString()),
                        subtitle: Text('last updated: ${profile.lastUpdated}'),
                        secondary: PopupMenuButton<ProfileAction>(
                          onSelected: (value) =>
                              handleProfileAction(profile, value),
                          itemBuilder: (context) => ProfileAction.values
                              .map((action) => PopupMenuItem(
                                    value: action,
                                    child: Text(action.name),
                                  ))
                              .toList(),
                        ));
                  } else {
                    final profileGroupId = node.data as int;
                    final profileGroupTitle =
                        getProfileGroupTitle(_profileGroups[profileGroupId]!);
                    final profileGroupSubTitle = getProfileGroupSubTitle(
                        _profileGroups[profileGroupId]!);
                    return ListTile(
                      title: Text(profileGroupTitle),
                      subtitle: Text(profileGroupSubTitle),
                      // leading: node.isExpanded ? Icon(Icons.folder_open) : Icon(Icons.folder),
                      leading: const Icon(null),
                      trailing: PopupMenuButton<ProfileGroupAction>(
                        onSelected: (value) =>
                            handleProfileGroupAction(profileGroupId, value),
                        itemBuilder: (context) => ProfileGroupAction.values
                            .map((action) => PopupMenuItem(
                                  value: action,
                                  child: Text(action.name),
                                ))
                            .toList(),
                      ),
                    );
                  }
                },
              ),
            ])));
  }
}
