
import 'package:grpc/grpc.dart';

import '../generated/grpc/v2ray-core/app/stats/command/command.pbgrpc.dart';

enum TrafficType{
  uplink,
  downlink,
}

class V2ApiServer{
  late ClientChannel channel;
  late StatsServiceClient statsServiceClient;

  V2ApiServer(String address, int port){
    channel = ClientChannel(
      'localhost',
      port: port,
      options: ChannelOptions(
        credentials: const ChannelCredentials.insecure(),
        codecRegistry:
            CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
      ),
    );
    statsServiceClient = StatsServiceClient(channel);
  }

  Future<int> getUserTraffic(String email, TrafficType trafficType, {bool reset=false}) async {
    final response = await statsServiceClient.getStats(
      GetStatsRequest(name:"user>>>$email>>>traffic>>>${trafficType.name}", reset: reset),
      // options: CallOptions(compression: const GzipCodec()),
    );
    return response.stat.value.toInt();
  }

  Future<List<Stat>> queryStats({String? pattern, List<String>? patterns, bool? reset, bool? regexp}) async {
    final response = await statsServiceClient.queryStats(
      QueryStatsRequest(pattern: pattern, patterns: patterns, reset: reset, regexp: regexp),
    );
    return response.stat;
  }

  Future<SysStatsResponse> getSysStats() async {
    final response = await statsServiceClient.getSysStats(
      SysStatsRequest(),
    );
    return response;
  }

  void close() async {
    // User requested close.
    await channel.shutdown();
  }
}
