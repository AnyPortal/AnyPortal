import 'package:flutter/material.dart';

import '../../../models/log_level.dart';
import '../../../models/send_through_binding_stratagy.dart';
import '../../../utils/prefs.dart';
import '../../../widgets/popup/radio_list_selection.dart';
import '../../../widgets/popup/text_input.dart';

class ProfileOverrideScreen extends StatefulWidget {
  const ProfileOverrideScreen({
    super.key,
  });

  @override
  State<ProfileOverrideScreen> createState() => _ProfileOverrideScreenState();
}

class _ProfileOverrideScreenState extends State<ProfileOverrideScreen> {
  bool _injectApi = prefs.getBool('inject.api')!;
  int _apiPort = prefs.getInt('inject.api.port')!;

  bool _injectLog = prefs.getBool('inject.log')!;
  LogLevel _logLevel = LogLevel.values[prefs.getInt('inject.log.level')!];

  bool _injectSocks = prefs.getBool('inject.socks')!;
  int _socksPort = prefs.getInt('inject.socks.port')!;

  bool _injectSendThrough = prefs.getBool('inject.sendThrough')!;
  String _bindingIp = prefs.getString('inject.sendThrough.bindingIp')!;
  String _bindingInterface =
      prefs.getString('inject.sendThrough.bindingInterface')!;
  SendThroughBindingStratagy _sendThroughBindingStratagy =
      SendThroughBindingStratagy
          .values[prefs.getInt('inject.sendThrough.bindingStratagy')!];

  @override
  Widget build(BuildContext context) {
    final fields = [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Api config",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text("Inject api"),
        subtitle: const Text("Necessary for dashboard infomation"),
        trailing: Switch(
          value: _injectApi,
          onChanged: (bool value) {
            prefs.setBool('inject.api', value);
            setState(() {
              _injectApi = value;
            });
          },
        ),
      ),
      ListTile(
        title: const Text('Port'),
        subtitle: Text(_apiPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Api port',
                initialValue: _apiPort.toString(),
                onSaved: (String value) {
                  final apiPort = int.parse(value);
                  setState(() {
                    _apiPort = apiPort;
                  });
                  prefs.setInt('inject.api.port', apiPort);
                }),
          );
        },
        enabled: _injectApi,
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Log config",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text("Inject Log"),
        subtitle: const Text("Override log config"),
        trailing: Switch(
          value: _injectLog,
          onChanged: (bool value) {
            prefs.setBool('inject.log', value);
            setState(() {
              _injectLog = value;
            });
          },
        ),
      ),
      ListTile(
        enabled: _injectLog,
        title: const Text('Log Level'),
        subtitle: Text(_logLevel.name),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => RadioListSelectionPopup<LogLevel>(
                    title: 'Log Level',
                    items: LogLevel.values,
                    initialValue: _logLevel,
                    onSaved: (value) {
                      prefs.setInt('inject.log.level', value.index);
                      setState(() {
                        _logLevel = value;
                      });
                    },
                    itemToString: (e) => e.name,
                  ));
        },
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Inbound config: socks",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text("Inject socks inbound"),
        subtitle: const Text(
            "inject a socks inbound"),
        trailing: Switch(
          value: _injectSocks,
          onChanged: (value) {
            prefs.setBool('inject.socks', value);
            setState(() {
              _injectSocks = value;
            });
          },
        ),
      ),
      ListTile(
        title: const Text('Port'),
        subtitle: Text(_socksPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Socks port',
                initialValue: _socksPort.toString(),
                onSaved: (String value) {
                  final socksPort = int.parse(value);
                  prefs.setInt('inject.socks.port', socksPort);
                  setState(() {
                    _socksPort = socksPort;
                  });
                }),
          );
        },
        enabled: _injectSocks,
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          "Outbound config: sendThrough",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: const Text("Inject sendThrough"),
        subtitle: const Text(
            "Bind all outbounds to ip address, useful when using with some Tun tools"),
        trailing: Switch(
          value: _injectSendThrough,
          onChanged: (bool value) {
            prefs.setBool('inject.sendThrough', value);
            setState(() {
              _injectSendThrough = value;
            });
          },
        ),
      ),
      ListTile(
        enabled: _injectSendThrough,
        title: const Text('SendThrough ip binding stratagy'),
        subtitle: Text(_sendThroughBindingStratagy.name),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) =>
                  RadioListSelectionPopup<SendThroughBindingStratagy>(
                    title: 'SendThrough binding stratagy',
                    items: SendThroughBindingStratagy.values,
                    initialValue: _sendThroughBindingStratagy,
                    onSaved: (value) {
                      prefs.setInt(
                          'inject.sendThrough.bindingStratagy', value.index);
                      setState(() {
                        _sendThroughBindingStratagy = value;
                      });
                    },
                    itemToString: (e) => e.name,
                  ));
        },
      ),
      ListTile(
        enabled: _injectSendThrough,
        title: const Text("Binding interface"),
        subtitle: Text(_bindingInterface),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Binding interface',
                initialValue: _bindingInterface,
                onSaved: (String value) {
                  prefs.setString('inject.sendThrough.bindingInterface', value);
                  setState(() {
                    _bindingInterface = value;
                  });
                }),
          );
        },
      ),
      ListTile(
        enabled: _injectSendThrough,
        title: const Text('Binding constant ip'),
        subtitle: Text(_bindingIp),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Binding constant ip',
                initialValue: _bindingIp,
                onSaved: (value) {
                  prefs.setString('inject.sendThrough.bindingIp', value);
                  setState(() {
                    _bindingIp = value;
                  });
                }),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Profile override"),
              ),
      body: Form(
        child: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) => fields[index],
          // separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }
}
