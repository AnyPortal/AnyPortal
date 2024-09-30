// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $ProfileGroupTable extends ProfileGroup
    with drift.TableInfo<$ProfileGroupTable, ProfileGroupData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileGroupTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta =
      const drift.VerificationMeta('id');
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _nameMeta =
      const drift.VerificationMeta('name');
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const drift.VerificationMeta _lastUpdatedMeta =
      const drift.VerificationMeta('lastUpdated');
  @override
  late final drift.GeneratedColumn<DateTime> lastUpdated =
      drift.GeneratedColumn<DateTime>('last_updated', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const drift.VerificationMeta _typeMeta =
      const drift.VerificationMeta('type');
  @override
  late final drift.GeneratedColumnWithTypeConverter<ProfileGroupType, int>
      type = drift.GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProfileGroupType>($ProfileGroupTable.$convertertype);
  @override
  List<drift.GeneratedColumn> get $columns => [id, name, lastUpdated, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_group';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ProfileGroupData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    context.handle(_typeMeta, const drift.VerificationResult.success());
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileGroupData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileGroupData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      type: $ProfileGroupTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $ProfileGroupTable createAlias(String alias) {
    return $ProfileGroupTable(attachedDatabase, alias);
  }

  static drift.TypeConverter<ProfileGroupType, int> $convertertype =
      const ProfileGroupTypeConverter();
}

class ProfileGroupData extends drift.DataClass
    implements drift.Insertable<ProfileGroupData> {
  final int id;
  final String name;
  final DateTime lastUpdated;
  final ProfileGroupType type;
  const ProfileGroupData(
      {required this.id,
      required this.name,
      required this.lastUpdated,
      required this.type});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['name'] = drift.Variable<String>(name);
    map['last_updated'] = drift.Variable<DateTime>(lastUpdated);
    {
      map['type'] =
          drift.Variable<int>($ProfileGroupTable.$convertertype.toSql(type));
    }
    return map;
  }

  ProfileGroupCompanion toCompanion(bool nullToAbsent) {
    return ProfileGroupCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      lastUpdated: drift.Value(lastUpdated),
      type: drift.Value(type),
    );
  }

  factory ProfileGroupData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ProfileGroupData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      type: serializer.fromJson<ProfileGroupType>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'type': serializer.toJson<ProfileGroupType>(type),
    };
  }

  ProfileGroupData copyWith(
          {int? id,
          String? name,
          DateTime? lastUpdated,
          ProfileGroupType? type}) =>
      ProfileGroupData(
        id: id ?? this.id,
        name: name ?? this.name,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        type: type ?? this.type,
      );
  ProfileGroupData copyWithCompanion(ProfileGroupCompanion data) {
    return ProfileGroupData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lastUpdated, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileGroupData &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastUpdated == this.lastUpdated &&
          other.type == this.type);
}

class ProfileGroupCompanion extends drift.UpdateCompanion<ProfileGroupData> {
  final drift.Value<int> id;
  final drift.Value<String> name;
  final drift.Value<DateTime> lastUpdated;
  final drift.Value<ProfileGroupType> type;
  const ProfileGroupCompanion({
    this.id = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.lastUpdated = const drift.Value.absent(),
    this.type = const drift.Value.absent(),
  });
  ProfileGroupCompanion.insert({
    this.id = const drift.Value.absent(),
    required String name,
    required DateTime lastUpdated,
    required ProfileGroupType type,
  })  : name = drift.Value(name),
        lastUpdated = drift.Value(lastUpdated),
        type = drift.Value(type);
  static drift.Insertable<ProfileGroupData> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? name,
    drift.Expression<DateTime>? lastUpdated,
    drift.Expression<int>? type,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (type != null) 'type': type,
    });
  }

  ProfileGroupCompanion copyWith(
      {drift.Value<int>? id,
      drift.Value<String>? name,
      drift.Value<DateTime>? lastUpdated,
      drift.Value<ProfileGroupType>? type}) {
    return ProfileGroupCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = drift.Variable<DateTime>(lastUpdated.value);
    }
    if (type.present) {
      map['type'] = drift.Variable<int>(
          $ProfileGroupTable.$convertertype.toSql(type.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $ProfileTable extends Profile
    with drift.TableInfo<$ProfileTable, ProfileData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta =
      const drift.VerificationMeta('id');
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _nameMeta =
      const drift.VerificationMeta('name');
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const drift.VerificationMeta _coreCfgMeta =
      const drift.VerificationMeta('coreCfg');
  @override
  late final drift.GeneratedColumn<String> coreCfg =
      drift.GeneratedColumn<String>('core_cfg', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const drift.Constant("{}"));
  static const drift.VerificationMeta _lastUpdatedMeta =
      const drift.VerificationMeta('lastUpdated');
  @override
  late final drift.GeneratedColumn<DateTime> lastUpdated =
      drift.GeneratedColumn<DateTime>('last_updated', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const drift.VerificationMeta _typeMeta =
      const drift.VerificationMeta('type');
  @override
  late final drift.GeneratedColumnWithTypeConverter<ProfileType, int> type =
      drift.GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProfileType>($ProfileTable.$convertertype);
  static const drift.VerificationMeta _profileGroupIdMeta =
      const drift.VerificationMeta('profileGroupId');
  @override
  late final drift.GeneratedColumn<int> profileGroupId = drift.GeneratedColumn<
          int>('profile_group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile_group (id)'),
      defaultValue: const drift.Constant(1));
  @override
  List<drift.GeneratedColumn> get $columns =>
      [id, name, coreCfg, lastUpdated, type, profileGroupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ProfileData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('core_cfg')) {
      context.handle(_coreCfgMeta,
          coreCfg.isAcceptableOrUnknown(data['core_cfg']!, _coreCfgMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    context.handle(_typeMeta, const drift.VerificationResult.success());
    if (data.containsKey('profile_group_id')) {
      context.handle(
          _profileGroupIdMeta,
          profileGroupId.isAcceptableOrUnknown(
              data['profile_group_id']!, _profileGroupIdMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      coreCfg: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}core_cfg'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      type: $ProfileTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      profileGroupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_group_id'])!,
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }

  static drift.TypeConverter<ProfileType, int> $convertertype =
      const ProfileTypeConverter();
}

class ProfileData extends drift.DataClass
    implements drift.Insertable<ProfileData> {
  final int id;
  final String name;
  final String coreCfg;
  final DateTime lastUpdated;
  final ProfileType type;
  final int profileGroupId;
  const ProfileData(
      {required this.id,
      required this.name,
      required this.coreCfg,
      required this.lastUpdated,
      required this.type,
      required this.profileGroupId});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['name'] = drift.Variable<String>(name);
    map['core_cfg'] = drift.Variable<String>(coreCfg);
    map['last_updated'] = drift.Variable<DateTime>(lastUpdated);
    {
      map['type'] =
          drift.Variable<int>($ProfileTable.$convertertype.toSql(type));
    }
    map['profile_group_id'] = drift.Variable<int>(profileGroupId);
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      coreCfg: drift.Value(coreCfg),
      lastUpdated: drift.Value(lastUpdated),
      type: drift.Value(type),
      profileGroupId: drift.Value(profileGroupId),
    );
  }

  factory ProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coreCfg: serializer.fromJson<String>(json['coreCfg']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      type: serializer.fromJson<ProfileType>(json['type']),
      profileGroupId: serializer.fromJson<int>(json['profileGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'coreCfg': serializer.toJson<String>(coreCfg),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'type': serializer.toJson<ProfileType>(type),
      'profileGroupId': serializer.toJson<int>(profileGroupId),
    };
  }

  ProfileData copyWith(
          {int? id,
          String? name,
          String? coreCfg,
          DateTime? lastUpdated,
          ProfileType? type,
          int? profileGroupId}) =>
      ProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        coreCfg: coreCfg ?? this.coreCfg,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        type: type ?? this.type,
        profileGroupId: profileGroupId ?? this.profileGroupId,
      );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coreCfg: data.coreCfg.present ? data.coreCfg.value : this.coreCfg,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      type: data.type.present ? data.type.value : this.type,
      profileGroupId: data.profileGroupId.present
          ? data.profileGroupId.value
          : this.profileGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coreCfg: $coreCfg, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('type: $type, ')
          ..write('profileGroupId: $profileGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, coreCfg, lastUpdated, type, profileGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.coreCfg == this.coreCfg &&
          other.lastUpdated == this.lastUpdated &&
          other.type == this.type &&
          other.profileGroupId == this.profileGroupId);
}

class ProfileCompanion extends drift.UpdateCompanion<ProfileData> {
  final drift.Value<int> id;
  final drift.Value<String> name;
  final drift.Value<String> coreCfg;
  final drift.Value<DateTime> lastUpdated;
  final drift.Value<ProfileType> type;
  final drift.Value<int> profileGroupId;
  const ProfileCompanion({
    this.id = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.coreCfg = const drift.Value.absent(),
    this.lastUpdated = const drift.Value.absent(),
    this.type = const drift.Value.absent(),
    this.profileGroupId = const drift.Value.absent(),
  });
  ProfileCompanion.insert({
    this.id = const drift.Value.absent(),
    required String name,
    this.coreCfg = const drift.Value.absent(),
    required DateTime lastUpdated,
    required ProfileType type,
    this.profileGroupId = const drift.Value.absent(),
  })  : name = drift.Value(name),
        lastUpdated = drift.Value(lastUpdated),
        type = drift.Value(type);
  static drift.Insertable<ProfileData> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? name,
    drift.Expression<String>? coreCfg,
    drift.Expression<DateTime>? lastUpdated,
    drift.Expression<int>? type,
    drift.Expression<int>? profileGroupId,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coreCfg != null) 'core_cfg': coreCfg,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (type != null) 'type': type,
      if (profileGroupId != null) 'profile_group_id': profileGroupId,
    });
  }

  ProfileCompanion copyWith(
      {drift.Value<int>? id,
      drift.Value<String>? name,
      drift.Value<String>? coreCfg,
      drift.Value<DateTime>? lastUpdated,
      drift.Value<ProfileType>? type,
      drift.Value<int>? profileGroupId}) {
    return ProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coreCfg: coreCfg ?? this.coreCfg,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      type: type ?? this.type,
      profileGroupId: profileGroupId ?? this.profileGroupId,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (coreCfg.present) {
      map['core_cfg'] = drift.Variable<String>(coreCfg.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = drift.Variable<DateTime>(lastUpdated.value);
    }
    if (type.present) {
      map['type'] =
          drift.Variable<int>($ProfileTable.$convertertype.toSql(type.value));
    }
    if (profileGroupId.present) {
      map['profile_group_id'] = drift.Variable<int>(profileGroupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coreCfg: $coreCfg, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('type: $type, ')
          ..write('profileGroupId: $profileGroupId')
          ..write(')'))
        .toString();
  }
}

class $ProfileLocalTable extends ProfileLocal
    with drift.TableInfo<$ProfileLocalTable, ProfileLocalData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileLocalTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _profileIdMeta =
      const drift.VerificationMeta('profileId');
  @override
  late final drift.GeneratedColumn<int> profileId = drift.GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile (id)'));
  @override
  List<drift.GeneratedColumn> get $columns => [profileId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_local';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ProfileLocalData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileLocalData(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
    );
  }

  @override
  $ProfileLocalTable createAlias(String alias) {
    return $ProfileLocalTable(attachedDatabase, alias);
  }
}

class ProfileLocalData extends drift.DataClass
    implements drift.Insertable<ProfileLocalData> {
  final int profileId;
  const ProfileLocalData({required this.profileId});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['profile_id'] = drift.Variable<int>(profileId);
    return map;
  }

  ProfileLocalCompanion toCompanion(bool nullToAbsent) {
    return ProfileLocalCompanion(
      profileId: drift.Value(profileId),
    );
  }

  factory ProfileLocalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ProfileLocalData(
      profileId: serializer.fromJson<int>(json['profileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
    };
  }

  ProfileLocalData copyWith({int? profileId}) => ProfileLocalData(
        profileId: profileId ?? this.profileId,
      );
  ProfileLocalData copyWithCompanion(ProfileLocalCompanion data) {
    return ProfileLocalData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalData(')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => profileId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileLocalData && other.profileId == this.profileId);
}

class ProfileLocalCompanion extends drift.UpdateCompanion<ProfileLocalData> {
  final drift.Value<int> profileId;
  const ProfileLocalCompanion({
    this.profileId = const drift.Value.absent(),
  });
  ProfileLocalCompanion.insert({
    this.profileId = const drift.Value.absent(),
  });
  static drift.Insertable<ProfileLocalData> custom({
    drift.Expression<int>? profileId,
  }) {
    return drift.RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
    });
  }

  ProfileLocalCompanion copyWith({drift.Value<int>? profileId}) {
    return ProfileLocalCompanion(
      profileId: profileId ?? this.profileId,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (profileId.present) {
      map['profile_id'] = drift.Variable<int>(profileId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalCompanion(')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }
}

class $ProfileRemoteTable extends ProfileRemote
    with drift.TableInfo<$ProfileRemoteTable, ProfileRemoteData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRemoteTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _profileIdMeta =
      const drift.VerificationMeta('profileId');
  @override
  late final drift.GeneratedColumn<int> profileId = drift.GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile (id)'));
  static const drift.VerificationMeta _urlMeta =
      const drift.VerificationMeta('url');
  @override
  late final drift.GeneratedColumn<String> url = drift.GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const drift.VerificationMeta _autoUpdateIntervalMeta =
      const drift.VerificationMeta('autoUpdateInterval');
  @override
  late final drift.GeneratedColumn<int> autoUpdateInterval =
      drift.GeneratedColumn<int>('auto_update_interval', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns =>
      [profileId, url, autoUpdateInterval];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_remote';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ProfileRemoteData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('auto_update_interval')) {
      context.handle(
          _autoUpdateIntervalMeta,
          autoUpdateInterval.isAcceptableOrUnknown(
              data['auto_update_interval']!, _autoUpdateIntervalMeta));
    } else if (isInserting) {
      context.missing(_autoUpdateIntervalMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileRemoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRemoteData(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      autoUpdateInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}auto_update_interval'])!,
    );
  }

  @override
  $ProfileRemoteTable createAlias(String alias) {
    return $ProfileRemoteTable(attachedDatabase, alias);
  }
}

class ProfileRemoteData extends drift.DataClass
    implements drift.Insertable<ProfileRemoteData> {
  final int profileId;
  final String url;
  final int autoUpdateInterval;
  const ProfileRemoteData(
      {required this.profileId,
      required this.url,
      required this.autoUpdateInterval});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['profile_id'] = drift.Variable<int>(profileId);
    map['url'] = drift.Variable<String>(url);
    map['auto_update_interval'] = drift.Variable<int>(autoUpdateInterval);
    return map;
  }

  ProfileRemoteCompanion toCompanion(bool nullToAbsent) {
    return ProfileRemoteCompanion(
      profileId: drift.Value(profileId),
      url: drift.Value(url),
      autoUpdateInterval: drift.Value(autoUpdateInterval),
    );
  }

  factory ProfileRemoteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ProfileRemoteData(
      profileId: serializer.fromJson<int>(json['profileId']),
      url: serializer.fromJson<String>(json['url']),
      autoUpdateInterval: serializer.fromJson<int>(json['autoUpdateInterval']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'url': serializer.toJson<String>(url),
      'autoUpdateInterval': serializer.toJson<int>(autoUpdateInterval),
    };
  }

  ProfileRemoteData copyWith(
          {int? profileId, String? url, int? autoUpdateInterval}) =>
      ProfileRemoteData(
        profileId: profileId ?? this.profileId,
        url: url ?? this.url,
        autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
      );
  ProfileRemoteData copyWithCompanion(ProfileRemoteCompanion data) {
    return ProfileRemoteData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      url: data.url.present ? data.url.value : this.url,
      autoUpdateInterval: data.autoUpdateInterval.present
          ? data.autoUpdateInterval.value
          : this.autoUpdateInterval,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRemoteData(')
          ..write('profileId: $profileId, ')
          ..write('url: $url, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, url, autoUpdateInterval);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRemoteData &&
          other.profileId == this.profileId &&
          other.url == this.url &&
          other.autoUpdateInterval == this.autoUpdateInterval);
}

class ProfileRemoteCompanion extends drift.UpdateCompanion<ProfileRemoteData> {
  final drift.Value<int> profileId;
  final drift.Value<String> url;
  final drift.Value<int> autoUpdateInterval;
  const ProfileRemoteCompanion({
    this.profileId = const drift.Value.absent(),
    this.url = const drift.Value.absent(),
    this.autoUpdateInterval = const drift.Value.absent(),
  });
  ProfileRemoteCompanion.insert({
    this.profileId = const drift.Value.absent(),
    required String url,
    required int autoUpdateInterval,
  })  : url = drift.Value(url),
        autoUpdateInterval = drift.Value(autoUpdateInterval);
  static drift.Insertable<ProfileRemoteData> custom({
    drift.Expression<int>? profileId,
    drift.Expression<String>? url,
    drift.Expression<int>? autoUpdateInterval,
  }) {
    return drift.RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (url != null) 'url': url,
      if (autoUpdateInterval != null)
        'auto_update_interval': autoUpdateInterval,
    });
  }

  ProfileRemoteCompanion copyWith(
      {drift.Value<int>? profileId,
      drift.Value<String>? url,
      drift.Value<int>? autoUpdateInterval}) {
    return ProfileRemoteCompanion(
      profileId: profileId ?? this.profileId,
      url: url ?? this.url,
      autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (profileId.present) {
      map['profile_id'] = drift.Variable<int>(profileId.value);
    }
    if (url.present) {
      map['url'] = drift.Variable<String>(url.value);
    }
    if (autoUpdateInterval.present) {
      map['auto_update_interval'] =
          drift.Variable<int>(autoUpdateInterval.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRemoteCompanion(')
          ..write('profileId: $profileId, ')
          ..write('url: $url, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }
}

class $ProfileGroupLocalTable extends ProfileGroupLocal
    with drift.TableInfo<$ProfileGroupLocalTable, ProfileGroupLocalData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileGroupLocalTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _profileGroupIdMeta =
      const drift.VerificationMeta('profileGroupId');
  @override
  late final drift.GeneratedColumn<int> profileGroupId = drift.GeneratedColumn<
          int>('profile_group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile_group (id)'));
  @override
  List<drift.GeneratedColumn> get $columns => [profileGroupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_group_local';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ProfileGroupLocalData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_group_id')) {
      context.handle(
          _profileGroupIdMeta,
          profileGroupId.isAcceptableOrUnknown(
              data['profile_group_id']!, _profileGroupIdMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {profileGroupId};
  @override
  ProfileGroupLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileGroupLocalData(
      profileGroupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_group_id'])!,
    );
  }

  @override
  $ProfileGroupLocalTable createAlias(String alias) {
    return $ProfileGroupLocalTable(attachedDatabase, alias);
  }
}

class ProfileGroupLocalData extends drift.DataClass
    implements drift.Insertable<ProfileGroupLocalData> {
  final int profileGroupId;
  const ProfileGroupLocalData({required this.profileGroupId});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['profile_group_id'] = drift.Variable<int>(profileGroupId);
    return map;
  }

  ProfileGroupLocalCompanion toCompanion(bool nullToAbsent) {
    return ProfileGroupLocalCompanion(
      profileGroupId: drift.Value(profileGroupId),
    );
  }

  factory ProfileGroupLocalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ProfileGroupLocalData(
      profileGroupId: serializer.fromJson<int>(json['profileGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileGroupId': serializer.toJson<int>(profileGroupId),
    };
  }

  ProfileGroupLocalData copyWith({int? profileGroupId}) =>
      ProfileGroupLocalData(
        profileGroupId: profileGroupId ?? this.profileGroupId,
      );
  ProfileGroupLocalData copyWithCompanion(ProfileGroupLocalCompanion data) {
    return ProfileGroupLocalData(
      profileGroupId: data.profileGroupId.present
          ? data.profileGroupId.value
          : this.profileGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupLocalData(')
          ..write('profileGroupId: $profileGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => profileGroupId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileGroupLocalData &&
          other.profileGroupId == this.profileGroupId);
}

class ProfileGroupLocalCompanion
    extends drift.UpdateCompanion<ProfileGroupLocalData> {
  final drift.Value<int> profileGroupId;
  const ProfileGroupLocalCompanion({
    this.profileGroupId = const drift.Value.absent(),
  });
  ProfileGroupLocalCompanion.insert({
    this.profileGroupId = const drift.Value.absent(),
  });
  static drift.Insertable<ProfileGroupLocalData> custom({
    drift.Expression<int>? profileGroupId,
  }) {
    return drift.RawValuesInsertable({
      if (profileGroupId != null) 'profile_group_id': profileGroupId,
    });
  }

  ProfileGroupLocalCompanion copyWith({drift.Value<int>? profileGroupId}) {
    return ProfileGroupLocalCompanion(
      profileGroupId: profileGroupId ?? this.profileGroupId,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (profileGroupId.present) {
      map['profile_group_id'] = drift.Variable<int>(profileGroupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupLocalCompanion(')
          ..write('profileGroupId: $profileGroupId')
          ..write(')'))
        .toString();
  }
}

class $ProfileGroupRemoteTable extends ProfileGroupRemote
    with drift.TableInfo<$ProfileGroupRemoteTable, ProfileGroupRemoteData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileGroupRemoteTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _profileGroupIdMeta =
      const drift.VerificationMeta('profileGroupId');
  @override
  late final drift.GeneratedColumn<int> profileGroupId = drift.GeneratedColumn<
          int>('profile_group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile_group (id)'));
  static const drift.VerificationMeta _urlMeta =
      const drift.VerificationMeta('url');
  @override
  late final drift.GeneratedColumn<String> url = drift.GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const drift.VerificationMeta _formatMeta =
      const drift.VerificationMeta('format');
  @override
  late final drift
      .GeneratedColumnWithTypeConverter<ProfileGroupRemoteFormat, int> format =
      drift.GeneratedColumn<int>('format', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProfileGroupRemoteFormat>(
              $ProfileGroupRemoteTable.$converterformat);
  static const drift.VerificationMeta _autoUpdateIntervalMeta =
      const drift.VerificationMeta('autoUpdateInterval');
  @override
  late final drift.GeneratedColumn<int> autoUpdateInterval =
      drift.GeneratedColumn<int>('auto_update_interval', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<drift.GeneratedColumn> get $columns =>
      [profileGroupId, url, format, autoUpdateInterval];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_group_remote';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<ProfileGroupRemoteData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_group_id')) {
      context.handle(
          _profileGroupIdMeta,
          profileGroupId.isAcceptableOrUnknown(
              data['profile_group_id']!, _profileGroupIdMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    context.handle(_formatMeta, const drift.VerificationResult.success());
    if (data.containsKey('auto_update_interval')) {
      context.handle(
          _autoUpdateIntervalMeta,
          autoUpdateInterval.isAcceptableOrUnknown(
              data['auto_update_interval']!, _autoUpdateIntervalMeta));
    } else if (isInserting) {
      context.missing(_autoUpdateIntervalMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {profileGroupId};
  @override
  ProfileGroupRemoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileGroupRemoteData(
      profileGroupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_group_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      format: $ProfileGroupRemoteTable.$converterformat.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}format'])!),
      autoUpdateInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}auto_update_interval'])!,
    );
  }

  @override
  $ProfileGroupRemoteTable createAlias(String alias) {
    return $ProfileGroupRemoteTable(attachedDatabase, alias);
  }

  static drift.TypeConverter<ProfileGroupRemoteFormat, int> $converterformat =
      const ProfileGroupFormatConverter();
}

class ProfileGroupRemoteData extends drift.DataClass
    implements drift.Insertable<ProfileGroupRemoteData> {
  final int profileGroupId;
  final String url;
  final ProfileGroupRemoteFormat format;
  final int autoUpdateInterval;
  const ProfileGroupRemoteData(
      {required this.profileGroupId,
      required this.url,
      required this.format,
      required this.autoUpdateInterval});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['profile_group_id'] = drift.Variable<int>(profileGroupId);
    map['url'] = drift.Variable<String>(url);
    {
      map['format'] = drift.Variable<int>(
          $ProfileGroupRemoteTable.$converterformat.toSql(format));
    }
    map['auto_update_interval'] = drift.Variable<int>(autoUpdateInterval);
    return map;
  }

  ProfileGroupRemoteCompanion toCompanion(bool nullToAbsent) {
    return ProfileGroupRemoteCompanion(
      profileGroupId: drift.Value(profileGroupId),
      url: drift.Value(url),
      format: drift.Value(format),
      autoUpdateInterval: drift.Value(autoUpdateInterval),
    );
  }

  factory ProfileGroupRemoteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return ProfileGroupRemoteData(
      profileGroupId: serializer.fromJson<int>(json['profileGroupId']),
      url: serializer.fromJson<String>(json['url']),
      format: serializer.fromJson<ProfileGroupRemoteFormat>(json['format']),
      autoUpdateInterval: serializer.fromJson<int>(json['autoUpdateInterval']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileGroupId': serializer.toJson<int>(profileGroupId),
      'url': serializer.toJson<String>(url),
      'format': serializer.toJson<ProfileGroupRemoteFormat>(format),
      'autoUpdateInterval': serializer.toJson<int>(autoUpdateInterval),
    };
  }

  ProfileGroupRemoteData copyWith(
          {int? profileGroupId,
          String? url,
          ProfileGroupRemoteFormat? format,
          int? autoUpdateInterval}) =>
      ProfileGroupRemoteData(
        profileGroupId: profileGroupId ?? this.profileGroupId,
        url: url ?? this.url,
        format: format ?? this.format,
        autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
      );
  ProfileGroupRemoteData copyWithCompanion(ProfileGroupRemoteCompanion data) {
    return ProfileGroupRemoteData(
      profileGroupId: data.profileGroupId.present
          ? data.profileGroupId.value
          : this.profileGroupId,
      url: data.url.present ? data.url.value : this.url,
      format: data.format.present ? data.format.value : this.format,
      autoUpdateInterval: data.autoUpdateInterval.present
          ? data.autoUpdateInterval.value
          : this.autoUpdateInterval,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupRemoteData(')
          ..write('profileGroupId: $profileGroupId, ')
          ..write('url: $url, ')
          ..write('format: $format, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileGroupId, url, format, autoUpdateInterval);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileGroupRemoteData &&
          other.profileGroupId == this.profileGroupId &&
          other.url == this.url &&
          other.format == this.format &&
          other.autoUpdateInterval == this.autoUpdateInterval);
}

class ProfileGroupRemoteCompanion
    extends drift.UpdateCompanion<ProfileGroupRemoteData> {
  final drift.Value<int> profileGroupId;
  final drift.Value<String> url;
  final drift.Value<ProfileGroupRemoteFormat> format;
  final drift.Value<int> autoUpdateInterval;
  const ProfileGroupRemoteCompanion({
    this.profileGroupId = const drift.Value.absent(),
    this.url = const drift.Value.absent(),
    this.format = const drift.Value.absent(),
    this.autoUpdateInterval = const drift.Value.absent(),
  });
  ProfileGroupRemoteCompanion.insert({
    this.profileGroupId = const drift.Value.absent(),
    required String url,
    required ProfileGroupRemoteFormat format,
    required int autoUpdateInterval,
  })  : url = drift.Value(url),
        format = drift.Value(format),
        autoUpdateInterval = drift.Value(autoUpdateInterval);
  static drift.Insertable<ProfileGroupRemoteData> custom({
    drift.Expression<int>? profileGroupId,
    drift.Expression<String>? url,
    drift.Expression<int>? format,
    drift.Expression<int>? autoUpdateInterval,
  }) {
    return drift.RawValuesInsertable({
      if (profileGroupId != null) 'profile_group_id': profileGroupId,
      if (url != null) 'url': url,
      if (format != null) 'format': format,
      if (autoUpdateInterval != null)
        'auto_update_interval': autoUpdateInterval,
    });
  }

  ProfileGroupRemoteCompanion copyWith(
      {drift.Value<int>? profileGroupId,
      drift.Value<String>? url,
      drift.Value<ProfileGroupRemoteFormat>? format,
      drift.Value<int>? autoUpdateInterval}) {
    return ProfileGroupRemoteCompanion(
      profileGroupId: profileGroupId ?? this.profileGroupId,
      url: url ?? this.url,
      format: format ?? this.format,
      autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (profileGroupId.present) {
      map['profile_group_id'] = drift.Variable<int>(profileGroupId.value);
    }
    if (url.present) {
      map['url'] = drift.Variable<String>(url.value);
    }
    if (format.present) {
      map['format'] = drift.Variable<int>(
          $ProfileGroupRemoteTable.$converterformat.toSql(format.value));
    }
    if (autoUpdateInterval.present) {
      map['auto_update_interval'] =
          drift.Variable<int>(autoUpdateInterval.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupRemoteCompanion(')
          ..write('profileGroupId: $profileGroupId, ')
          ..write('url: $url, ')
          ..write('format: $format, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends drift.GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ProfileGroupTable profileGroup = $ProfileGroupTable(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $ProfileLocalTable profileLocal = $ProfileLocalTable(this);
  late final $ProfileRemoteTable profileRemote = $ProfileRemoteTable(this);
  late final $ProfileGroupLocalTable profileGroupLocal =
      $ProfileGroupLocalTable(this);
  late final $ProfileGroupRemoteTable profileGroupRemote =
      $ProfileGroupRemoteTable(this);
  @override
  Iterable<drift.TableInfo<drift.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<drift.TableInfo<drift.Table, Object?>>();
  @override
  List<drift.DatabaseSchemaEntity> get allSchemaEntities => [
        profileGroup,
        profile,
        profileLocal,
        profileRemote,
        profileGroupLocal,
        profileGroupRemote
      ];
}

typedef $$ProfileGroupTableCreateCompanionBuilder = ProfileGroupCompanion
    Function({
  drift.Value<int> id,
  required String name,
  required DateTime lastUpdated,
  required ProfileGroupType type,
});
typedef $$ProfileGroupTableUpdateCompanionBuilder = ProfileGroupCompanion
    Function({
  drift.Value<int> id,
  drift.Value<String> name,
  drift.Value<DateTime> lastUpdated,
  drift.Value<ProfileGroupType> type,
});

final class $$ProfileGroupTableReferences extends drift
    .BaseReferences<_$Database, $ProfileGroupTable, ProfileGroupData> {
  $$ProfileGroupTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static drift.MultiTypedResultKey<$ProfileTable, List<ProfileData>>
      _profileRefsTable(_$Database db) =>
          drift.MultiTypedResultKey.fromTable(db.profile,
              aliasName: drift.$_aliasNameGenerator(
                  db.profileGroup.id, db.profile.profileGroupId));

  $$ProfileTableProcessedTableManager get profileRefs {
    final manager = $$ProfileTableTableManager($_db, $_db.profile)
        .filter((f) => f.profileGroupId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_profileRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift
      .MultiTypedResultKey<$ProfileGroupLocalTable, List<ProfileGroupLocalData>>
      _profileGroupLocalRefsTable(_$Database db) =>
          drift.MultiTypedResultKey.fromTable(db.profileGroupLocal,
              aliasName: drift.$_aliasNameGenerator(
                  db.profileGroup.id, db.profileGroupLocal.profileGroupId));

  $$ProfileGroupLocalTableProcessedTableManager get profileGroupLocalRefs {
    final manager =
        $$ProfileGroupLocalTableTableManager($_db, $_db.profileGroupLocal)
            .filter((f) => f.profileGroupId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_profileGroupLocalRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$ProfileGroupRemoteTable,
      List<ProfileGroupRemoteData>> _profileGroupRemoteRefsTable(
          _$Database db) =>
      drift.MultiTypedResultKey.fromTable(db.profileGroupRemote,
          aliasName: drift.$_aliasNameGenerator(
              db.profileGroup.id, db.profileGroupRemote.profileGroupId));

  $$ProfileGroupRemoteTableProcessedTableManager get profileGroupRemoteRefs {
    final manager =
        $$ProfileGroupRemoteTableTableManager($_db, $_db.profileGroupRemote)
            .filter((f) => f.profileGroupId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_profileGroupRemoteRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfileGroupTableFilterComposer
    extends drift.FilterComposer<_$Database, $ProfileGroupTable> {
  $$ProfileGroupTableFilterComposer(super.$state);
  drift.ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnWithTypeConverterFilters<ProfileGroupType, ProfileGroupType, int>
      get type => $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) =>
              drift.ColumnWithTypeConverterFilters(column,
                  joinBuilders: joinBuilders));

  drift.ComposableFilter profileRefs(
      drift.ComposableFilter Function($$ProfileTableFilterComposer f) f) {
    final $$ProfileTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.profile,
        getReferencedColumn: (t) => t.profileGroupId,
        builder: (joinBuilder, parentComposers) => $$ProfileTableFilterComposer(
            drift.ComposerState(
                $state.db, $state.db.profile, joinBuilder, parentComposers)));
    return f(composer);
  }

  drift.ComposableFilter profileGroupLocalRefs(
      drift.ComposableFilter Function($$ProfileGroupLocalTableFilterComposer f)
          f) {
    final $$ProfileGroupLocalTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.profileGroupLocal,
            getReferencedColumn: (t) => t.profileGroupId,
            builder: (joinBuilder, parentComposers) =>
                $$ProfileGroupLocalTableFilterComposer(drift.ComposerState(
                    $state.db,
                    $state.db.profileGroupLocal,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  drift.ComposableFilter profileGroupRemoteRefs(
      drift.ComposableFilter Function($$ProfileGroupRemoteTableFilterComposer f)
          f) {
    final $$ProfileGroupRemoteTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.profileGroupRemote,
            getReferencedColumn: (t) => t.profileGroupId,
            builder: (joinBuilder, parentComposers) =>
                $$ProfileGroupRemoteTableFilterComposer(drift.ComposerState(
                    $state.db,
                    $state.db.profileGroupRemote,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$ProfileGroupTableOrderingComposer
    extends drift.OrderingComposer<_$Database, $ProfileGroupTable> {
  $$ProfileGroupTableOrderingComposer(super.$state);
  drift.ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ProfileGroupTableTableManager extends drift.RootTableManager<
    _$Database,
    $ProfileGroupTable,
    ProfileGroupData,
    $$ProfileGroupTableFilterComposer,
    $$ProfileGroupTableOrderingComposer,
    $$ProfileGroupTableCreateCompanionBuilder,
    $$ProfileGroupTableUpdateCompanionBuilder,
    (ProfileGroupData, $$ProfileGroupTableReferences),
    ProfileGroupData,
    drift.PrefetchHooks Function(
        {bool profileRefs,
        bool profileGroupLocalRefs,
        bool profileGroupRemoteRefs})> {
  $$ProfileGroupTableTableManager(_$Database db, $ProfileGroupTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfileGroupTableFilterComposer(drift.ComposerState(db, table)),
          orderingComposer: $$ProfileGroupTableOrderingComposer(
              drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> id = const drift.Value.absent(),
            drift.Value<String> name = const drift.Value.absent(),
            drift.Value<DateTime> lastUpdated = const drift.Value.absent(),
            drift.Value<ProfileGroupType> type = const drift.Value.absent(),
          }) =>
              ProfileGroupCompanion(
            id: id,
            name: name,
            lastUpdated: lastUpdated,
            type: type,
          ),
          createCompanionCallback: ({
            drift.Value<int> id = const drift.Value.absent(),
            required String name,
            required DateTime lastUpdated,
            required ProfileGroupType type,
          }) =>
              ProfileGroupCompanion.insert(
            id: id,
            name: name,
            lastUpdated: lastUpdated,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileGroupTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {profileRefs = false,
              profileGroupLocalRefs = false,
              profileGroupRemoteRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profileRefs) db.profile,
                if (profileGroupLocalRefs) db.profileGroupLocal,
                if (profileGroupRemoteRefs) db.profileGroupRemote
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profileRefs)
                    await drift.$_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfileGroupTableReferences._profileRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileGroupTableReferences(db, table, p0)
                                .profileRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileGroupId == item.id),
                        typedResults: items),
                  if (profileGroupLocalRefs)
                    await drift.$_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfileGroupTableReferences
                            ._profileGroupLocalRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileGroupTableReferences(db, table, p0)
                                .profileGroupLocalRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileGroupId == item.id),
                        typedResults: items),
                  if (profileGroupRemoteRefs)
                    await drift.$_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfileGroupTableReferences
                            ._profileGroupRemoteRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileGroupTableReferences(db, table, p0)
                                .profileGroupRemoteRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileGroupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfileGroupTableProcessedTableManager = drift.ProcessedTableManager<
    _$Database,
    $ProfileGroupTable,
    ProfileGroupData,
    $$ProfileGroupTableFilterComposer,
    $$ProfileGroupTableOrderingComposer,
    $$ProfileGroupTableCreateCompanionBuilder,
    $$ProfileGroupTableUpdateCompanionBuilder,
    (ProfileGroupData, $$ProfileGroupTableReferences),
    ProfileGroupData,
    drift.PrefetchHooks Function(
        {bool profileRefs,
        bool profileGroupLocalRefs,
        bool profileGroupRemoteRefs})>;
typedef $$ProfileTableCreateCompanionBuilder = ProfileCompanion Function({
  drift.Value<int> id,
  required String name,
  drift.Value<String> coreCfg,
  required DateTime lastUpdated,
  required ProfileType type,
  drift.Value<int> profileGroupId,
});
typedef $$ProfileTableUpdateCompanionBuilder = ProfileCompanion Function({
  drift.Value<int> id,
  drift.Value<String> name,
  drift.Value<String> coreCfg,
  drift.Value<DateTime> lastUpdated,
  drift.Value<ProfileType> type,
  drift.Value<int> profileGroupId,
});

final class $$ProfileTableReferences
    extends drift.BaseReferences<_$Database, $ProfileTable, ProfileData> {
  $$ProfileTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfileGroupTable _profileGroupIdTable(_$Database db) =>
      db.profileGroup.createAlias(drift.$_aliasNameGenerator(
          db.profile.profileGroupId, db.profileGroup.id));

  $$ProfileGroupTableProcessedTableManager? get profileGroupId {
    if ($_item.profileGroupId == null) return null;
    final manager = $$ProfileGroupTableTableManager($_db, $_db.profileGroup)
        .filter((f) => f.id($_item.profileGroupId!));
    final item = $_typedResult.readTableOrNull(_profileGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static drift.MultiTypedResultKey<$ProfileLocalTable, List<ProfileLocalData>>
      _profileLocalRefsTable(_$Database db) =>
          drift.MultiTypedResultKey.fromTable(db.profileLocal,
              aliasName: drift.$_aliasNameGenerator(
                  db.profile.id, db.profileLocal.profileId));

  $$ProfileLocalTableProcessedTableManager get profileLocalRefs {
    final manager = $$ProfileLocalTableTableManager($_db, $_db.profileLocal)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_profileLocalRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static drift.MultiTypedResultKey<$ProfileRemoteTable, List<ProfileRemoteData>>
      _profileRemoteRefsTable(_$Database db) =>
          drift.MultiTypedResultKey.fromTable(db.profileRemote,
              aliasName: drift.$_aliasNameGenerator(
                  db.profile.id, db.profileRemote.profileId));

  $$ProfileRemoteTableProcessedTableManager get profileRemoteRefs {
    final manager = $$ProfileRemoteTableTableManager($_db, $_db.profileRemote)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_profileRemoteRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfileTableFilterComposer
    extends drift.FilterComposer<_$Database, $ProfileTable> {
  $$ProfileTableFilterComposer(super.$state);
  drift.ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<String> get coreCfg => $state.composableBuilder(
      column: $state.table.coreCfg,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnWithTypeConverterFilters<ProfileType, ProfileType, int>
      get type => $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) =>
              drift.ColumnWithTypeConverterFilters(column,
                  joinBuilders: joinBuilders));

  $$ProfileGroupTableFilterComposer get profileGroupId {
    final $$ProfileGroupTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileGroupId,
        referencedTable: $state.db.profileGroup,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileGroupTableFilterComposer(drift.ComposerState($state.db,
                $state.db.profileGroup, joinBuilder, parentComposers)));
    return composer;
  }

  drift.ComposableFilter profileLocalRefs(
      drift.ComposableFilter Function($$ProfileLocalTableFilterComposer f) f) {
    final $$ProfileLocalTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.profileLocal,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileLocalTableFilterComposer(drift.ComposerState($state.db,
                $state.db.profileLocal, joinBuilder, parentComposers)));
    return f(composer);
  }

  drift.ComposableFilter profileRemoteRefs(
      drift.ComposableFilter Function($$ProfileRemoteTableFilterComposer f) f) {
    final $$ProfileRemoteTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.profileRemote,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileRemoteTableFilterComposer(drift.ComposerState($state.db,
                $state.db.profileRemote, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ProfileTableOrderingComposer
    extends drift.OrderingComposer<_$Database, $ProfileTable> {
  $$ProfileTableOrderingComposer(super.$state);
  drift.ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<String> get coreCfg => $state.composableBuilder(
      column: $state.table.coreCfg,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProfileGroupTableOrderingComposer get profileGroupId {
    final $$ProfileGroupTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileGroupId,
        referencedTable: $state.db.profileGroup,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileGroupTableOrderingComposer(drift.ComposerState($state.db,
                $state.db.profileGroup, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileTableTableManager extends drift.RootTableManager<
    _$Database,
    $ProfileTable,
    ProfileData,
    $$ProfileTableFilterComposer,
    $$ProfileTableOrderingComposer,
    $$ProfileTableCreateCompanionBuilder,
    $$ProfileTableUpdateCompanionBuilder,
    (ProfileData, $$ProfileTableReferences),
    ProfileData,
    drift.PrefetchHooks Function(
        {bool profileGroupId, bool profileLocalRefs, bool profileRemoteRefs})> {
  $$ProfileTableTableManager(_$Database db, $ProfileTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfileTableFilterComposer(drift.ComposerState(db, table)),
          orderingComposer:
              $$ProfileTableOrderingComposer(drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> id = const drift.Value.absent(),
            drift.Value<String> name = const drift.Value.absent(),
            drift.Value<String> coreCfg = const drift.Value.absent(),
            drift.Value<DateTime> lastUpdated = const drift.Value.absent(),
            drift.Value<ProfileType> type = const drift.Value.absent(),
            drift.Value<int> profileGroupId = const drift.Value.absent(),
          }) =>
              ProfileCompanion(
            id: id,
            name: name,
            coreCfg: coreCfg,
            lastUpdated: lastUpdated,
            type: type,
            profileGroupId: profileGroupId,
          ),
          createCompanionCallback: ({
            drift.Value<int> id = const drift.Value.absent(),
            required String name,
            drift.Value<String> coreCfg = const drift.Value.absent(),
            required DateTime lastUpdated,
            required ProfileType type,
            drift.Value<int> profileGroupId = const drift.Value.absent(),
          }) =>
              ProfileCompanion.insert(
            id: id,
            name: name,
            coreCfg: coreCfg,
            lastUpdated: lastUpdated,
            type: type,
            profileGroupId: profileGroupId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfileTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profileGroupId = false,
              profileLocalRefs = false,
              profileRemoteRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profileLocalRefs) db.profileLocal,
                if (profileRemoteRefs) db.profileRemote
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileGroupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileGroupId,
                    referencedTable:
                        $$ProfileTableReferences._profileGroupIdTable(db),
                    referencedColumn:
                        $$ProfileTableReferences._profileGroupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profileLocalRefs)
                    await drift.$_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfileTableReferences._profileLocalRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileTableReferences(db, table, p0)
                                .profileLocalRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (profileRemoteRefs)
                    await drift.$_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfileTableReferences
                            ._profileRemoteRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileTableReferences(db, table, p0)
                                .profileRemoteRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfileTableProcessedTableManager = drift.ProcessedTableManager<
    _$Database,
    $ProfileTable,
    ProfileData,
    $$ProfileTableFilterComposer,
    $$ProfileTableOrderingComposer,
    $$ProfileTableCreateCompanionBuilder,
    $$ProfileTableUpdateCompanionBuilder,
    (ProfileData, $$ProfileTableReferences),
    ProfileData,
    drift.PrefetchHooks Function(
        {bool profileGroupId, bool profileLocalRefs, bool profileRemoteRefs})>;
typedef $$ProfileLocalTableCreateCompanionBuilder = ProfileLocalCompanion
    Function({
  drift.Value<int> profileId,
});
typedef $$ProfileLocalTableUpdateCompanionBuilder = ProfileLocalCompanion
    Function({
  drift.Value<int> profileId,
});

final class $$ProfileLocalTableReferences extends drift
    .BaseReferences<_$Database, $ProfileLocalTable, ProfileLocalData> {
  $$ProfileLocalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfileTable _profileIdTable(_$Database db) => db.profile.createAlias(
      drift.$_aliasNameGenerator(db.profileLocal.profileId, db.profile.id));

  $$ProfileTableProcessedTableManager? get profileId {
    if ($_item.profileId == null) return null;
    final manager = $$ProfileTableTableManager($_db, $_db.profile)
        .filter((f) => f.id($_item.profileId!));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileLocalTableFilterComposer
    extends drift.FilterComposer<_$Database, $ProfileLocalTable> {
  $$ProfileLocalTableFilterComposer(super.$state);
  $$ProfileTableFilterComposer get profileId {
    final $$ProfileTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ProfileTableFilterComposer(
            drift.ComposerState(
                $state.db, $state.db.profile, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileLocalTableOrderingComposer
    extends drift.OrderingComposer<_$Database, $ProfileLocalTable> {
  $$ProfileLocalTableOrderingComposer(super.$state);
  $$ProfileTableOrderingComposer get profileId {
    final $$ProfileTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileTableOrderingComposer(drift.ComposerState(
                $state.db, $state.db.profile, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileLocalTableTableManager extends drift.RootTableManager<
    _$Database,
    $ProfileLocalTable,
    ProfileLocalData,
    $$ProfileLocalTableFilterComposer,
    $$ProfileLocalTableOrderingComposer,
    $$ProfileLocalTableCreateCompanionBuilder,
    $$ProfileLocalTableUpdateCompanionBuilder,
    (ProfileLocalData, $$ProfileLocalTableReferences),
    ProfileLocalData,
    drift.PrefetchHooks Function({bool profileId})> {
  $$ProfileLocalTableTableManager(_$Database db, $ProfileLocalTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfileLocalTableFilterComposer(drift.ComposerState(db, table)),
          orderingComposer: $$ProfileLocalTableOrderingComposer(
              drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> profileId = const drift.Value.absent(),
          }) =>
              ProfileLocalCompanion(
            profileId: profileId,
          ),
          createCompanionCallback: ({
            drift.Value<int> profileId = const drift.Value.absent(),
          }) =>
              ProfileLocalCompanion.insert(
            profileId: profileId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileLocalTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ProfileLocalTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$ProfileLocalTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProfileLocalTableProcessedTableManager = drift.ProcessedTableManager<
    _$Database,
    $ProfileLocalTable,
    ProfileLocalData,
    $$ProfileLocalTableFilterComposer,
    $$ProfileLocalTableOrderingComposer,
    $$ProfileLocalTableCreateCompanionBuilder,
    $$ProfileLocalTableUpdateCompanionBuilder,
    (ProfileLocalData, $$ProfileLocalTableReferences),
    ProfileLocalData,
    drift.PrefetchHooks Function({bool profileId})>;
typedef $$ProfileRemoteTableCreateCompanionBuilder = ProfileRemoteCompanion
    Function({
  drift.Value<int> profileId,
  required String url,
  required int autoUpdateInterval,
});
typedef $$ProfileRemoteTableUpdateCompanionBuilder = ProfileRemoteCompanion
    Function({
  drift.Value<int> profileId,
  drift.Value<String> url,
  drift.Value<int> autoUpdateInterval,
});

final class $$ProfileRemoteTableReferences extends drift
    .BaseReferences<_$Database, $ProfileRemoteTable, ProfileRemoteData> {
  $$ProfileRemoteTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfileTable _profileIdTable(_$Database db) => db.profile.createAlias(
      drift.$_aliasNameGenerator(db.profileRemote.profileId, db.profile.id));

  $$ProfileTableProcessedTableManager? get profileId {
    if ($_item.profileId == null) return null;
    final manager = $$ProfileTableTableManager($_db, $_db.profile)
        .filter((f) => f.id($_item.profileId!));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileRemoteTableFilterComposer
    extends drift.FilterComposer<_$Database, $ProfileRemoteTable> {
  $$ProfileRemoteTableFilterComposer(super.$state);
  drift.ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<int> get autoUpdateInterval => $state.composableBuilder(
      column: $state.table.autoUpdateInterval,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  $$ProfileTableFilterComposer get profileId {
    final $$ProfileTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ProfileTableFilterComposer(
            drift.ComposerState(
                $state.db, $state.db.profile, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileRemoteTableOrderingComposer
    extends drift.OrderingComposer<_$Database, $ProfileRemoteTable> {
  $$ProfileRemoteTableOrderingComposer(super.$state);
  drift.ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<int> get autoUpdateInterval => $state.composableBuilder(
      column: $state.table.autoUpdateInterval,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProfileTableOrderingComposer get profileId {
    final $$ProfileTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileTableOrderingComposer(drift.ComposerState(
                $state.db, $state.db.profile, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileRemoteTableTableManager extends drift.RootTableManager<
    _$Database,
    $ProfileRemoteTable,
    ProfileRemoteData,
    $$ProfileRemoteTableFilterComposer,
    $$ProfileRemoteTableOrderingComposer,
    $$ProfileRemoteTableCreateCompanionBuilder,
    $$ProfileRemoteTableUpdateCompanionBuilder,
    (ProfileRemoteData, $$ProfileRemoteTableReferences),
    ProfileRemoteData,
    drift.PrefetchHooks Function({bool profileId})> {
  $$ProfileRemoteTableTableManager(_$Database db, $ProfileRemoteTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ProfileRemoteTableFilterComposer(
              drift.ComposerState(db, table)),
          orderingComposer: $$ProfileRemoteTableOrderingComposer(
              drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> profileId = const drift.Value.absent(),
            drift.Value<String> url = const drift.Value.absent(),
            drift.Value<int> autoUpdateInterval = const drift.Value.absent(),
          }) =>
              ProfileRemoteCompanion(
            profileId: profileId,
            url: url,
            autoUpdateInterval: autoUpdateInterval,
          ),
          createCompanionCallback: ({
            drift.Value<int> profileId = const drift.Value.absent(),
            required String url,
            required int autoUpdateInterval,
          }) =>
              ProfileRemoteCompanion.insert(
            profileId: profileId,
            url: url,
            autoUpdateInterval: autoUpdateInterval,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileRemoteTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ProfileRemoteTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$ProfileRemoteTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProfileRemoteTableProcessedTableManager = drift.ProcessedTableManager<
    _$Database,
    $ProfileRemoteTable,
    ProfileRemoteData,
    $$ProfileRemoteTableFilterComposer,
    $$ProfileRemoteTableOrderingComposer,
    $$ProfileRemoteTableCreateCompanionBuilder,
    $$ProfileRemoteTableUpdateCompanionBuilder,
    (ProfileRemoteData, $$ProfileRemoteTableReferences),
    ProfileRemoteData,
    drift.PrefetchHooks Function({bool profileId})>;
typedef $$ProfileGroupLocalTableCreateCompanionBuilder
    = ProfileGroupLocalCompanion Function({
  drift.Value<int> profileGroupId,
});
typedef $$ProfileGroupLocalTableUpdateCompanionBuilder
    = ProfileGroupLocalCompanion Function({
  drift.Value<int> profileGroupId,
});

final class $$ProfileGroupLocalTableReferences extends drift.BaseReferences<
    _$Database, $ProfileGroupLocalTable, ProfileGroupLocalData> {
  $$ProfileGroupLocalTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfileGroupTable _profileGroupIdTable(_$Database db) =>
      db.profileGroup.createAlias(drift.$_aliasNameGenerator(
          db.profileGroupLocal.profileGroupId, db.profileGroup.id));

  $$ProfileGroupTableProcessedTableManager? get profileGroupId {
    if ($_item.profileGroupId == null) return null;
    final manager = $$ProfileGroupTableTableManager($_db, $_db.profileGroup)
        .filter((f) => f.id($_item.profileGroupId!));
    final item = $_typedResult.readTableOrNull(_profileGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileGroupLocalTableFilterComposer
    extends drift.FilterComposer<_$Database, $ProfileGroupLocalTable> {
  $$ProfileGroupLocalTableFilterComposer(super.$state);
  $$ProfileGroupTableFilterComposer get profileGroupId {
    final $$ProfileGroupTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileGroupId,
        referencedTable: $state.db.profileGroup,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileGroupTableFilterComposer(drift.ComposerState($state.db,
                $state.db.profileGroup, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileGroupLocalTableOrderingComposer
    extends drift.OrderingComposer<_$Database, $ProfileGroupLocalTable> {
  $$ProfileGroupLocalTableOrderingComposer(super.$state);
  $$ProfileGroupTableOrderingComposer get profileGroupId {
    final $$ProfileGroupTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileGroupId,
        referencedTable: $state.db.profileGroup,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileGroupTableOrderingComposer(drift.ComposerState($state.db,
                $state.db.profileGroup, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileGroupLocalTableTableManager extends drift.RootTableManager<
    _$Database,
    $ProfileGroupLocalTable,
    ProfileGroupLocalData,
    $$ProfileGroupLocalTableFilterComposer,
    $$ProfileGroupLocalTableOrderingComposer,
    $$ProfileGroupLocalTableCreateCompanionBuilder,
    $$ProfileGroupLocalTableUpdateCompanionBuilder,
    (ProfileGroupLocalData, $$ProfileGroupLocalTableReferences),
    ProfileGroupLocalData,
    drift.PrefetchHooks Function({bool profileGroupId})> {
  $$ProfileGroupLocalTableTableManager(
      _$Database db, $ProfileGroupLocalTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ProfileGroupLocalTableFilterComposer(
              drift.ComposerState(db, table)),
          orderingComposer: $$ProfileGroupLocalTableOrderingComposer(
              drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> profileGroupId = const drift.Value.absent(),
          }) =>
              ProfileGroupLocalCompanion(
            profileGroupId: profileGroupId,
          ),
          createCompanionCallback: ({
            drift.Value<int> profileGroupId = const drift.Value.absent(),
          }) =>
              ProfileGroupLocalCompanion.insert(
            profileGroupId: profileGroupId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileGroupLocalTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileGroupId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileGroupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileGroupId,
                    referencedTable: $$ProfileGroupLocalTableReferences
                        ._profileGroupIdTable(db),
                    referencedColumn: $$ProfileGroupLocalTableReferences
                        ._profileGroupIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProfileGroupLocalTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$Database,
        $ProfileGroupLocalTable,
        ProfileGroupLocalData,
        $$ProfileGroupLocalTableFilterComposer,
        $$ProfileGroupLocalTableOrderingComposer,
        $$ProfileGroupLocalTableCreateCompanionBuilder,
        $$ProfileGroupLocalTableUpdateCompanionBuilder,
        (ProfileGroupLocalData, $$ProfileGroupLocalTableReferences),
        ProfileGroupLocalData,
        drift.PrefetchHooks Function({bool profileGroupId})>;
typedef $$ProfileGroupRemoteTableCreateCompanionBuilder
    = ProfileGroupRemoteCompanion Function({
  drift.Value<int> profileGroupId,
  required String url,
  required ProfileGroupRemoteFormat format,
  required int autoUpdateInterval,
});
typedef $$ProfileGroupRemoteTableUpdateCompanionBuilder
    = ProfileGroupRemoteCompanion Function({
  drift.Value<int> profileGroupId,
  drift.Value<String> url,
  drift.Value<ProfileGroupRemoteFormat> format,
  drift.Value<int> autoUpdateInterval,
});

final class $$ProfileGroupRemoteTableReferences extends drift.BaseReferences<
    _$Database, $ProfileGroupRemoteTable, ProfileGroupRemoteData> {
  $$ProfileGroupRemoteTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfileGroupTable _profileGroupIdTable(_$Database db) =>
      db.profileGroup.createAlias(drift.$_aliasNameGenerator(
          db.profileGroupRemote.profileGroupId, db.profileGroup.id));

  $$ProfileGroupTableProcessedTableManager? get profileGroupId {
    if ($_item.profileGroupId == null) return null;
    final manager = $$ProfileGroupTableTableManager($_db, $_db.profileGroup)
        .filter((f) => f.id($_item.profileGroupId!));
    final item = $_typedResult.readTableOrNull(_profileGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileGroupRemoteTableFilterComposer
    extends drift.FilterComposer<_$Database, $ProfileGroupRemoteTable> {
  $$ProfileGroupRemoteTableFilterComposer(super.$state);
  drift.ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnWithTypeConverterFilters<ProfileGroupRemoteFormat,
          ProfileGroupRemoteFormat, int>
      get format => $state.composableBuilder(
          column: $state.table.format,
          builder: (column, joinBuilders) =>
              drift.ColumnWithTypeConverterFilters(column,
                  joinBuilders: joinBuilders));

  drift.ColumnFilters<int> get autoUpdateInterval => $state.composableBuilder(
      column: $state.table.autoUpdateInterval,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  $$ProfileGroupTableFilterComposer get profileGroupId {
    final $$ProfileGroupTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileGroupId,
        referencedTable: $state.db.profileGroup,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileGroupTableFilterComposer(drift.ComposerState($state.db,
                $state.db.profileGroup, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileGroupRemoteTableOrderingComposer
    extends drift.OrderingComposer<_$Database, $ProfileGroupRemoteTable> {
  $$ProfileGroupRemoteTableOrderingComposer(super.$state);
  drift.ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<int> get format => $state.composableBuilder(
      column: $state.table.format,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<int> get autoUpdateInterval => $state.composableBuilder(
      column: $state.table.autoUpdateInterval,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProfileGroupTableOrderingComposer get profileGroupId {
    final $$ProfileGroupTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileGroupId,
        referencedTable: $state.db.profileGroup,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileGroupTableOrderingComposer(drift.ComposerState($state.db,
                $state.db.profileGroup, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileGroupRemoteTableTableManager extends drift.RootTableManager<
    _$Database,
    $ProfileGroupRemoteTable,
    ProfileGroupRemoteData,
    $$ProfileGroupRemoteTableFilterComposer,
    $$ProfileGroupRemoteTableOrderingComposer,
    $$ProfileGroupRemoteTableCreateCompanionBuilder,
    $$ProfileGroupRemoteTableUpdateCompanionBuilder,
    (ProfileGroupRemoteData, $$ProfileGroupRemoteTableReferences),
    ProfileGroupRemoteData,
    drift.PrefetchHooks Function({bool profileGroupId})> {
  $$ProfileGroupRemoteTableTableManager(
      _$Database db, $ProfileGroupRemoteTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ProfileGroupRemoteTableFilterComposer(
              drift.ComposerState(db, table)),
          orderingComposer: $$ProfileGroupRemoteTableOrderingComposer(
              drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> profileGroupId = const drift.Value.absent(),
            drift.Value<String> url = const drift.Value.absent(),
            drift.Value<ProfileGroupRemoteFormat> format =
                const drift.Value.absent(),
            drift.Value<int> autoUpdateInterval = const drift.Value.absent(),
          }) =>
              ProfileGroupRemoteCompanion(
            profileGroupId: profileGroupId,
            url: url,
            format: format,
            autoUpdateInterval: autoUpdateInterval,
          ),
          createCompanionCallback: ({
            drift.Value<int> profileGroupId = const drift.Value.absent(),
            required String url,
            required ProfileGroupRemoteFormat format,
            required int autoUpdateInterval,
          }) =>
              ProfileGroupRemoteCompanion.insert(
            profileGroupId: profileGroupId,
            url: url,
            format: format,
            autoUpdateInterval: autoUpdateInterval,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileGroupRemoteTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileGroupId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileGroupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileGroupId,
                    referencedTable: $$ProfileGroupRemoteTableReferences
                        ._profileGroupIdTable(db),
                    referencedColumn: $$ProfileGroupRemoteTableReferences
                        ._profileGroupIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProfileGroupRemoteTableProcessedTableManager
    = drift.ProcessedTableManager<
        _$Database,
        $ProfileGroupRemoteTable,
        ProfileGroupRemoteData,
        $$ProfileGroupRemoteTableFilterComposer,
        $$ProfileGroupRemoteTableOrderingComposer,
        $$ProfileGroupRemoteTableCreateCompanionBuilder,
        $$ProfileGroupRemoteTableUpdateCompanionBuilder,
        (ProfileGroupRemoteData, $$ProfileGroupRemoteTableReferences),
        ProfileGroupRemoteData,
        drift.PrefetchHooks Function({bool profileGroupId})>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ProfileGroupTableTableManager get profileGroup =>
      $$ProfileGroupTableTableManager(_db, _db.profileGroup);
  $$ProfileTableTableManager get profile =>
      $$ProfileTableTableManager(_db, _db.profile);
  $$ProfileLocalTableTableManager get profileLocal =>
      $$ProfileLocalTableTableManager(_db, _db.profileLocal);
  $$ProfileRemoteTableTableManager get profileRemote =>
      $$ProfileRemoteTableTableManager(_db, _db.profileRemote);
  $$ProfileGroupLocalTableTableManager get profileGroupLocal =>
      $$ProfileGroupLocalTableTableManager(_db, _db.profileGroupLocal);
  $$ProfileGroupRemoteTableTableManager get profileGroupRemote =>
      $$ProfileGroupRemoteTableTableManager(_db, _db.profileGroupRemote);
}
