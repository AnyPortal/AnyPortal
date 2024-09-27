import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fv2ray/utils/data_watcher.dart';

import '../screens/home/settings/core.dart';
import '../utils/core_manager.dart';

// ignore: must_be_immutable
class RayToggle extends StatefulWidget {
  Function setHighlightSelectProfile;
  RayToggle({
    super.key,
    required this.setHighlightSelectProfile,
  });

  @override
  RayToggleState createState() => RayToggleState();
}

class RayToggleState extends State<RayToggle> {
  StreamSubscription<String>? _stdoutSubscription;
  bool on = false;
  Timer? timer;

  void syncDataWatcher() async {
    final coreOn = await coreMan.on();
    if (coreOn && !dataWatcher.on) {
      try {
        await coreMan.init();
        dataWatcher.loadCfg(coreMan.rawCfg);
        dataWatcher.start();
      } catch (e) {
        final snackBar = SnackBar(
          content: Text("syncDataWatcher: $e"),
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else if (!coreOn && dataWatcher.on) {
      dataWatcher.stop();
    }
    setState(() {
      on = coreOn;
    });
  }

  @override
  void initState() {
    super.initState();
    syncDataWatcher();
  }

  void _toggle() async {
    Exception? err;
    try {
      if (await coreMan.on()) {
        await coreMan.stop();
      } else {
        await coreMan.start();
      }
    } on NoCorePathException catch (_) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoreScreen()),
        );
        const snackBar = SnackBar(
          content: Text("Please specify v2ray-core executable path"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on NoSelectedProfileException catch (e) {
      err = e;
      widget.setHighlightSelectProfile();
    } on Exception catch (e) {
      err = e;
    } finally {
      if (err != null) {
        final snackBar = SnackBar(
          content: Text("toggle: $err"),
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    syncDataWatcher();
  }

  @override
  void dispose() {
    _stdoutSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: _toggle,
        tooltip: on ? 'disconnect' : 'connect',
        child: on ? const Icon(Icons.stop) : const Icon(Icons.play_arrow));
  }
}
