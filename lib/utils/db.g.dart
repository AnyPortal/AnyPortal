// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
      'json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("{}"));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<ProfileType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProfileType>($ProfilesTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [id, name, json, lastUpdated, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
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
    if (data.containsKey('json')) {
      context.handle(
          _jsonMeta, json.isAcceptableOrUnknown(data['json']!, _jsonMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      json: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      type: $ProfilesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<ProfileType, int> $convertertype =
      const ProfileTypeConverter();
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final String json;
  final DateTime lastUpdated;
  final ProfileType type;
  const Profile(
      {required this.id,
      required this.name,
      required this.json,
      required this.lastUpdated,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['json'] = Variable<String>(json);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    {
      map['type'] = Variable<int>($ProfilesTable.$convertertype.toSql(type));
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      json: Value(json),
      lastUpdated: Value(lastUpdated),
      type: Value(type),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      json: serializer.fromJson<String>(json['json']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      type: serializer.fromJson<ProfileType>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'json': serializer.toJson<String>(json),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'type': serializer.toJson<ProfileType>(type),
    };
  }

  Profile copyWith(
          {int? id,
          String? name,
          String? json,
          DateTime? lastUpdated,
          ProfileType? type}) =>
      Profile(
        id: id ?? this.id,
        name: name ?? this.name,
        json: json ?? this.json,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        type: type ?? this.type,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      json: data.json.present ? data.json.value : this.json,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('json: $json, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, json, lastUpdated, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.json == this.json &&
          other.lastUpdated == this.lastUpdated &&
          other.type == this.type);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> json;
  final Value<DateTime> lastUpdated;
  final Value<ProfileType> type;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.json = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.type = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.json = const Value.absent(),
    required DateTime lastUpdated,
    required ProfileType type,
  })  : name = Value(name),
        lastUpdated = Value(lastUpdated),
        type = Value(type);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? json,
    Expression<DateTime>? lastUpdated,
    Expression<int>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (json != null) 'json': json,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (type != null) 'type': type,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? json,
      Value<DateTime>? lastUpdated,
      Value<ProfileType>? type}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      json: json ?? this.json,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($ProfilesTable.$convertertype.toSql(type.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('json: $json, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $ProfileLocalsTable extends ProfileLocals
    with TableInfo<$ProfileLocalsTable, ProfileLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileLocalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  @override
  List<GeneratedColumn> get $columns => [profileId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_locals';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileLocal(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
    );
  }

  @override
  $ProfileLocalsTable createAlias(String alias) {
    return $ProfileLocalsTable(attachedDatabase, alias);
  }
}

class ProfileLocal extends DataClass implements Insertable<ProfileLocal> {
  final int profileId;
  const ProfileLocal({required this.profileId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    return map;
  }

  ProfileLocalsCompanion toCompanion(bool nullToAbsent) {
    return ProfileLocalsCompanion(
      profileId: Value(profileId),
    );
  }

  factory ProfileLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileLocal(
      profileId: serializer.fromJson<int>(json['profileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
    };
  }

  ProfileLocal copyWith({int? profileId}) => ProfileLocal(
        profileId: profileId ?? this.profileId,
      );
  ProfileLocal copyWithCompanion(ProfileLocalsCompanion data) {
    return ProfileLocal(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocal(')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => profileId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileLocal && other.profileId == this.profileId);
}

class ProfileLocalsCompanion extends UpdateCompanion<ProfileLocal> {
  final Value<int> profileId;
  const ProfileLocalsCompanion({
    this.profileId = const Value.absent(),
  });
  ProfileLocalsCompanion.insert({
    this.profileId = const Value.absent(),
  });
  static Insertable<ProfileLocal> custom({
    Expression<int>? profileId,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
    });
  }

  ProfileLocalsCompanion copyWith({Value<int>? profileId}) {
    return ProfileLocalsCompanion(
      profileId: profileId ?? this.profileId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalsCompanion(')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }
}

class $ProfileRemotesTable extends ProfileRemotes
    with TableInfo<$ProfileRemotesTable, ProfileRemote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRemotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _autoUpdateIntervalMeta =
      const VerificationMeta('autoUpdateInterval');
  @override
  late final GeneratedColumn<int> autoUpdateInterval = GeneratedColumn<int>(
      'auto_update_interval', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [profileId, url, autoUpdateInterval];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_remotes';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileRemote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
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
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileRemote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRemote(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      autoUpdateInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}auto_update_interval'])!,
    );
  }

  @override
  $ProfileRemotesTable createAlias(String alias) {
    return $ProfileRemotesTable(attachedDatabase, alias);
  }
}

class ProfileRemote extends DataClass implements Insertable<ProfileRemote> {
  final int profileId;
  final String url;
  final int autoUpdateInterval;
  const ProfileRemote(
      {required this.profileId,
      required this.url,
      required this.autoUpdateInterval});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['url'] = Variable<String>(url);
    map['auto_update_interval'] = Variable<int>(autoUpdateInterval);
    return map;
  }

  ProfileRemotesCompanion toCompanion(bool nullToAbsent) {
    return ProfileRemotesCompanion(
      profileId: Value(profileId),
      url: Value(url),
      autoUpdateInterval: Value(autoUpdateInterval),
    );
  }

  factory ProfileRemote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRemote(
      profileId: serializer.fromJson<int>(json['profileId']),
      url: serializer.fromJson<String>(json['url']),
      autoUpdateInterval: serializer.fromJson<int>(json['autoUpdateInterval']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'url': serializer.toJson<String>(url),
      'autoUpdateInterval': serializer.toJson<int>(autoUpdateInterval),
    };
  }

  ProfileRemote copyWith(
          {int? profileId, String? url, int? autoUpdateInterval}) =>
      ProfileRemote(
        profileId: profileId ?? this.profileId,
        url: url ?? this.url,
        autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
      );
  ProfileRemote copyWithCompanion(ProfileRemotesCompanion data) {
    return ProfileRemote(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      url: data.url.present ? data.url.value : this.url,
      autoUpdateInterval: data.autoUpdateInterval.present
          ? data.autoUpdateInterval.value
          : this.autoUpdateInterval,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRemote(')
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
      (other is ProfileRemote &&
          other.profileId == this.profileId &&
          other.url == this.url &&
          other.autoUpdateInterval == this.autoUpdateInterval);
}

class ProfileRemotesCompanion extends UpdateCompanion<ProfileRemote> {
  final Value<int> profileId;
  final Value<String> url;
  final Value<int> autoUpdateInterval;
  const ProfileRemotesCompanion({
    this.profileId = const Value.absent(),
    this.url = const Value.absent(),
    this.autoUpdateInterval = const Value.absent(),
  });
  ProfileRemotesCompanion.insert({
    this.profileId = const Value.absent(),
    required String url,
    required int autoUpdateInterval,
  })  : url = Value(url),
        autoUpdateInterval = Value(autoUpdateInterval);
  static Insertable<ProfileRemote> custom({
    Expression<int>? profileId,
    Expression<String>? url,
    Expression<int>? autoUpdateInterval,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (url != null) 'url': url,
      if (autoUpdateInterval != null)
        'auto_update_interval': autoUpdateInterval,
    });
  }

  ProfileRemotesCompanion copyWith(
      {Value<int>? profileId,
      Value<String>? url,
      Value<int>? autoUpdateInterval}) {
    return ProfileRemotesCompanion(
      profileId: profileId ?? this.profileId,
      url: url ?? this.url,
      autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (autoUpdateInterval.present) {
      map['auto_update_interval'] = Variable<int>(autoUpdateInterval.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRemotesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('url: $url, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProfileLocalsTable profileLocals = $ProfileLocalsTable(this);
  late final $ProfileRemotesTable profileRemotes = $ProfileRemotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profiles, profileLocals, profileRemotes];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> json,
  required DateTime lastUpdated,
  required ProfileType type,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> json,
  Value<DateTime> lastUpdated,
  Value<ProfileType> type,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$Database, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileLocalsTable, List<ProfileLocal>>
      _profileLocalsRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
          db.profileLocals,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.profileLocals.profileId));

  $$ProfileLocalsTableProcessedTableManager get profileLocalsRefs {
    final manager = $$ProfileLocalsTableTableManager($_db, $_db.profileLocals)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_profileLocalsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProfileRemotesTable, List<ProfileRemote>>
      _profileRemotesRefsTable(_$Database db) =>
          MultiTypedResultKey.fromTable(db.profileRemotes,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.profileRemotes.profileId));

  $$ProfileRemotesTableProcessedTableManager get profileRemotesRefs {
    final manager = $$ProfileRemotesTableTableManager($_db, $_db.profileRemotes)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_profileRemotesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends FilterComposer<_$Database, $ProfilesTable> {
  $$ProfilesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get json => $state.composableBuilder(
      column: $state.table.json,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<ProfileType, ProfileType, int> get type =>
      $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ComposableFilter profileLocalsRefs(
      ComposableFilter Function($$ProfileLocalsTableFilterComposer f) f) {
    final $$ProfileLocalsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.profileLocals,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileLocalsTableFilterComposer(ComposerState($state.db,
                $state.db.profileLocals, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter profileRemotesRefs(
      ComposableFilter Function($$ProfileRemotesTableFilterComposer f) f) {
    final $$ProfileRemotesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.profileRemotes,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder, parentComposers) =>
            $$ProfileRemotesTableFilterComposer(ComposerState($state.db,
                $state.db.profileRemotes, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends OrderingComposer<_$Database, $ProfilesTable> {
  $$ProfilesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get json => $state.composableBuilder(
      column: $state.table.json,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$Database,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function({bool profileLocalsRefs, bool profileRemotesRefs})> {
  $$ProfilesTableTableManager(_$Database db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfilesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProfilesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> json = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<ProfileType> type = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            name: name,
            json: json,
            lastUpdated: lastUpdated,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> json = const Value.absent(),
            required DateTime lastUpdated,
            required ProfileType type,
          }) =>
              ProfilesCompanion.insert(
            id: id,
            name: name,
            json: json,
            lastUpdated: lastUpdated,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profileLocalsRefs = false, profileRemotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profileLocalsRefs) db.profileLocals,
                if (profileRemotesRefs) db.profileRemotes
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profileLocalsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._profileLocalsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .profileLocalsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (profileRemotesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._profileRemotesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .profileRemotesRefs,
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

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function({bool profileLocalsRefs, bool profileRemotesRefs})>;
typedef $$ProfileLocalsTableCreateCompanionBuilder = ProfileLocalsCompanion
    Function({
  Value<int> profileId,
});
typedef $$ProfileLocalsTableUpdateCompanionBuilder = ProfileLocalsCompanion
    Function({
  Value<int> profileId,
});

final class $$ProfileLocalsTableReferences
    extends BaseReferences<_$Database, $ProfileLocalsTable, ProfileLocal> {
  $$ProfileLocalsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.profileLocals.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    if ($_item.profileId == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId!));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileLocalsTableFilterComposer
    extends FilterComposer<_$Database, $ProfileLocalsTable> {
  $$ProfileLocalsTableFilterComposer(super.$state);
  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfilesTableFilterComposer(ComposerState(
                $state.db, $state.db.profiles, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileLocalsTableOrderingComposer
    extends OrderingComposer<_$Database, $ProfileLocalsTable> {
  $$ProfileLocalsTableOrderingComposer(super.$state);
  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfilesTableOrderingComposer(ComposerState(
                $state.db, $state.db.profiles, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileLocalsTableTableManager extends RootTableManager<
    _$Database,
    $ProfileLocalsTable,
    ProfileLocal,
    $$ProfileLocalsTableFilterComposer,
    $$ProfileLocalsTableOrderingComposer,
    $$ProfileLocalsTableCreateCompanionBuilder,
    $$ProfileLocalsTableUpdateCompanionBuilder,
    (ProfileLocal, $$ProfileLocalsTableReferences),
    ProfileLocal,
    PrefetchHooks Function({bool profileId})> {
  $$ProfileLocalsTableTableManager(_$Database db, $ProfileLocalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfileLocalsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProfileLocalsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
          }) =>
              ProfileLocalsCompanion(
            profileId: profileId,
          ),
          createCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
          }) =>
              ProfileLocalsCompanion.insert(
            profileId: profileId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileLocalsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
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
                        $$ProfileLocalsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$ProfileLocalsTableReferences._profileIdTable(db).id,
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

typedef $$ProfileLocalsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $ProfileLocalsTable,
    ProfileLocal,
    $$ProfileLocalsTableFilterComposer,
    $$ProfileLocalsTableOrderingComposer,
    $$ProfileLocalsTableCreateCompanionBuilder,
    $$ProfileLocalsTableUpdateCompanionBuilder,
    (ProfileLocal, $$ProfileLocalsTableReferences),
    ProfileLocal,
    PrefetchHooks Function({bool profileId})>;
typedef $$ProfileRemotesTableCreateCompanionBuilder = ProfileRemotesCompanion
    Function({
  Value<int> profileId,
  required String url,
  required int autoUpdateInterval,
});
typedef $$ProfileRemotesTableUpdateCompanionBuilder = ProfileRemotesCompanion
    Function({
  Value<int> profileId,
  Value<String> url,
  Value<int> autoUpdateInterval,
});

final class $$ProfileRemotesTableReferences
    extends BaseReferences<_$Database, $ProfileRemotesTable, ProfileRemote> {
  $$ProfileRemotesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$Database db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.profileRemotes.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    if ($_item.profileId == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId!));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileRemotesTableFilterComposer
    extends FilterComposer<_$Database, $ProfileRemotesTable> {
  $$ProfileRemotesTableFilterComposer(super.$state);
  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get autoUpdateInterval => $state.composableBuilder(
      column: $state.table.autoUpdateInterval,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfilesTableFilterComposer(ComposerState(
                $state.db, $state.db.profiles, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileRemotesTableOrderingComposer
    extends OrderingComposer<_$Database, $ProfileRemotesTable> {
  $$ProfileRemotesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get autoUpdateInterval => $state.composableBuilder(
      column: $state.table.autoUpdateInterval,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $state.db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProfilesTableOrderingComposer(ComposerState(
                $state.db, $state.db.profiles, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProfileRemotesTableTableManager extends RootTableManager<
    _$Database,
    $ProfileRemotesTable,
    ProfileRemote,
    $$ProfileRemotesTableFilterComposer,
    $$ProfileRemotesTableOrderingComposer,
    $$ProfileRemotesTableCreateCompanionBuilder,
    $$ProfileRemotesTableUpdateCompanionBuilder,
    (ProfileRemote, $$ProfileRemotesTableReferences),
    ProfileRemote,
    PrefetchHooks Function({bool profileId})> {
  $$ProfileRemotesTableTableManager(_$Database db, $ProfileRemotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfileRemotesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProfileRemotesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int> autoUpdateInterval = const Value.absent(),
          }) =>
              ProfileRemotesCompanion(
            profileId: profileId,
            url: url,
            autoUpdateInterval: autoUpdateInterval,
          ),
          createCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            required String url,
            required int autoUpdateInterval,
          }) =>
              ProfileRemotesCompanion.insert(
            profileId: profileId,
            url: url,
            autoUpdateInterval: autoUpdateInterval,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileRemotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
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
                        $$ProfileRemotesTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$ProfileRemotesTableReferences._profileIdTable(db).id,
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

typedef $$ProfileRemotesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $ProfileRemotesTable,
    ProfileRemote,
    $$ProfileRemotesTableFilterComposer,
    $$ProfileRemotesTableOrderingComposer,
    $$ProfileRemotesTableCreateCompanionBuilder,
    $$ProfileRemotesTableUpdateCompanionBuilder,
    (ProfileRemote, $$ProfileRemotesTableReferences),
    ProfileRemote,
    PrefetchHooks Function({bool profileId})>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ProfileLocalsTableTableManager get profileLocals =>
      $$ProfileLocalsTableTableManager(_db, _db.profileLocals);
  $$ProfileRemotesTableTableManager get profileRemotes =>
      $$ProfileRemotesTableTableManager(_db, _db.profileRemotes);
}
