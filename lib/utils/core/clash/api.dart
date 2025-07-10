import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../logger.dart';

enum TrafficType {
  uplink,
  downlink,
}

class ClashAPI {
  late final String apiBase;
  bool shouldWatchTraffic = false;
  void Function(String) onTrafficData = (_) {};

  ClashAPI(
    String address,
    int port,
  ) {
    apiBase = "http://$address:$port";
  }

  void startWatchTraffic() {
    shouldWatchTraffic = true;
    watchTraffic();
  }

  void stopWatchTraffic() {
    shouldWatchTraffic = false;
  }

  Future<void> watchTraffic() async {
    final url = Uri.parse('$apiBase/traffic');

    final request = http.Request('GET', url);
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (!shouldWatchTraffic) break;
          try {
            onTrafficData(line);
          } catch (e) {
            logger.w('watchTraffic: failed to decode line: $line\nError: $e');
          }
        }
      } else {
        logger.w('watchTraffic failed: ${response.statusCode}');
      }
    } on (ClientException,) {
      /// ignore
    } catch (e) {
      logger.w('watchTraffic: failed: $e');
    }
  }

  void close() async {}
}
