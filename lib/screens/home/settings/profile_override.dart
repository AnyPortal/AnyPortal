import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/log_level.dart';

class ProfileOverrideScreen extends StatefulWidget {
  const ProfileOverrideScreen({
    super.key,
  });

  @override
  State<ProfileOverrideScreen> createState() => _ProfileOverrideScreenState();
}

class _ProfileOverrideScreenState extends State<ProfileOverrideScreen> {
  bool _injectApi = true;
  int _apiPort = 15490;
  bool _injectLog = true;
  LogLevel _logLevel = LogLevel.warning;
  late SharedPreferences _prefs;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _injectApi = _prefs.getBool('injectApi') ?? _injectApi;
      _apiPort = _prefs.getInt('apiPort') ?? _apiPort;
      _injectLog = _prefs.getBool('injectLog') ?? _injectLog;
      _logLevel =
          LogLevel.values[_prefs.getInt('logLevel') ?? LogLevel.warning.index];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _updateApiPort(String value) {
    int apiPort = 15490;
    try {
      apiPort = int.parse(value);
      // ignore: empty_catches
    } catch (e) {}
    _prefs.setInt('apiPort', apiPort);
  }

  void _updateInjectLog(bool value) {
    _prefs.setBool('injectLog', value);
    setState(() {
      _injectLog = value;
    });
  }

  void _updateInjectApi(bool value) {
    _prefs.setBool('injectApi', value);
    setState(() {
      _injectApi = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      Card(
        child: ListTile(
          title: const Text("Api config override"),
          subtitle: TextField(
            controller: TextEditingController()..text = _apiPort.toString(),
            onChanged: _updateApiPort,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
            ),
          ),
          trailing: Switch(
            value: _injectApi,
            onChanged: _updateInjectApi,
          ),
          isThreeLine: true,
        ),
      ),
      Card(
        child: ListTile(
          title: const Text("Log config override"),
          subtitle: DropdownButtonFormField<LogLevel>(
            decoration: const InputDecoration(
              labelText: 'type',
            ),
            items: LogLevel.values.map((LogLevel t) {
              return DropdownMenuItem<LogLevel>(value: t, child: Text(t.name));
            }).toList(),
            onChanged: (value) {
              _prefs.setInt('logLevel', value!.index);
            },
            value: _logLevel,
          ),
          trailing: Switch(
            value: _injectLog,
            onChanged: _updateInjectLog,
          ),
          isThreeLine: true,
        ),
      ),
      
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Profile override"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
