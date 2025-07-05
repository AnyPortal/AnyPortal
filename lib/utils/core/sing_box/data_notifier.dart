import '../v2ray/data_notifier.dart';

class CoreDataNotifierSingBox extends CoreDataNotifierV2Ray {
  @override
  Set<String> get protocolDirect => {"direct"};

  @override
  String get protocolKey => "type";
}
