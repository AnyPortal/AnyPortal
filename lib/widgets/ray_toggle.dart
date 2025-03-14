import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/home/settings/cores.dart';
import '../utils/logger.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void _toggle() async {
    final isCoreActive = await vPNMan.getIsCoreActive();

    Exception? err;
    try {
      if (isCoreActive) {
        await vPNMan.stop();
      } else {
        await vPNMan.start();
      }
    } on ExceptionInvalidCorePath catch (e) {
      err = e;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoresScreen()),
        );
        const snackBar = SnackBar(
          content: Text("Please specify v2ray-core executable path"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on ExceptionNoSelectedProfile catch (e) {
      err = e;
      widget.setHighlightSelectProfile();
    } on Exception catch (e) {
      err = e;
      logger.w(e);
    } finally {
      if (err != null) {
        vPNMan.setIsToggling(false);
        final snackBar = SnackBar(
          content: Text("toggle: $err"),
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              onPressed: vPNMan.isToggling ? null : _toggle,
              tooltip: vPNMan.isCoreActive
                  ? 'disconnect'
                  : 'connect',
              child: vPNMan.isToggling
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
