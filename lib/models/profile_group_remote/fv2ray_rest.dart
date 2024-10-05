import 'package:json_annotation/json_annotation.dart';

part 'fv2ray_rest.g.dart';

@JsonSerializable()
class Profile {
  final String name;
  final String coreType;
  final String format;
  final dynamic coreConfig;

  Profile(this.name, this.coreType, this.format, this.coreConfig);

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class ProfileGroupRemoteFv2rayREST {
  final int version;
  final List<Profile> profiles;

  ProfileGroupRemoteFv2rayREST(this.version, this.profiles);

  factory ProfileGroupRemoteFv2rayREST.fromJson(Map<String, dynamic> json) => _$ProfileGroupRemoteFv2rayRESTFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileGroupRemoteFv2rayRESTToJson(this);
}