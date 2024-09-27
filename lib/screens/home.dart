import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home/logs.dart';
import 'home/dashboard.dart';
import 'home/profiles.dart';
import 'home/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

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

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _pathLog = "";

  setSelectedIndex(i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((folder) {
      setState(() {
        _pathLog =
            File(p.join(folder.path, 'fv2ray', 'core.log')).absolute.path;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ScreenNav> screens = <ScreenNav>[
      ScreenNav(
        Dashboard(setSelectedIndex: setSelectedIndex),
        AppLocalizations.of(context)!.dashboard,
        const Icon(Icons.dashboard),
      ),
      ScreenNav(
        LogViewer(filePath: _pathLog),
        AppLocalizations.of(context)!.logs,
        const Icon(Icons.message),
      ),
      ScreenNav(
        const ProfileList(),
        AppLocalizations.of(context)!.profiles,
        const Icon(Icons.description),
      ),
      ScreenNav(
        const SettingList(),
        AppLocalizations.of(context)!.settings,
        const Icon(Icons.settings),
      ),
    ];

    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Layout for landscape mode with custom drawer
    Widget landscapeLayout = Scaffold(
        body: Row(
      children: [
        // Custom Drawer in landscape mode
        Container(
            width: 250,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ListView(
                padding: const EdgeInsets.all(12),
                children: (screens.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final screen = entry.value;
                  return Card(
                      color: _selectedIndex == index
                          ? Theme.of(context).colorScheme.surfaceContainerLowest
                          : Theme.of(context).colorScheme.surfaceContainer,
                      shadowColor: _selectedIndex == index
                          ? Theme.of(context).colorScheme.shadow
                          : Colors.transparent,
                      child: ListTile(
                        leading: screen.icon,
                        title: Text(screen.title),
                        selected: _selectedIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ));
                }).toList()))),
        // Body of the app
        Expanded(
          child: Center(
            child: screens.elementAt(_selectedIndex).widget,
          ),
        ),
      ],
    ));

    // Layout for portrait mode with bottom navigation bar
    Widget portraitLayout = Scaffold(
        appBar: AppBar(
          // Use the selected tab's label for the AppBar title
          title: Text(screens[_selectedIndex].title),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
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
            }).toList()));

    // Switch between portrait and landscape layouts
    return isLandscape ? landscapeLayout : portraitLayout;
  }
}
