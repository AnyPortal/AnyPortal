import 'package:json_annotation/json_annotation.dart';

part 'base.g.dart';

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

class ProfileGroupRemoteBase {
  final List<Profile> profiles;
  // String? name;
  // String? autoUpdateInterval;
  // String? supportUrl;
  // String? subscriptionUserinfo;

  ProfileGroupRemoteBase(this.profiles);
}
