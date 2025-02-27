import 'package:flutter/material.dart';

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
        title: const Text('Server address'),
        subtitle: Text(_serverAddress),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Server address',
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
        title: const Text('Socks port'),
        subtitle: Text(_socksPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'Socks port',
                text: 'You may want to check `Settings` -> `Profile override` -> `Inject socks inbound`',
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
        title: const Text('HTTP port'),
        subtitle: Text(_httpPort.toString()),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TextInputPopup(
                title: 'HTTP port',
                text: 'You may want to check `Settings` -> `Profile override` -> `Inject http inbound`',
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
        title: const Text("Connectivity basic settings"),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) => fields[index],
        // separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
