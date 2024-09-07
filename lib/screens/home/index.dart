import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'logs.dart';
import 'profiles.dart';
import 'settings/index.dart';


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


class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of titles for the AppBar (corresponding to BottomNavigationBar items)
  static const List<String> _appBarTitles = <String>[
    'Dashboard',
    'Logs',
    'Profiles',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    // List of widget options (one for each tab)
    List<Widget> widgetOptions = <Widget>[
      const Dashboard(),
      const RayOutput(),
      const ProfileList(),
      const SettingList(),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.description),
            label: 'profiles',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      )
    );
  }
}
