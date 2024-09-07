import 'package:flutter/material.dart';
import 'package:fv2ray/widgets/direct_speed.dart';
import 'package:fv2ray/widgets/proxy_speed.dart';
import 'package:fv2ray/widgets/speed_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/db.dart';
import '../../widgets/perf_stats.dart';
import '../../widgets/ray_toggle.dart';
import '../../widgets/traffic_stats.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Profile> _profiles = [];

  late SharedPreferences _prefs;
  Profile? _selectedProfile;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final selectedProfileId = _prefs.getInt('selectedProfileId');
    if (selectedProfileId != null) {
      final selectedProfile = await (db.select(db.profiles)
            ..where((p) => p.id.equals(selectedProfileId)))
          .getSingle();
      setState(() {
        _selectedProfile = selectedProfile;
      });
    }
  }

  Future<void> _loadProfiles() async {
    final profiles = await db.select(db.profiles).get();
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(8.0),
          child: Wrap(children: [
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
              Expanded(
                child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        'Traffic',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: const TrafficStats(),
                    )),
              ),
            ]),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'Profiles',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Wrap(
                  children: _profiles.map((profile) {
                    return RadioListTile<int>(
                      title: Text(profile.name.toString()),
                      value: profile.id,
                      groupValue:
                          _selectedProfile == null ? -1 : _selectedProfile!.id,
                      onChanged: (int? profileId) {
                        _prefs.setInt('selectedProfileId', profileId!);
                        setState(() {
                          _selectedProfile = profile;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ]),
        ),
        floatingActionButton: const RayToggle());
  }
}
