import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:fv2ray/utils/data_watcher.dart';

import '../utils/config_injector.dart';
import '../utils/db.dart';
import '../utils/ray_core.dart';

class RayToggle extends StatefulWidget {
  const RayToggle({
    super.key,
  });

  @override
  RayToggleState createState() => RayToggleState();
}

class RayToggleState extends State<RayToggle> {
  StreamSubscription<String>? _stdoutSubscription;
  bool on = rayCore.on;
  Timer? timer;

  void _toggleRay() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedProfileId = prefs.getInt('selectedProfileId');
    if (selectedProfileId == null) {
      return;
    }
    final selectedProfile = await (db.select(db.profiles)
          ..where((p) => p.id.equals(selectedProfileId)))
        .getSingle();

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fv2ray', 'config.g.json'));

    final rawCfg = jsonDecode(selectedProfile.json) as Map<String, dynamic>;
    final cfg = await getInjectedConfig(rawCfg);
    await file.writeAsString(jsonEncode(cfg));

    if (rayCore.on) {
      dataWatcher.stop();
      rayCore.stopProcess();
    } else {
      String corePath = prefs.getString('corePath') ?? "";
      String assetPath = prefs.getString('assetPath') ?? "";
      String coreArgsTemplate =
          prefs.getString('coreArgsTemplate') ?? "run -c {config}";
      final String coreArgs =
          coreArgsTemplate.replaceAll("{config}", file.path);
      List<String> coreArgList = coreArgs.split(' ');
      // await rayCore.startProcess("ls", ["-la","/storage/emulated/0/opt/v2ray/geosite.dat"]);
      try {
        await rayCore.startProcess(corePath, coreArgList, environment: {
          "V2RAY_LOCATION_ASSET": assetPath,
          "XRAY_LOCATION_ASSET": assetPath,
        });
      } catch (e) {
        const snackBar = SnackBar(
          content: Text("Core start failed. Make sure settings are correct."),
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      dataWatcher.loadCfg(rawCfg);
      await dataWatcher.start();
    }

    setState(() {
      on = rayCore.on;
    });
  }

  @override
  void dispose() {
    _stdoutSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: _toggleRay,
        tooltip: on ? 'disconnect' : 'connect',
        child: on ? const Icon(Icons.stop) : const Icon(Icons.play_arrow));
  }
}
