import 'package:json_annotation/json_annotation.dart';

import 'base.dart';

part 'anyportal_rest.g.dart';

@JsonSerializable()
class ProfileGroupRemoteAnyPortalREST extends ProfileGroupRemoteBase {
  final int version;

  ProfileGroupRemoteAnyPortalREST(
    this.version,
    super.profiles, {
    super.name,
    super.autoUpdateInterval,
    super.subscriptionUserInfo,
    super.supportUrl,
    super.profileWebPageUrl,
  });

  factory ProfileGroupRemoteAnyPortalREST.fromJson(Map<String, dynamic> json) =>
      _$ProfileGroupRemoteAnyPortalRESTFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProfileGroupRemoteAnyPortalRESTToJson(this);
}
