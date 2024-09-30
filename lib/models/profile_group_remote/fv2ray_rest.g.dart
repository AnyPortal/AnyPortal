// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fv2ray_rest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      json['name'] as String,
      json['config'],
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'name': instance.name,
      'config': instance.config,
    };

ProfileGroupRemoteFv2rayREST _$ProfileGroupRemoteFv2rayRESTFromJson(
        Map<String, dynamic> json) =>
    ProfileGroupRemoteFv2rayREST(
      (json['version'] as num).toInt(),
      (json['profiles'] as List<dynamic>)
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileGroupRemoteFv2rayRESTToJson(
        ProfileGroupRemoteFv2rayREST instance) =>
    <String, dynamic>{
      'version': instance.version,
      'profiles': instance.profiles,
    };
