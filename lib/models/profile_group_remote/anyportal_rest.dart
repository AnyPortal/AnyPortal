import 'package:json_annotation/json_annotation.dart';

part 'anyportal_rest.g.dart';

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
class ProfileGroupRemoteAnyPortalREST {
  final int version;
  final List<Profile> profiles;

  ProfileGroupRemoteAnyPortalREST(this.version, this.profiles);

  factory ProfileGroupRemoteAnyPortalREST.fromJson(Map<String, dynamic> json) => _$ProfileGroupRemoteAnyPortalRESTFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileGroupRemoteAnyPortalRESTToJson(this);
}