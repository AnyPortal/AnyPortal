import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../logger.dart';

enum TrafficType {
  uplink,
  downlink,
}

class ClashAPI {
  late final String apiBase;
  bool shouldWatch = false;
  void Function(String) onTrafficData = (_) {};
  void Function(String) onMemoryData = (_) {};

  ClashAPI(
    String address,
    int port,
  ) {
    apiBase = "http://$address:$port";
  }

  void startWatchTraffic() {
    shouldWatch = true;
    watchTraffic();
    watchMemory();
  }

  void stopWatchTraffic() {
    shouldWatch = false;
  }

  Future<void> watchHttpGetStream(
    Uri uri,
    void Function(String) onData, {
    int retryCount = 0,
  }) async {
    final request = http.Request('GET', uri);
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (!shouldWatch) break;
          try {
            onData(line);
          } catch (e) {
            logger.w(
              'watchHttpGetStream: failed to decode line: $line\nError: $e',
            );
          }
        }
      } else {
        logger.w('watchHttpGetStream failed: ${response.statusCode}');
      }
    } catch (e) {
      logger.w('watchHttpGetStream: failed: $e');
      await Future.delayed(Duration(seconds: 1));
      retryCount += 1;
      if (shouldWatch && retryCount < 5) {
        logger.w('watchHttpGetStream: retryCount: $retryCount');
        await (watchHttpGetStream(uri, onData, retryCount: retryCount));
      }
    }
  }

  Future<void> watchTraffic() async {
    return await watchHttpGetStream(
      Uri.parse('$apiBase/traffic'),
      onTrafficData,
    );
  }

  Future<void> watchMemory() async {
    return await watchHttpGetStream(
      Uri.parse('$apiBase/memory'),
      onMemoryData,
    );
  }

  void close() async {}
}
