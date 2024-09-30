import 'package:json_annotation/json_annotation.dart';

part 'fv2ray_rest.g.dart';

@JsonSerializable()
class Profile {
  final String name;
  final dynamic config;

  Profile(this.name, this.config);

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