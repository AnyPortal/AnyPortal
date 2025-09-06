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

@JsonSerializable()
class SubscriptionUserInfo {
  num? expire;
  num? total;
  num? upload;
  num? download;

  SubscriptionUserInfo(this.expire, this.total, this.upload, this.download);

  factory SubscriptionUserInfo.fromJson(Map<String, dynamic> json) {
    return _$SubscriptionUserInfoFromJson(json);
  }
}

class ProfileGroupRemoteBase {
  final List<Profile> profiles;
  String? name;
  int? autoUpdateInterval;
  SubscriptionUserInfo? subscriptionUserInfo;
  String? supportUrl;
  String? profileWebPageUrl;

  ProfileGroupRemoteBase(
    this.profiles, {
    this.name,
    this.autoUpdateInterval,
    this.subscriptionUserInfo,
    this.supportUrl,
    this.profileWebPageUrl,
  });
}
