import 'package:flutter/material.dart';

import 'package:drift/drift.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/utils/core/base/plugin.dart';

import '../../utils/db.dart';
import '../../utils/prefs.dart';
import '../../utils/show_snack_bar_now.dart';
import '../../widgets/ray_toggle.dart';
import '../../widgets/vpn_toggles.dart';



class Dashboard extends StatefulWidget {
  final Function setSelectedIndex;
  final bool isLandscapeLayout;
  const Dashboard({
    super.key,
    required this.setSelectedIndex,
    this.isLandscapeLayout = false,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<ProfileData> _profiles = [];
  String? _selectedProfileName =
      prefs.getString("cache.app.selectedProfileName");

  bool _highlightSelectProfile = false;
  final bool _useFloatingActionButton =
      prefs.getBool("app.dashboard.floatingActionButton")!;

  void setHighlightSelectProfile() async {
    for (var i = 0; i < 2; ++i) {
      if (mounted) {
        setState(() {
          _highlightSelectProfile = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }
  }

  Future<void> _loadSettings() async {
    final selectedProfileId = prefs.getInt('app.selectedProfileId');
    if (selectedProfileId != null) {
      final selectedProfile = await (db.select(db.profile)
            ..where((p) => p.id.equals(selectedProfileId)))
          .getSingleOrNull();
      if (mounted) {
        setState(() {
          _selectedProfileName = selectedProfile?.name;
        });
      }
    }
  }

  Future<void> _loadProfiles() async {
    final profiles = await (db.select(db.profile)
          ..orderBy([
            (u) => OrderingTerm(
                  expression: u.name,
                )
          ]))
        .get();
    if (mounted) {
      setState(() {
        _profiles = profiles;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.dashboard),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8.0),
        child: Wrap(children: [
          if (_useFloatingActionButton) Card(
              margin: const EdgeInsets.all(8.0),
              child: SmoothHighlight(
                  enabled: _highlightSelectProfile,
                  color: Colors.grey,
                  child: ListTile(
                    title: Text(
                      context.loc.selected_profile,
                    ),
                    subtitle: Text(_selectedProfileName == null
                        ? ""
                        : _selectedProfileName!),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                      _profiles.isNotEmpty
                          ? widget.setSelectedIndex(2)
                          : () {
                              if (mounted) {
                                showSnackBarNow(
                                    context,
                                    Text(context
                                        .loc.no_profile_yet_create_one_first));
                              }
                              widget.setSelectedIndex(2);
                            }();
                    },
                  ))),
          if (!widget.isLandscapeLayout && !_useFloatingActionButton)
            Card(
                margin: const EdgeInsets.all(8.0),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                  child: VPNToggles(),
                )),
          ...CorePluginManager().instance.dashboardWidgets.of(context),
          if (_useFloatingActionButton)
            Container(
              constraints: const BoxConstraints(
                minHeight: 72,
              ),
            )
        ]),
      ),
      floatingActionButton: prefs.getBool("app.dashboard.floatingActionButton")!
          ? RayToggle(
              setHighlightSelectProfile: setHighlightSelectProfile,
            )
          : null,
    );
  }
}
