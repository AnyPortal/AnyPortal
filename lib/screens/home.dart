import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../extensions/localization.dart';
import '../utils/global.dart';
import '../utils/permission_manager.dart';
import '../utils/prefs.dart';
import '../utils/runtime_platform.dart';
import '../utils/theme_manager.dart';
import '../utils/vpn_manager.dart';
import '../widgets/vpn_toggles.dart';

import 'home/dashboard.dart';
import 'home/logs.dart';
import 'home/profiles.dart';
import 'home/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class ScreenNav {
  Widget widget;
  String title;
  Icon icon;

  ScreenNav(this.widget, this.title, this.icon);
}

class _HomePageState extends State<HomePage> with WindowListener, TrayListener {
  int _selectedIndex = 0;

  void setSelectedIndex(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await permMan.onHomeScreen(context);
    });
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscapeLayout =
        MediaQuery.of(context).orientation == Orientation.landscape;

    List<ScreenNav> screens = <ScreenNav>[
      ScreenNav(
        Dashboard(
          setSelectedIndex: setSelectedIndex,
          isLandscapeLayout: isLandscapeLayout,
        ),
        context.loc.dashboard,
        const Icon(Icons.dashboard),
      ),
      ScreenNav(
        LogViewer(),
        context.loc.logs,
        const Icon(Icons.message),
      ),
      ScreenNav(
        const ProfileList(),
        context.loc.profiles,
        const Icon(Icons.description),
      ),
      ScreenNav(
        const SettingList(),
        context.loc.settings,
        const Icon(Icons.settings),
      ),
    ];

    // Layout for landscape mode with custom drawer
    Widget landscapeLayout = Scaffold(
      body: Row(
        children: [
          // Custom Drawer in landscape mode
          SizedBox(
            width: 250,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: screens.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final screen = entry.value;
                      return Card(
                        // color: _selectedIndex == index
                        //     ? Theme.of(context).colorScheme.surfaceContainerLowest
                        //     : Theme.of(context).colorScheme.surfaceContainer,
                        // shadowColor: _selectedIndex == index
                        //     ? Theme.of(context).colorScheme.shadow
                        //     : Colors.transparent,
                        color: _selectedIndex == index
                            ? Theme.of(context).cardTheme.color
                            : Colors.transparent,
                        shadowColor: _selectedIndex == index
                            ? Theme.of(context).cardTheme.shadowColor
                            : Colors.transparent,
                        child: ListTile(
                          leading: screen.icon,
                          title: Text(screen.title),
                          selected: _selectedIndex == index,
                          selectedColor: Theme.of(
                            context,
                          ).textTheme.titleMedium!.color,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                  child: VPNToggles(isDense: true),
                ),
              ],
            ),
          ),
          // Body of the app
          Expanded(
            child: Center(
              child: screens.elementAt(_selectedIndex).widget,
            ),
          ),
        ],
      ),
    );

    // Layout for portrait mode with bottom navigation bar
    Widget portraitLayout = Scaffold(
      body: Center(
        child: screens.elementAt(_selectedIndex).widget,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: screens.map((screen) {
          return NavigationDestination(
            icon: screen.icon,
            label: screen.title,
          );
        }).toList(),
      ),
    );

    // Switch between portrait and landscape layouts
    return isLandscapeLayout ? landscapeLayout : portraitLayout;
  }

  // @override
  // void onWindowEvent(String eventName) {
  //   logger.d('[WindowManager] onWindowEvent: $eventName');
  // }

  static final pendingInstallerExitFlagFile = File(
    p.join(
      global.applicationSupportDirectory.path,
      "pending_installer_exit.flag",
    ),
  );

  @override
  void onWindowClose() async {
    if (RuntimePlatform.isWindows &&
        await pendingInstallerExitFlagFile.exists()) {
      await pendingInstallerExitFlagFile.delete();
      await vPNMan.stopAll();
      exit(0);
    }
    windowManager.hide();
  }

  /// only on Windows, macOS
  @override
  void onTrayIconMouseDown() async {
    windowManager.show();
    windowManager.setSkipTaskbar(false);
  }

  /// only on Windows, macOS
  @override
  void onTrayIconRightMouseDown() async {
    // await trayMenu.updateContextMenu();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
      case 'hide':
        windowManager.hide();
      case 'exit':
        // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        await vPNMan.stopAll();
        exit(0);
      case 'toggle_all':
        final shouldEnable = !menuItem.checked!;
        menuItem.checked = shouldEnable;
        if (shouldEnable) {
          vPNMan.startAll();
        } else {
          vPNMan.stopAll();
        }
      case 'toggle_tun':
        final shouldEnable = !menuItem.checked!;
        menuItem.checked = shouldEnable;
        await prefs.setBool("tun", shouldEnable);
        prefs.notifyListeners();
        if (await vPNMan.getIsCoreActive()) {
          if (shouldEnable) {
            await vPNMan.startTun();
          } else {
            await vPNMan.stopTun();
          }
        }
      case 'toggle_system_proxy':
        final shouldEnable = !menuItem.checked!;
        menuItem.checked = shouldEnable;
        await prefs.setBool("systemProxy", shouldEnable);
        prefs.notifyListeners();
        if (await vPNMan.getIsCoreActive()) {
          if (shouldEnable) {
            await vPNMan.startSystemProxy();
          } else {
            await vPNMan.stopSystemProxy();
          }
        }
    }
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    prefs.setDouble("app.window.size.width", size.width);
    prefs.setDouble("app.window.size.height", size.height);
  }

  @override
  void onWindowMaximize() async {
    prefs.setBool("app.window.isMaximized", true);
  }

  @override
  void onWindowUnmaximize() async {
    prefs.setBool("app.window.isMaximized", false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    themeManager.update().then((_) {
      if (RuntimePlatform.isWindows || RuntimePlatform.isMacOS) {
        var isDark = themeManager.isDark;
        Window.setEffect(
          effect: RuntimePlatform.isLinux || RuntimePlatform.isMacOS
              ? WindowEffect.disabled
              : WindowEffect.mica,
          dark: isDark,
        );
      }
    });
  }
}
