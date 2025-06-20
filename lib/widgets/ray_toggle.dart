import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/logger.dart';
import '../utils/show_snack_bar_now.dart';
import '../utils/vpn_manager.dart';

class RayToggle extends StatefulWidget {
  final Function setHighlightSelectProfile;
  const RayToggle({
    super.key,
    required this.setHighlightSelectProfile,
  });

  @override
  RayToggleState createState() => RayToggleState();
}

class RayToggleState extends State<RayToggle> {
  StreamSubscription<String>? _stdoutSubscription;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  void _toggle() async {
    final isCoreActive = await vPNMan.getIsCoreActive();

    Exception? err;
    try {
      if (isCoreActive) {
        await vPNMan.stopAll();
      } else {
        await vPNMan.startAll();
      }
    } on Exception catch (e) {
      err = e;
      logger.w(e);
    } finally {
      if (err != null) {
        vPNMan.setisTogglingAll(false);
        if (mounted) showSnackBarNow(context, Text("toggle: $err"));
      }
    }
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
          return FloatingActionButton(
              onPressed: vPNMan.isTogglingAll ? null : _toggle,
              tooltip: vPNMan.isCoreActive ? 'disconnect' : 'connect',
              child: vPNMan.isTogglingAll
                  ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(),
                    )
                  : vPNMan.isCoreActive
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.play_arrow));
        });
  }
}
