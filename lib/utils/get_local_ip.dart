import 'dart:io';

Future<String?> getIPAddr() async {
  try {
    final process = await Process.run('python', [
      '-c',
      "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(('8.8.8.8', 80)); print(s.getsockname()[0], end =''); s.close()"
    ]);
    return process.stdout.toString();
  } catch (e) {
    return null;
  }
}

Future<String?> getIPv4OfInterface(String interfaceName) async {
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