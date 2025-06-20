import 'package:flutter/material.dart';

import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import '../../../extensions/localization.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../utils/global.dart';
import '../../../utils/locale_manager.dart';
import '../../../utils/platform_launch_at_login.dart';
import '../../../utils/prefs.dart';
import '../../../utils/runtime_platform.dart';
import '../../../utils/show_snack_bar_now.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/vpn_manager.dart';
import '../../../widgets/popup/radio_list_selection.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({
    super.key,
  });

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  bool _autoUpdate = prefs.getBool('app.autoUpdate')!;
  bool _launchAtLogin = false;
  bool _connectAtStartup = prefs.getBool('app.connectAtStartup')!;
  bool _connectAtLaunch = prefs.getBool('app.connectAtLaunch')!;
  bool _runElevated = prefs.getBool('app.runElevated')!;

  bool _brightnessIsDark = prefs.getBool('app.brightness.dark')!;
  bool _isBlackDark = prefs.getBool('app.brightness.dark.black')!;
  bool _brightnessFollowSystem = prefs.getBool('app.brightness.followSystem')!;
  bool _closeToTray = prefs.getBool('app.window.closeToTray')!;
  bool _notificationForeground = prefs.getBool('app.notification.foreground')!;
  late Locale _locale = localeManager.locale;
  bool _localeFollowSystem = prefs.getBool('app.locale.followSystem')!;
  bool _isFloatingActionButton =
      prefs.getBool('app.dashboard.floatingActionButton')!;

  @override
  void initState() {
    super.initState();
    _loadLaunchAtLogin();
  }

  void _loadLaunchAtLogin() {
    if (RuntimePlatform.isWindows ||
        RuntimePlatform.isLinux ||
        RuntimePlatform.isMacOS) {
      platformLaunchAtLogin.isEnabled().then((value) {
        setState(() {
          _launchAtLogin = value;
        });
      });
    }
  }

  String getLanguageName(String localeCode) {
    // return LocaleNames.of(context)?.nameOf(localeCode) ?? localeCode;
    return LocaleNamesLocalizationsDelegate.nativeLocaleNames[localeCode] ??
        localeCode;
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.language_settings,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.follow_system_locale),
        subtitle:
            Text(context.loc.auto_change_language_based_on_system_settings),
        trailing: Switch(
          value: _localeFollowSystem,
          onChanged: (value) async {
            prefs.setBool('app.locale.followSystem', value);
            setState(() {
              _localeFollowSystem = value;
            });
            localeManager.update(notify: true);
            setState(() {
              _locale = localeManager.locale;
            });
          },
        ),
      ),
      ListTile(
        title: Text(context.loc.language),
        subtitle: Text(getLanguageName(_locale.toString())),
        enabled: !_localeFollowSystem,
        onTap: () {
          final supportedLocales = AppLocalizations.supportedLocales.toList();
          supportedLocales.remove(Locale('zh'));
          showDialog(
              context: context,
              builder: (context) => RadioListSelectionPopup<Locale>(
                    title: context.loc.language,
                    items: supportedLocales,
                    initialValue: _locale,
                    onSaved: (value) {
                      prefs.setString('app.locale', value.toString());
                      localeManager.update(notify: true);
                      setState(() {
                        _locale = value;
                      });
                    },
                    itemToString: (e) => getLanguageName(e.toString()),
                  ));
        },
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.launch_settings,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.auto_update),
        subtitle: Text(
            context.loc.auto_download_installer_and_update_on_next_app_launch),
        trailing: Switch(
          value: _autoUpdate,
          onChanged: (value) async {
            prefs.setBool('app.autoUpdate', value);
            setState(() {
              _autoUpdate = value;
            });
          },
        ),
      ),
      if (RuntimePlatform.isWindows ||
          (!global.isElevated &&
              (RuntimePlatform.isLinux || RuntimePlatform.isMacOS)))
        ListTile(
          title: Text(context.loc.auto_launch),
          subtitle: Text(context.loc.auto_launch_at_login),
          trailing: Switch(
            value: _launchAtLogin,
            onChanged: (value) async {
              bool ok = false;
              if (value) {
                ok = await platformLaunchAtLogin.enable(
                    isElevated: _runElevated);
              } else {
                ok = await platformLaunchAtLogin.disable();
              }
              if (ok) {
                setState(() {
                  _launchAtLogin = value;
                });
              } else {
                if (context.mounted) {
                  showSnackBarNow(
                    context,
                    Text(
                      context.loc
                          .warning_you_need_to_be_elevated_user_to_modify_this_setting(
                              RuntimePlatform.isWindows
                                  ? context.loc.administrator
                                  : "root"),
                    ),
                  );
                }
              }
            },
          ),
        ),
      if (RuntimePlatform.isWindows)
        ListTile(
          enabled: global.isElevated,
          title: Text(context.loc.run_as_elevated_user(
              RuntimePlatform.isWindows ? context.loc.administrator : "root")),
          subtitle: Text(context.loc.typically_required_by_tun),
          trailing: Switch(
            value: _runElevated,
            onChanged: (value) async {
              if (!global.isElevated) {
                if (context.mounted) {
                  showSnackBarNow(
                    context,
                    Text(
                      context.loc
                          .warning_you_need_to_be_elevated_user_to_modify_this_setting(
                              RuntimePlatform.isWindows
                                  ? context.loc.administrator
                                  : "root"),
                    ),
                  );
                }
                return;
              }
              if (_launchAtLogin) {
                bool ok = false;
                await platformLaunchAtLogin.disable();
                ok = await platformLaunchAtLogin.enable(isElevated: value);
                if (!ok) {
                  if (context.mounted) {
                    showSnackBarNow(
                      context,
                      Text(
                        context.loc
                            .warning_you_need_to_be_elevated_user_to_modify_this_setting(
                                RuntimePlatform.isWindows
                                    ? context.loc
                                        .warning_failed_due_to_unable_to_update_launch_at_login
                                    : "root"),
                      ),
                    );
                  }
                  return;
                }
              }
              prefs.setBool('app.runElevated', value);
              setState(() {
                _runElevated = value;
              });
            },
          ),
        ),
      if (RuntimePlatform.isWindows ||
          RuntimePlatform.isLinux ||
          RuntimePlatform.isMacOS)
        ListTile(
          title: Text(context.loc.close_to_tray),
          subtitle:
              Text(context.loc.dock_to_tray_instead_when_app_window_is_closed),
          trailing: Switch(
            value: _closeToTray,
            onChanged: (value) async {
              prefs.setBool('app.window.closeToTray', value);
              setState(() {
                _closeToTray = value;
              });
            },
          ),
        ),
      if (RuntimePlatform.isWindows ||
          RuntimePlatform.isLinux ||
          RuntimePlatform.isMacOS)
        ListTile(
          title: Text(context.loc.auto_connect_at_app_launch),
          subtitle:
              Text(context.loc.auto_connect_selected_profile_at_app_launch),
          trailing: Switch(
            value: _connectAtLaunch,
            onChanged: (value) async {
              prefs.setBool('app.connectAtLaunch', value);
              setState(() {
                _connectAtLaunch = value;
              });
            },
          ),
        ),
      if (RuntimePlatform.isAndroid)
        ListTile(
          title: Text(context.loc.auto_connect_at_device_boot),
          subtitle:
              Text(context.loc.auto_connect_selected_profile_at_device_boot),
          trailing: Switch(
            value: _connectAtStartup,
            onChanged: (value) async {
              prefs.setBool('app.connectAtStartup', value);
              setState(() {
                _connectAtStartup = value;
              });
            },
          ),
        ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.theme_settings,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.follow_system_brightness),
        subtitle:
            Text(context.loc.auto_change_brightness_based_on_system_settings),
        trailing: Switch(
          value: _brightnessFollowSystem,
          onChanged: (value) async {
            prefs.setBool('app.brightness.followSystem', value);
            setState(() {
              _brightnessFollowSystem = value;
            });
            themeManager.update(notify: true);
          },
        ),
      ),
      ListTile(
        enabled: _brightnessFollowSystem == false,
        title: Text(context.loc.dark_theme),
        subtitle: Text(context.loc.use_dark_theme),
        trailing: Switch(
          value: _brightnessIsDark,
          onChanged: _brightnessFollowSystem == true
              ? null
              : (value) async {
                  prefs.setBool('app.brightness.dark', value);
                  setState(() {
                    _brightnessIsDark = value;
                  });
                  themeManager.update(notify: true);
                },
        ),
      ),
      ListTile(
        title: Text(context.loc.black_dark),
        subtitle: Text(context.loc.use_black_background_in_dark_theme),
        trailing: Switch(
          value: _isBlackDark,
          onChanged: (value) async {
            prefs.setBool('app.brightness.dark.black', value);
            setState(() {
              _isBlackDark = value;
            });
            themeManager.update(notify: true);
          },
        ),
      ),
      ListTile(
        title: Text(context.loc.show_dashboard_floating_button),
        subtitle: Text(context
            .loc.disable_to_show_all_toggles_inside_a_dashboard_pane_instead),
        trailing: Switch(
          value: _isFloatingActionButton,
          onChanged: (value) async {
            prefs.setBool('app.dashboard.floatingActionButton', value);
            setState(() {
              _isFloatingActionButton = value;
            });
          },
        ),
      ),
      if (RuntimePlatform.isAndroid)
      const Divider(),
      if (RuntimePlatform.isAndroid)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            context.loc.notification,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      if (RuntimePlatform.isAndroid)
        ListTile(
          title: Text(context.loc.foreground),
          subtitle: Text(context.loc
              .runs_the_service_in_foreground_less_likely_be_killed_by_system_a_notification_must_show),
          trailing: Switch(
            value: _notificationForeground,
            onChanged: (shouldEnable) async {
              prefs.setBool('app.notification.foreground', shouldEnable);
              setState(() {
                _notificationForeground = shouldEnable;
              });
              if (vPNMan.isCoreActive) {
                if (shouldEnable) {
                  vPNMan.startNotificationForeground();
                } else {
                  vPNMan.stopNotificationForeground();
                }
              }
            },
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.general_settings),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
        // separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
