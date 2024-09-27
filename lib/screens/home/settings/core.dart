import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

// import '../../../utils/method_channel/add_exec_permission.dart';
// import '../../../utils/file_unlocker.dart';
import '../../../utils/prefs.dart';
import '../../../widgets/popup/text_input.dart';

class CoreScreen extends StatefulWidget {
  const CoreScreen({
    super.key,
  });

  @override
  State<CoreScreen> createState() => _CoreScreenState();
}

class _CoreScreenState extends State<CoreScreen> {
  bool _useEmbeddedCore = prefs.getBool('core.useEmbedded')!;
  String _corePath = prefs.getString('core.path') ?? "";
  String _assetPath = prefs.getString('core.assetPath') ?? "";

  Future<void> _selectCorePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    String corePath = result.files.single.path!;
    if (Platform.isAndroid) {
      final folder = await getApplicationDocumentsDirectory();
      final dest = File(p.join(folder.path, 'fv2ray', 'core')).path;
      await File(corePath).rename(dest);
      await FilePicker.platform.clearTemporaryFiles();
      corePath = dest;
    }
    if (Platform.isAndroid) {
      await Process.start("chmod", ["a+x", corePath]);
      // await FilePermission.addExecutablePermission(corePath);
    }
    prefs.setString('core.path', corePath);
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

        //   // I noticed that sometimes popup won't show after user press deny
        //   // so I do the check once again but now go straight to appSettings
        //   if (permissionStatus.isDenied) {
        //     await openAppSettings();
        //   }
        // } else if (permissionStatus.isPermanentlyDenied) {
        //   // Here open app settings for user to manually enable permission in case
        //   // where permission was permanently denied
        //   await openAppSettings();
      }
    }
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    String assetPath;
    if (selectedDirectory != null) {
      assetPath = selectedDirectory;
    } else {
      return;
    }
    prefs.setString('core.assetPath', assetPath);
    setState(() {
      _assetPath = assetPath;
    });
  }

  // Future<void> _selectAssets() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
  //   if (result == null) {
  //     return;
  //   }
  //   List<File> files = result.paths.map((path) => File(path!)).toList();
  //   if (Platform.isAndroid) {
  //     final folder = await getApplicationDocumentsDirectory();
  //     for (var file in files){
  //       final dest = File(p.join(folder.path, 'fv2ray', 'asset', basename(file.path))).path;
  //       await file.rename(dest);
  //     }
  //     await FilePicker.platform.clearTemporaryFiles();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final fields = [
      if (Platform.isAndroid) Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Only embedded cores are supported on Play Store releases due to API 29+ policies",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      if (Platform.isIOS) Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Only embedded cores are supported on iOS",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      if (Platform.isAndroid || Platform.isIOS) ListTile(
        title: const Text("Use embedded core"),
        subtitle: const Text("xray-core v1.8.24"), // todo: auto version
        trailing: Switch(
          value: _useEmbeddedCore,
          onChanged: (bool value) {
            prefs.setBool('core.useEmbedded', value);
            setState(() {
              _useEmbeddedCore = value;
            });
          },
        ),
      ),
      // if (Platform.isAndroid) Container(
      //   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      //   child: Text(
      //     "Custom assets are copied to internal storage on selection due to android policies, so you need to redo this on assets upgrading, then restart the app",
      //     style: TextStyle(color: Theme.of(context).colorScheme.primary),
      //   ),
      // ),
      // if (Platform.isAndroid) ListTile(
      //   title: const Text('Assets'),
      //   subtitle: Text(_assetPath),
      //   trailing: IconButton(
      //     icon: const Icon(Icons.open_in_new),
      //     onPressed: _selectAssets,
      //   ),
      //   onTap: _selectAssets
      // ),
      // // todo: reset assets
      const Divider(),
      if (Platform.isAndroid) Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Custom cores supported only on non Play Store releases",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      if (Platform.isAndroid) Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Custom cores are copied to internal storage on selection due to android policies, so you need to redo this on core upgrading, then restart the app",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        enabled: (Platform.isAndroid? !_useEmbeddedCore: true),
        title: const Text('Core path'),
        subtitle: Text(_corePath),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: _selectCorePath,
        ),
        onTap: () {
          Platform.isAndroid
              ? _selectCorePath()
              : showDialog(
                  context: context,
                  builder: (context) => TextInputPopup(
                      title: 'Core path',
                      initialValue: _corePath,
                      decoration: const InputDecoration(
                        hintText: '/path/to/v2ray_excutable',
                      ),
                      onSaved: (value) {
                        prefs.setString('core.path', value);
                        setState(() {
                          _corePath = value;
                        });
                      }),
                );
        },
      ),
      if (Platform.isAndroid) Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Custom asset path supported only on non Play Store releases. This takes priority than custom Assets, if not empty",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text('Asset path'),
        subtitle: Text(_assetPath),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: _selectAssetPath,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Asset path',
                initialValue: _assetPath,
                decoration: const InputDecoration(
                  hintText: '/path/to/v2ray_asset',
                ),
                onSaved: (value) {
                  prefs.setString('core.assetPath', value);
                  setState(() {
                    _assetPath = value;
                  });
                }),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Core settings"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
        // separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
