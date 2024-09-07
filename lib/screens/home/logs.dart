import 'dart:async';
import 'package:flutter/material.dart';

import '../../widgets/ray_toggle.dart';
import '../../utils/ray_core.dart';

Widget colorizeLogLine(String logline) {
  // Regular expression to capture datetime, protocol, IP, ports, and other parts.
  final RegExp regex = RegExp(
      r'(\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) (tcp:|udp:)?(.+):(\d+) accepted (tcp:|udp:)?(.+):(\d+) (.*)');
  final match = regex.firstMatch(logline);

  if (match == null) {
    return Text(
        logline); // Return plain text if the line doesn't match the pattern
  }

  // Extract matched groups
  final datetime = match.group(1); // e.g. 2024/09/06 20:48:34
  final protocol1 = match.group(2); // e.g. tcp or udp
  final ip1 = match.group(3); // e.g. 127.0.0.1
  final port1 = match.group(4); // e.g. 36214
  final protocol2 = match.group(5); // e.g. tcp or udp
  final address2 = match.group(6); // e.g. alive.github.com
  final port2 = match.group(7); // e.g. 443
  final extra = match.group(8); // e.g. in_9511 -> ot_lp_bl_29_57_25_cf.vultr

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '$datetime ', // DateTime part
          style:
              const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '$protocol1:$ip1:$port1 ', // First protocol, IP, and port
          style: const TextStyle(color: Colors.orange),
        ),
        const TextSpan(
          text: 'accepted ', // Accepted text
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          text:
              '$protocol2:$address2:$port2 ', // Second protocol, address, and port
          style: const TextStyle(color: Colors.orange),
        ),
        TextSpan(
          text: '[$extra]', // Extra information in brackets
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}

class RayOutput extends StatefulWidget {
  const RayOutput({
    super.key,
  });
  @override
  RayOutputState createState() => RayOutputState();
}

class RayOutputState extends State<RayOutput> {
  late StreamSubscription<List<String>> _subscription;
  List<String> _output = [];

  @override
  void initState() {
    super.initState();
    // first initialization upon creation
    setState(() {
      _output = rayCore.output;
    });
    // dynamic update upon outputStream update
    _subscription = rayCore.outputStream.listen((output) {
      setState(() {
        _output = output;
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    rayCore.dispose();
    super.dispose();
  }

  final ScrollController _controller = ScrollController();
  void _scrollToBottom() {
    if (_controller.hasClients) _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SelectionArea(
              child: ListView.builder(
            controller: _controller,
            itemCount: _output.length,
            itemBuilder: (context, index) {
              return Text(
                _output[index],
              );
            },
          ))),
      floatingActionButton: const RayToggle(),
    );
  }
}
