import 'package:flutter/material.dart';

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/utils/global.dart';
import 'package:anyportal/utils/vpn_manager.dart';
import '../screens/home/settings/cores.dart';
import '../screens/home/profiles.dart';
import '../utils/logger.dart';
import '../utils/platform_system_proxy_user.dart';
import '../utils/prefs.dart';
import '../utils/platform.dart';

class VPNToggles extends StatefulWidget {
  const VPNToggles({
    super.key,
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
    final snackBar = SnackBar(
      content: Text("$e"),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void toggleCore(bool shouldEnable) async {
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
        const snackBar = SnackBar(
          content: Text("Please specify v2ray-core executable path"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on ExceptionNoSelectedProfile catch (e) {
      err = e;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileList()),
        );
        const snackBar = SnackBar(
          content: Text("Please select a profile"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on Exception catch (e) {
      err = e;
      logger.w(e);
    } finally {
      if (err != null) {
        vPNMan.setisTogglingAll(false);
        final snackBar = SnackBar(
          content: Text("toggle: $err"),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
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
    if (!global.isElevated) {
      final snackBar = SnackBar(
        content: Text(context.loc
            .warning_you_need_to_be_elevated_user_to_modify_this_setting(
                platform.isWindows ? context.loc.administrator : "root")),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  bool? _systemProxyIsEnabled;
  bool tun = prefs.getBool('tun')!;
  bool systemProxy = prefs.getBool('systemProxy')!;

  Future<void> _loadSystemProxyIsEnabled() async {
    _systemProxyIsEnabled = await platformSystemProxyUser.isEnabled();
    setState(() {
      _systemProxyIsEnabled = _systemProxyIsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: ListenableBuilder(
              listenable: vPNMan,
              builder: (BuildContext context, Widget? child) {
                List<Widget> status = [];
                if (vPNMan.isTogglingAll) {
                  status = [
                    Text(" "),
                    SizedBox(
                      height: 16.0,
                      width: 16.0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ];
                }
                return Row(children: [
                  Text(context.loc.core),
                  ...status,
                ]);
              }),
          trailing: Transform.scale(
              scale: 0.5,
              origin: const Offset(32, 0),
              child: ListenableBuilder(
                  listenable: vPNMan,
                  builder: (BuildContext context, Widget? child) {
                    return Switch(
                      value: vPNMan.isCoreActive,
                      onChanged: (shouldEnable) {
                        vPNMan.isTogglingAll ? null : toggleCore(shouldEnable);
                      },
                    );
                  })),
        ),
        if (platform.isWindows ||
            platform.isLinux ||
            platform.isMacOS ||
            platform.isAndroid)
          ListTile(
              dense: true,
              title: ListenableBuilder(
                  listenable: Listenable.merge([vPNMan, prefs]),
                  builder: (BuildContext context, Widget? child) {
                    final shouldOn = prefs.getBool('systemProxy')!;
                    final isOn = vPNMan.isSystemProxyActive;
                    List<Widget> status = [];
                    if (vPNMan.isTogglingSystemProxy) {
                      status = [
                        Text(" "),
                        SizedBox(
                          height: 16.0,
                          width: 16.0,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ];
                    }
                    if (!vPNMan.isTogglingSystemProxy && !isOn && shouldOn) {
                      status = [
                        Text(" (!)"),
                      ];
                    }
                    return Row(children: [
                      Text(context.loc.system_proxy),
                      ...status,
                    ]);
                  }),
              trailing: Transform.scale(
                scale: 0.5,
                origin: const Offset(32, 0),
                child: ListenableBuilder(
                    listenable: prefs,
                    builder: (BuildContext context, Widget? child) {
                      return Switch(
                        value: _systemProxyIsEnabled == null
                            ? false
                            : prefs.getBool("systemProxy")!,
                        onChanged: (bool shouldEnable) {
                          vPNMan.isTogglingSystemProxy
                              ? null
                              : toggleSystemProxy(shouldEnable);
                        },
                      );
                    }),
              )),
        ListTile(
          dense: true,
          title: ListenableBuilder(
              listenable: Listenable.merge([vPNMan, prefs]),
              builder: (BuildContext context, Widget? child) {
                final shouldOn = prefs.getBool('tun')!;
                final isOn = vPNMan.isTunActive;
                List<Widget> status = [];
                if (vPNMan.isTogglingTun) {
                  status = [
                    Text(" "),
                    SizedBox(
                      height: 16.0,
                      width: 16.0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ];
                }
                if (!vPNMan.isTogglingTun && !isOn && shouldOn) {
                  status = [
                    Text(" (!)"),
                  ];
                }
                return Row(children: [
                  Text("Tun"),
                  ...status,
                ]);
              }),
          trailing: Transform.scale(
              scale: 0.5,
              origin: const Offset(32, 0),
              child: ListenableBuilder(
                  listenable: prefs,
                  builder: (BuildContext context, Widget? child) {
                    bool tun = prefs.getBool('tun')!;
                    return Switch(
                      value: tun,
                      onChanged: (shouldEnable) {
                        vPNMan.isTogglingTun ? null : toggleTun(shouldEnable);
                      },
                    );
                  })),
        ),
      ],
    );
  }
}
