import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';

import 'package:anyportal/models/profile_group_remote/generic.dart';

void main() {
  setUp(() {
    GetIt.I.reset();
    GetIt.I.registerLazySingleton<Logger>(() => Logger());
  });

  /// https://github.com/XTLS/Xray-core/issues/91
  final s =
      """vmess://99c80931-f3f1-4f84-bffd-6eed6030f53d@qv2ray.net:31415?encryption=none#VMessTCPNaked
vmess://f08a563a-674d-4ffb-9f02-89d28aec96c9@qv2ray.net:9265#VMessTCPAuto
vmess://5dc94f3a-ecf0-42d8-ae27-722a68a6456c@qv2ray.net:35897?encryption=aes-128-gcm#VMessTCPAES
vmess://136ca332-f855-4b53-a7cc-d9b8bff1a8d7@qv2ray.net:9323?encryption=none&security=tls#VMessTCPTLSNaked
vmess://be5459d9-2dc8-4f47-bf4d-8b479fc4069d@qv2ray.net:8462?security=tls#VMessTCPTLS
vmess://c7199cd9-964b-4321-9d33-842b6fcec068@qv2ray.net:64338?encryption=none&security=tls&sni=fastgit.org#VMessTCPTLSSNI
vless://b0dd64e4-0fbd-4038-9139-d1f32a68a0dc@qv2ray.net:3279?security=xtls&flow=rprx-xtls-splice#VLESSTCPXTLSSplice
vless://399ce595-894d-4d40-add1-7d87f1a3bd10@qv2ray.net:50288?type=kcp&seed=69f04be3-d64e-45a3-8550-af3172c63055#VLESSmKCPSeed
vless://399ce595-894d-4d40-add1-7d87f1a3bd10@qv2ray.net:41971?type=kcp&headerType=wireguard&seed=69f04be3-d64e-45a3-8550-af3172c63055#VLESSmKCPSeedWG
vmess://44efe52b-e143-46b5-a9e7-aadbfd77eb9c@qv2ray.net:6939?type=ws&security=tls&host=qv2ray.net&path=%2Fsomewhere#VMessWebSocketTLS
""";
  test("ProfileGroupRemotegeneric", () {
    final length = LineSplitter().convert(s).length;
    final pg = ProfileGroupRemoteGeneric.fromString(s, "xray");
    expect(pg.profiles.length, equals(length));
    // print(pg.profiles[0].coreConfig);

    final sBase64 = base64.encode(utf8.encode(s));
    final pgBase64 = ProfileGroupRemoteGeneric.fromString(sBase64, "sing-box");
    expect(pgBase64.profiles.length, equals(1));
    // for (final p in pgBase64.profiles) {
    //   print(p.coreConfig);
    // }
  });
}
