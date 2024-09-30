import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:fv2ray/screens/home/dashboard/direct_speed.dart';
import 'package:fv2ray/screens/home/dashboard/proxy_speed.dart';
import 'package:fv2ray/screens/home/dashboard/speed_chart.dart';
import 'package:smooth_highlight/smooth_highlight.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/db.dart';
import '../../utils/prefs.dart';
import 'dashboard/perf_stats.dart';
import '../../widgets/ray_toggle.dart';
import 'dashboard/traffic_stats.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  Function setSelectedIndex;
  Dashboard({
    super.key,
    required this.setSelectedIndex,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<ProfileData> _profiles = [];
  ProfileData? _selectedProfile;

  bool _highlightSelectProfile = false;

  void setHighlightSelectProfile() async {
    for (var i = 0; i < 2; ++i) {
      if (context.mounted) {
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
      setState(() {
        _selectedProfile = selectedProfile;
      });
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
    setState(() {
      _profiles = profiles;
    });
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
          title: Text(AppLocalizations.of(context)!.dashboard),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(8.0),
          child: Wrap(children: [
            Card(
                margin: const EdgeInsets.all(8.0),
                child: SmoothHighlight(
                    enabled: _highlightSelectProfile,
                    color: Colors.grey,
                    child: ListTile(
                      title: const Text(
                        'Selected Profile',
                      ),
                      subtitle: Text(_selectedProfile == null
                          ? ""
                          : _selectedProfile!.name),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        _profiles.isNotEmpty
                            ? widget.setSelectedIndex(2)
                            : () {
                                const snackBar = SnackBar(
                                  content:
                                      Text("No profile yet, create one first"),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                                widget.setSelectedIndex(2);
                              }();
                      },
                    ))),
            Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Speed graph',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: const SpeedChart(),
                )),
            Row(children: [
              Expanded(
                  child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Stack(children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      )),
                  ListTile(
                    title: Row(children: [
                      Text(
                        'Direct speed',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ]),
                    subtitle: const DirectSpeeds(),
                  )
                ]),
              )),
              Expanded(
                  child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Stack(children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      )),
                  ListTile(
                    title: Text(
                      'Proxy speed',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: const ProxySpeeds(),
                  )
                ]),
              )),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        'Performance',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: const PerfStats(),
                    )),
              ),
              const Expanded(
                child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Traffic'),
                      subtitle: TrafficStats(),
                    )),
              ),
            ]),
            Container(
              constraints: const BoxConstraints(
                minHeight: 72,
              ),
            )
          ]),
        ),
        floatingActionButton: RayToggle(
          setHighlightSelectProfile: setHighlightSelectProfile,
        ));
  }
}
