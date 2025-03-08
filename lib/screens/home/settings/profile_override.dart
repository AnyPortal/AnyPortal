import 'package:flutter/material.dart';

import 'package:anyportal/extensions/localization.dart';
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
  bool _injectHttp = prefs.getBool('inject.http')!;

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
          context.loc.api_config,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_api),
        subtitle: Text(context.loc.necessary_for_dashboard_infomation),
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
        title: Text(context.loc.port),
        subtitle: Text(_apiPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: context.loc.api_port,
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
          context.loc.log_config,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_log),
        subtitle: Text(context.loc.override_log_config),
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
        title: Text(context.loc.log_level),
        subtitle: Text(_logLevel.name),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => RadioListSelectionPopup<LogLevel>(
                    title: context.loc.log_level,
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
          context.loc.inbound_config,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_socks_inbound),
        subtitle: Text(
            "${prefs.getString('app.server.address')!}:${prefs.getInt('app.socks.port')!}, ${context.loc.see_settings_connectivity}"),
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
        title: Text(context.loc.inject_http_inbound),
        subtitle: Text(
            "${prefs.getString('app.server.address')!}:${prefs.getInt('app.http.port')!}, ${context.loc.see_settings_connectivity}"),
        trailing: Switch(
          value: _injectHttp,
          onChanged: (value) {
            prefs.setBool('inject.http', value);
            setState(() {
              _injectHttp = value;
            });
          },
        ),
      ),
      const Divider(),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          context.loc.outbound_config_send_through,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      ListTile(
        title: Text(context.loc.inject_send_through),
        subtitle: Text(
            context.loc.bind_all_outbounds_to_ip_address_useful_when_using_with_some_tun_tools),
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
        title: Text(context.loc.send_through_ip_binding_stratagy),
        subtitle: Text(_sendThroughBindingStratagy.name),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) =>
                  RadioListSelectionPopup<SendThroughBindingStratagy>(
                    title: context.loc.send_through_binding_stratagy,
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
      if (_sendThroughBindingStratagy == SendThroughBindingStratagy.interface) ListTile(
        enabled: _injectSendThrough,
        title: Text(context.loc.binding_interface),
        subtitle: Text(_bindingInterface),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: context.loc.binding_interface,
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
      if (_sendThroughBindingStratagy == SendThroughBindingStratagy.ip) ListTile(
        enabled: _injectSendThrough,
        title: Text(context.loc.binding_ip),
        subtitle: Text(_bindingIp),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: context.loc.binding_ip,
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
        title: Text(context.loc.profile_override),
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
