import 'dart:async';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fv2ray/utils/core_data_notifier.dart';

import '../screens/home/settings/core.dart';
import '../utils/vpn_manager.dart';

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
  Timer? timer;

  Future<void> syncCoreDataNotifier() async {
    final coreIsActive = (await vPNMan.updateIsActiveRecord()).isActive;
    if (coreIsActive && !coreDataNotifier.on) {
      try {
        await vPNMan.init();
        coreDataNotifier.loadCfg(vPNMan.rawCfg);
        // should do atomic check
        if (!coreDataNotifier.on) coreDataNotifier.start();
      } catch (e) {
        final snackBar = SnackBar(
          content: Text("syncCoreDataNotifier: $e"),
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else if (!coreIsActive && coreDataNotifier.on) {
      // should do atomic check
      coreDataNotifier.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    syncCoreDataNotifier();
  }

  void _toggle() async {
    final isActive = (await vPNMan.updateIsActiveRecord()).isActive;

    Exception? err;
    try {
      if (isActive) {
        await vPNMan.stop();
      } else {
        await vPNMan.start();
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

    syncCoreDataNotifier();
  }

  @override
  void dispose() {
    _stdoutSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: vPNMan,
        builder: (BuildContext context, Widget? child) {
          syncCoreDataNotifier();
          // log("vPNMan: ${vPNMan.isActiveRecord.datetime} ${vPNMan.isActiveRecord.isActive} ${vPNMan.isActiveRecord.source}");
          // log("isToggling: ${vPNMan.isToggling}");
          return FloatingActionButton(
              onPressed: vPNMan.isToggling ? null : _toggle,
              tooltip:
                  vPNMan.isActiveRecord.isActive ? 'disconnect' : 'connect',
              child: vPNMan.isToggling
                  ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(),
                    )
                  : vPNMan.isActiveRecord.isActive
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.play_arrow));
        });
  }
}
