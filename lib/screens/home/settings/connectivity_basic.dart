import 'package:flutter/material.dart';

import '../../../extensions/localization.dart';
import '../../../utils/prefs.dart';
import '../../../widgets/popup/text_input.dart';

class ConnectivityBasicScreen extends StatefulWidget {
  const ConnectivityBasicScreen({
    super.key,
  });

  @override
  State<ConnectivityBasicScreen> createState() => _ConnectivityBasicScreenState();
}

class _ConnectivityBasicScreenState extends State<ConnectivityBasicScreen> {
  int _socksPort = prefs.getInt('app.socks.port')!;
  int _httpPort = prefs.getInt('app.http.port')!;
  String _serverAddress = prefs.getString('app.server.address')!;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ListTile(
        title: Text(context.loc.server_address),
        subtitle: Text(_serverAddress),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: context.loc.server_address,
                initialValue: _serverAddress,
                onSaved: (String value) {
                  prefs.setString('app.server.address', _serverAddress);
                  setState(() {
                    _serverAddress = value;
                  });
                }),
          );
        },
      ),
      ListTile(
        title: Text(context.loc.socks_port),
        subtitle: Text(_socksPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: context.loc.socks_port,
                text: context.loc.you_may_want_to_check_settings_profile_override_inject_socks_inbound,
                initialValue: _socksPort.toString(),
                onSaved: (String value) {
                  final socksPort = int.parse(value);
                  prefs.setInt('app.socks.port', socksPort);
                  setState(() {
                    _socksPort = socksPort;
                  });
                }),
          );
        },
      ),
      ListTile(
        title: Text(context.loc.http_port),
        subtitle: Text(_httpPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: context.loc.http_port,
                text: context.loc.you_may_want_to_check_settings_profile_override_inject_http_inbound,
                initialValue: _httpPort.toString(),
                onSaved: (String value) {
                  final httpPort = int.parse(value);
                  prefs.setInt('app.http.port', httpPort);
                  setState(() {
                    _httpPort = httpPort;
                  });
                }),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.connectivity_basic_settings),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
        // separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
