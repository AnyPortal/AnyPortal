import 'dart:io';

import 'logger.dart';

Future<String?> getIPAddr() async {
  try {
    final process = await Process.run('python', [
      '-c',
      "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(('8.8.8.8', 80)); print(s.getsockname()[0], end =''); s.close()",
    ]);
    return process.stdout.toString();
  } catch (e) {
    logger.e("getIPAddr: $e");
    return null;
  }
}

Future<String?> getIPv4OfInterfaceName(String interfaceName) async {
  List<NetworkInterface> interfaces = await NetworkInterface.list();

  for (var interface in interfaces) {
    if (interface.name == interfaceName) {
      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4) {
          return address.address;
        }
      }
    }
  }
  return null; // Return null if no matching interface is found
}

Future<String?> getInterfaceNameOfIP(String ip) async {
  List<NetworkInterface> interfaces = await NetworkInterface.list();

  for (var interface in interfaces) {
    for (var address in interface.addresses) {
      if (address.address == ip) {
        return interface.name;
      }
    }
  }
  return null; // Return null if no matching interface is found
}
