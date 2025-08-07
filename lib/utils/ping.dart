import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'logger.dart';

Future<ServerSocket> getFreeServerSocket() async {
  final serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  return serverSocket;
}

/// Attempts to establish a TCP connection to a SOCKS server.
/// Returns `socket` if the connection was successful within the timeout,
/// `null` otherwise.
Future<Socket?> ensureSocksConnectionOnce({
  required String host,
  required int port,
  Duration timeout = const Duration(seconds: 5),
}) async {
  Socket? socket;

  try {
    socket = await Socket.connect(host, port).timeout(timeout);
    return socket;
  } on TimeoutException {
    return null;
  } on SocketException catch (_) {
    // logger.d(e);
    return null;
  }
}

Future<Socket?> ensureSocksConnection({
  required String host,
  required int port,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  Socket? socket;
  while (DateTime.now().isBefore(deadline)) {
    socket = await ensureSocksConnectionOnce(
        host: host, port: port, timeout: timeout);
    if (socket != null) {
      return socket;
    }
  }
  logger.w('ensureSocksConnection: timeout');
  return null;
}

Future<Duration?> httpingOverSocks(
  String socksServer,
  int socksPort,
  String url, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final socket =
      await ensureSocksConnection(host: socksServer, port: socksPort);
  if (socket == null) {
    return null;
  } else {
    socket.destroy();
  }

  final client = HttpClient();
  client.findProxy = (uri) {
    return 'PROXY 127.0.0.1:$socksPort;';
  };

  return httping(client, url, timeout);
}

Future<Duration?> httping(
  HttpClient client,
  String url,
  Duration timeout,
) async {
  try {
    final stopwatch = Stopwatch()..start();
    final request = await client
        .getUrl(
          Uri.parse(url),
        )
        .timeout(timeout);
    final response = await request.close();
    stopwatch.stop();
    if (response.statusCode == 204) {
      return stopwatch.elapsed;
    }
  } catch (_) {
    logger.d(_);
  }

  return null;
}

Future<Duration?> tcpingOverSocks(
  String socksServer,
  int socksPort,
  String targetHost,
  int targetPort, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final socket =
      await ensureSocksConnection(host: socksServer, port: socksPort);
  if (socket == null) {
    logger.w("tcpingOverSocks: socket == null");
    return null;
  }

  return await tcping(socket, targetHost, targetPort, timeout);
}

Future<Duration?> tcping(
  Socket socket,
  String targetHost,
  int targetPort,
  Duration timeout,
) async {
  final buffer = BytesBuilder();
  final readRequests = <_ReadRequest>[];
  final cancel = Completer<void>();

  void handleData(List<int> data) {
    buffer.add(data);
    while (
        readRequests.isNotEmpty && buffer.length >= readRequests.first.length) {
      final request = readRequests.removeAt(0);
      final dataBytes = buffer.takeBytes();
      request.completer
          .complete(Uint8List.fromList(dataBytes.sublist(0, request.length)));
      final leftover = dataBytes.sublist(request.length);
      if (leftover.isNotEmpty) buffer.add(leftover);
    }
  }

  Future<Uint8List?> readExact(int n, Duration timeout) {
    final completer = Completer<Uint8List?>();
    final request = _ReadRequest(n, completer);
    readRequests.add(request);

    Timer(timeout, () {
      if (!completer.isCompleted) {
        logger.d("readExact: timeout");
        readRequests.remove(request);
        completer.complete(null);
      }
    });

    return completer.future;
  }

  try {
    socket.listen(
      handleData,
      onError: (_) {
        cancel.complete();
        for (final r in readRequests) {
          if (!r.completer.isCompleted) r.completer.complete(null);
        }
      },
      onDone: () {
        cancel.complete();
        for (final r in readRequests) {
          if (!r.completer.isCompleted) r.completer.complete(null);
        }
      },
      cancelOnError: true,
    );

    // 1. Send greeting
    logger.d("starting: snd greeting");
    socket.add([0x05, 0x01, 0x00]);
    await socket.flush();
    logger.d("finished: snd greeting");

    logger.d("starting: rcv greeting");
    final response1 = await readExact(2, timeout);
    if (response1 == null || response1[0] != 0x05 || response1[1] != 0x00) {
      throw Exception("SOCKS5 handshake failed");
    }
    logger.d("finished: rcv greeting");

    final stopwatch = Stopwatch()..start();

    // 2. Send connect request
    logger.d("starting: snd connect");
    final hostBytes = _encodeAddress(targetHost);
    final portBytes = Uint8List(2)
      ..buffer.asByteData().setUint16(0, targetPort);
    socket.add([
      0x05, // version
      0x01, // CONNECT
      0x00, // reserved
      ...hostBytes,
      ...portBytes
    ]);
    await socket.flush();
    logger.d("finished: snd connect");

    logger.d("starting: rcv connect");
    final response2 = await readExact(4, timeout);
    if (response2 == null || response2[1] != 0x00) {
      throw Exception("SOCKS5 connect failed");
    }
    logger.d("finished: rcv connect");

    logger.d("starting: calc remaining");
    int remaining;
    logger.d("response2[3]: ${response2[3]}");
    switch (response2[3]) {
      case 0x01:
        remaining = 4 + 2;
        break;
      case 0x04:
        remaining = 16 + 2;
        break;
      case 0x03:
        final lenByte = await readExact(1, timeout);
        if (lenByte == null) throw Exception("Invalid domain length");
        remaining = lenByte[0] + 2;
        break;
      default:
        throw Exception("Unknown address type in reply");
    }
    logger.d("remaining: $remaining");
    logger.d("finished: calc remaining");

    logger.d("starting: rcv ping");
    final _ = await readExact(remaining, Duration(seconds: 15));
    logger.d("finished: rcv ping");

    stopwatch.stop();
    return stopwatch.elapsed;
  } catch (_) {
    return null;
  } finally {
    socket.destroy();
  }
}

class _ReadRequest {
  final int length;
  final Completer<Uint8List?> completer;
  _ReadRequest(this.length, this.completer);
}

// Encodes domain/IP for SOCKS5
Uint8List _encodeAddress(String host) {
  final ip = InternetAddress.tryParse(host);
  if (ip != null) {
    if (ip.type == InternetAddressType.IPv4) {
      return Uint8List.fromList([0x01, ...ip.rawAddress]);
    } else if (ip.type == InternetAddressType.IPv6) {
      return Uint8List.fromList([0x04, ...ip.rawAddress]);
    }
  }

  final nameBytes = utf8.encode(host);
  return Uint8List.fromList([0x03, nameBytes.length, ...nameBytes]);
}
