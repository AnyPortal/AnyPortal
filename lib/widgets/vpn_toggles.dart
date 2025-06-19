import 'package:flutter/material.dart';

import '../extensions/localization.dart';
import '../screens/home/profiles.dart';
import '../screens/home/settings/cores.dart';
import '../utils/global.dart';
import '../utils/logger.dart';
import '../utils/platform_system_proxy_user.dart';
import '../utils/prefs.dart';
import '../utils/runtime_platform.dart';
import '../utils/show_snack_bar_now.dart';
import '../utils/vpn_manager.dart';

class VPNToggles extends StatefulWidget {
  final bool isDense;
  const VPNToggles({
    super.key,
    this.isDense = false,
  });

  @override
  VPNTogglesState createState() => VPNTogglesState();
}

class VPNTogglesState extends State<VPNToggles> {
  @override
  void initState() {
    super.initState();
    _loadSystemProxyIsEnabled();
  }

  void handleError(Object e) {
    logger.e("tun: $e");
    if (mounted) showSnackBarNow(context, Text("tun: $e"));
  }

  void toggleAll(bool shouldEnable) async {
    Exception? err;
    try {
      if (!shouldEnable) {
        await vPNMan.stopAll();
      } else {
        await vPNMan.startAll();
      }
    } on ExceptionInvalidCorePath catch (e) {
      err = e;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoresScreen()),
        );
        if (mounted) {
          showSnackBarNow(
              context, Text("Please specify v2ray-core executable path"));
        }
      }
    } on ExceptionNoSelectedProfile catch (e) {
      err = e;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileList()),
        );
        if (mounted) showSnackBarNow(context, Text("Please select a profile"));
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

  void toggleSystemProxy(bool shouldEnable) {
    setState(() {
      systemProxy = shouldEnable;
    });
    prefs.setBool('systemProxy', shouldEnable);
    vPNMan.getIsCoreActive().then((isCoreActive) {
      if (isCoreActive) {
        if (shouldEnable) {
          vPNMan.startSystemProxy();
        } else {
          vPNMan.stopSystemProxy();
        }
      }
    });
  }

  void toggleTun(bool shouldEnable) async {
    if (!prefs.getBool('tun.useEmbedded')! && !global.isElevated) {
      if (mounted) {
        showSnackBarNow(
          context,
          Text(context.loc
              .warning_you_need_to_be_elevated_user_to_modify_this_setting(
                  RuntimePlatform.isWindows
                      ? context.loc.administrator
                      : "root")),
        );
      }
      return;
    }
    setState(() {
      tun = shouldEnable;
    });
    prefs.setBool('tun', shouldEnable);
    vPNMan.getIsCoreActive().then((isCoreActive) {
      if (isCoreActive) {
        if (shouldEnable) {
          vPNMan.startTun().catchError(handleError);
        } else {
          vPNMan.stopTun().catchError(handleError);
        }
      }
    });
  }

  bool? _systemProxyIsEnabled = prefs.getBool('cache.systemProxy');
  bool tun = prefs.getBool('tun')!;
  bool systemProxy = prefs.getBool('systemProxy')!;

  Future<void> _loadSystemProxyIsEnabled() async {
    platformSystemProxyUser.isEnabled().then((value) {
      setState(() {
        _systemProxyIsEnabled = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double switchScale = widget.isDense ? 0.5 : 1;
    return Column(
      children: [
        ListTile(
          dense: widget.isDense,
          title: Text(context.loc.core),
          trailing: Transform.scale(
              scale: switchScale,
              origin: const Offset(32, 0),
              child: ListenableBuilder(
                  listenable: vPNMan,
                  builder: (BuildContext context, Widget? child) {
                    return Switch(
                      value: vPNMan.isCoreActive,
                      onChanged: vPNMan.isTogglingAll ? null : toggleAll,
                    );
                  })),
        ),
        if (RuntimePlatform.isWindows ||
            RuntimePlatform.isLinux ||
            RuntimePlatform.isMacOS ||
            (RuntimePlatform.isAndroid && global.isElevated))
          ListTile(
              dense: widget.isDense,
              title: Text(context.loc.system_proxy),
              trailing: Transform.scale(
                scale: switchScale,
                origin: const Offset(32, 0),
                child: ListenableBuilder(
                    listenable: Listenable.merge([vPNMan, prefs]),
                    builder: (BuildContext context, Widget? child) {
                      final shouldOn = prefs.getBool('systemProxy')!;
                      final isOn = vPNMan.isSystemProxyActive;
                      return Switch(
                        value: shouldOn,
                        onChanged: _systemProxyIsEnabled == null ||
                                vPNMan.isTogglingSystemProxy
                            ? null
                            : toggleSystemProxy,
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                            (Set<WidgetState> states) {
                          return !vPNMan.isTogglingSystemProxy &&
                                  shouldOn &&
                                  !isOn
                              ? Icon(Icons.priority_high)
                              : null;
                        }),
                      );
                    }),
              )),
        ListTile(
          dense: widget.isDense,
          title: Text("Tun"),
          trailing: Transform.scale(
              scale: switchScale,
              origin: const Offset(32, 0),
              child: ListenableBuilder(
                  listenable: Listenable.merge([vPNMan, prefs]),
                  builder: (BuildContext context, Widget? child) {
                    final shouldOn = prefs.getBool('tun')!;
                    final isOn = vPNMan.isTunActive;
                    return Switch(
                      value: tun,
                      onChanged: vPNMan.isTogglingTun ? null : toggleTun,
                      thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                          (Set<WidgetState> states) {
                        return !vPNMan.isTogglingTun && shouldOn && !isOn
                            ? Icon(Icons.priority_high)
                            : null;
                      }),
                    );
                  })),
        ),
      ],
    );
  }
}
