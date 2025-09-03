import 'package:json_annotation/json_annotation.dart';

part 'anyportal_rest.g.dart';

@JsonSerializable()
class Profile {
  final String name;
  final String key;
  final String coreType;
  final String format;
  final dynamic coreConfig;

  Profile(
    this.name,
    this.key,
    this.coreType,
    this.format,
    this.coreConfig,
  );

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      json['name'] as String,
      (json['key'] ?? json['name']) as String,
      json['coreType'] as String,
      json['format'] as String,
      json['coreConfig'],
    );
  }

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class ProfileGroupRemoteAnyPortalREST {
  final int version;
  final List<Profile> profiles;

  ProfileGroupRemoteAnyPortalREST(this.version, this.profiles);

  factory ProfileGroupRemoteAnyPortalREST.fromJson(Map<String, dynamic> json) =>
      _$ProfileGroupRemoteAnyPortalRESTFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProfileGroupRemoteAnyPortalRESTToJson(this);
}
