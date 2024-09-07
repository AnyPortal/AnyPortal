import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

import 'profile_override.dart';
// import 'package:permission_handler/permission_handler.dart';

class SettingList extends StatefulWidget {
  const SettingList({
    super.key,
  });

  @override
  State<SettingList> createState() => _SettingListState();
}

class _SettingListState extends State<SettingList> {
  String _corePath = "";
  String _coreArgs = "";
  String _assetPath = "";
  late SharedPreferences _prefs;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _corePath = _prefs.getString('corePath') ?? _corePath;
      _coreArgs = _prefs.getString('coreArgs') ?? _coreArgs;
      _assetPath = _prefs.getString('assetPath') ?? _assetPath;

      _injectApi = _prefs.getBool('injectApi') ?? _injectApi;
      _enableTun = _prefs.getBool('enableTun') ?? _enableTun;
      _apiPort = _prefs.getInt('apiPort') ?? _apiPort;
    });
  }

  Future<void> _selectCorePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String corePath;
    if (result != null) {
      corePath = result.files.single.path!;
    } else {
      return;
    }
    _prefs.setString('corePath', corePath);
    setState(() {
      _corePath = corePath;
    });
  }

  Future<void> _selectAssetPath() async {
    if (Platform.isAndroid) {
      final permissionStatus = await Permission.storage.status;
      if (permissionStatus.isDenied) {
        // Here just ask for the permission for the first time
        await Permission.storage.request();

        // I noticed that sometimes popup won't show after user press deny
        // so I do the check once again but now go straight to appSettings
        if (permissionStatus.isDenied) {
          await openAppSettings();
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        // Here open app settings for user to manually enable permission in case
        // where permission was permanently denied
        await openAppSettings();
      }
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    String assetPath;
    if (selectedDirectory != null) {
      assetPath = selectedDirectory;
    } else {
      return;
    }
    _prefs.setString('assetPath', assetPath);
    setState(() {
      _assetPath = assetPath;
    });
  }

  void _updateCorePath(String corePath) async {
    _prefs.setString('corePath', corePath);
  }

  void _updateCoreArgs(String coreArgs) async {
    _prefs.setString('coreArgs', coreArgs);
  }

  void _updateAssetPath(String assetPath) async {
    _prefs.setString('assetPath', assetPath);
  }

  void _editProfileOverride() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileOverrideScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  bool _injectApi = true;
  bool _enableTun = true;
  int _apiPort = 15490;

  void _updateApiPort(String value) {
    int apiPort = 15490;
    try {
      apiPort = int.parse(value);
      // ignore: empty_catches
    } catch (e) {}
    _prefs.setInt('apiPort', apiPort);
  }

  void _updateInjectApi(bool value) {
    _prefs.setBool('injectApi', value);
    setState(() {
      _injectApi = value;
    });
  }

  void _updateEnableTun(bool value) {
    _prefs.setBool('enableTun', value);
    setState(() {
      _enableTun = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8.0),
        child: Wrap(children: [
          Card(
            child: ListTile(
              title: const Text("Core path"),
              subtitle: TextField(
                decoration: const InputDecoration(
                  hintText: '/path/to/v2ray_excutable',
                ),
                onChanged: _updateCorePath,
                controller: TextEditingController()..text = _corePath,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectCorePath,
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Core args"),
              subtitle: TextField(
                decoration: const InputDecoration(
                  hintText: 'run -c {config}',
                ),
                onChanged: _updateCoreArgs,
                controller: TextEditingController()..text = _coreArgs,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Asset path"),
              subtitle: TextField(
                decoration: const InputDecoration(
                  hintText: '/path/to/v2ray_asset',
                ),
                onChanged: _updateAssetPath,
                controller: TextEditingController()..text = _assetPath,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectAssetPath,
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Profile override"),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Inject configuration into json."),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: _editProfileOverride,
                          child: const Text("Configure")),
                    )
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
