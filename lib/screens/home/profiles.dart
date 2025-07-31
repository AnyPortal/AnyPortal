import 'package:flutter/material.dart';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:drift/drift.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import '../../extensions/localization.dart';
import '../../models/profile_group.dart';
import '../../screens/profile_group.dart';
import '../../utils/db.dart';
import '../../utils/prefs.dart';
import '../../utils/show_snack_bar_now.dart';
import '../../utils/vpn_manager.dart';
import '../profile.dart';

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

extension ProfilesActionX on ProfilesAction {
  String localized(BuildContext context) {
    switch (this) {
      case ProfilesAction.addProfile:
        return context.loc.add_profile;
      case ProfilesAction.addProfileGroup:
        return context.loc.add_profile_group;
    }
  }
}

enum ProfileAction {
  edit,
  delete,
}

extension ProfileActionX on ProfileAction {
  String localized(BuildContext context) {
    switch (this) {
      case ProfileAction.edit:
        return context.loc.edit;
      case ProfileAction.delete:
        return context.loc.delete;
    }
  }
}

enum ProfileGroupAction {
  addProfile,
  edit,
  delete,
}

extension ProfileGroupActionX on ProfileGroupAction {
  String localized(BuildContext context) {
    switch (this) {
      case ProfileGroupAction.addProfile:
        return context.loc.add_profile;
      case ProfileGroupAction.edit:
        return context.loc.edit;
      case ProfileGroupAction.delete:
        return context.loc.delete;
    }
  }
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

  void handleProfilesAction(ProfilesAction action) {
    switch (action) {
      case ProfilesAction.addProfile:
        _addProfile();
      case ProfilesAction.addProfileGroup:
        _addProfileGroup();
    }
  }

  void _addProfile({int? profileGroupId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileScreen(profileGroupId: profileGroupId)),
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
          key: "profileGroupId-$profileGroupId",
        )..addAll(profiles.map((profile) {
            return TreeNode(data: profile, key: "profileId-${profile.id}");
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
      case ProfileGroupAction.addProfile:
        _addProfile(profileGroupId: profileGroupId);
      case ProfileGroupAction.delete:
        await db.transaction(() async {
          await (db.delete(db.profile)
                ..where((e) => e.profileGroupId.equals(profileGroupId)))
              .go();
          // do not delete the default local group
          if (profileGroupId != 1) {
            await (db.delete(db.profileGroup)
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
      return context.loc.standalone;
    }
    return profileGroup.name;
  }

  String getProfileGroupSubTitle(ProfileGroupData profileGroup) {
    if (profileGroup.id == 1) {
      return context.loc.manually_created_profiles;
    }
    if (profileGroup.type == ProfileGroupType.local) {
      return context.loc.local_profile_group;
    }
    return "${profileGroup.updatedAt}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.loc.profiles),
          actions: [
            SmoothHighlight(
              enabled: _highlightProfilesPopupMenuButton,
              color: Colors.grey,
              child: PopupMenuButton(
                itemBuilder: (context) => ProfilesAction.values
                    .map((action) => PopupMenuItem(
                          value: action,
                          child: Text(action.localized(context)),
                        ))
                    .toList(),
                onSelected: (value) => handleProfilesAction(value),
              ),
            ),
          ],
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
                        onChanged: (value) async {
                          prefs.setInt('app.selectedProfileId', value!);
                          prefs.setString(
                              'cache.app.selectedProfileName', profile.name);
                          prefs.notifyListeners();
                          setState(() {
                            _selectedProfileId = value;
                          });
                          if (await vPNMan.getIsCoreActive()) {
                            if (context.mounted) {
                              showSnackBarNow(
                                  context, Text(context.loc.reconnecting));
                            }

                            final res = await vPNMan.restartCore();

                            String msg = "";
                            if (context.mounted) {
                              if (res) {
                                msg = context.loc.info_reconnected;
                              } else {
                                msg = context.loc.warning_failed_to_reconnect;
                              }
                              showSnackBarNow(context, Text(msg));
                            }
                          }
                        },
                        title: Text(profile.name.toString()),
                        subtitle: Text('${profile.updatedAt}'),
                        dense: true,
                        secondary: PopupMenuButton<ProfileAction>(
                          onSelected: (value) =>
                              handleProfileAction(profile, value),
                          itemBuilder: (context) => ProfileAction.values
                              .map((action) => PopupMenuItem(
                                    value: action,
                                    child: Text(action.localized(context)),
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
                                  child: Text(action.localized(context)),
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
