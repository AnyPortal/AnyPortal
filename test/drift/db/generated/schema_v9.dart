// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Asset extends Table with TableInfo<Asset, AssetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Asset(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, path, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Asset createAlias(String alias) {
    return Asset(attachedDatabase, alias);
  }
}

class AssetData extends DataClass implements Insertable<AssetData> {
  final int id;
  final String? name;
  final int type;
  final String path;
  final DateTime updatedAt;
  const AssetData({
    required this.id,
    this.name,
    required this.type,
    required this.path,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['type'] = Variable<int>(type);
    map['path'] = Variable<String>(path);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AssetCompanion toCompanion(bool nullToAbsent) {
    return AssetCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      type: Value(type),
      path: Value(path),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssetData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      type: serializer.fromJson<int>(json['type']),
      path: serializer.fromJson<String>(json['path']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'type': serializer.toJson<int>(type),
      'path': serializer.toJson<String>(path),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssetData copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    int? type,
    String? path,
    DateTime? updatedAt,
  }) => AssetData(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    type: type ?? this.type,
    path: path ?? this.path,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssetData copyWithCompanion(AssetCompanion data) {
    return AssetData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      path: data.path.present ? data.path.value : this.path,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('path: $path, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, path, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.path == this.path &&
          other.updatedAt == this.updatedAt);
}

class AssetCompanion extends UpdateCompanion<AssetData> {
  final Value<int> id;
  final Value<String?> name;
  final Value<int> type;
  final Value<String> path;
  final Value<DateTime> updatedAt;
  const AssetCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.path = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AssetCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required int type,
    required String path,
    required DateTime updatedAt,
  }) : type = Value(type),
       path = Value(path),
       updatedAt = Value(updatedAt);
  static Insertable<AssetData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? path,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (path != null) 'path': path,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AssetCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<int>? type,
    Value<String>? path,
    Value<DateTime>? updatedAt,
  }) {
    return AssetCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      path: path ?? this.path,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('path: $path, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class AssetLocal extends Table with TableInfo<AssetLocal, AssetLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AssetLocal(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [assetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_local';
  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  AssetLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetLocalData(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
    );
  }

  @override
  AssetLocal createAlias(String alias) {
    return AssetLocal(attachedDatabase, alias);
  }
}

class AssetLocalData extends DataClass implements Insertable<AssetLocalData> {
  final int assetId;
  const AssetLocalData({required this.assetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<int>(assetId);
    return map;
  }

  AssetLocalCompanion toCompanion(bool nullToAbsent) {
    return AssetLocalCompanion(assetId: Value(assetId));
  }

  factory AssetLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetLocalData(assetId: serializer.fromJson<int>(json['assetId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'assetId': serializer.toJson<int>(assetId)};
  }

  AssetLocalData copyWith({int? assetId}) =>
      AssetLocalData(assetId: assetId ?? this.assetId);
  AssetLocalData copyWithCompanion(AssetLocalCompanion data) {
    return AssetLocalData(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetLocalData(')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => assetId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetLocalData && other.assetId == this.assetId);
}

class AssetLocalCompanion extends UpdateCompanion<AssetLocalData> {
  final Value<int> assetId;
  const AssetLocalCompanion({this.assetId = const Value.absent()});
  AssetLocalCompanion.insert({this.assetId = const Value.absent()});
  static Insertable<AssetLocalData> custom({Expression<int>? assetId}) {
    return RawValuesInsertable({if (assetId != null) 'asset_id': assetId});
  }

  AssetLocalCompanion copyWith({Value<int>? assetId}) {
    return AssetLocalCompanion(assetId: assetId ?? this.assetId);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetLocalCompanion(')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }
}

class AssetRemote extends Table with TableInfo<AssetRemote, AssetRemoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AssetRemote(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'{}\''),
  );
  late final GeneratedColumn<int> autoUpdateInterval = GeneratedColumn<int>(
    'auto_update_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> downloadedFilePath =
      GeneratedColumn<String>(
        'downloaded_file_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    assetId,
    url,
    meta,
    autoUpdateInterval,
    downloadedFilePath,
    checkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_remote';
  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  AssetRemoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRemoteData(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      meta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta'],
      )!,
      autoUpdateInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_interval'],
      )!,
      downloadedFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}downloaded_file_path'],
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      ),
    );
  }

  @override
  AssetRemote createAlias(String alias) {
    return AssetRemote(attachedDatabase, alias);
  }
}

class AssetRemoteData extends DataClass implements Insertable<AssetRemoteData> {
  final int assetId;
  final String url;
  final String meta;
  final int autoUpdateInterval;
  final String? downloadedFilePath;
  final DateTime? checkedAt;
  const AssetRemoteData({
    required this.assetId,
    required this.url,
    required this.meta,
    required this.autoUpdateInterval,
    this.downloadedFilePath,
    this.checkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<int>(assetId);
    map['url'] = Variable<String>(url);
    map['meta'] = Variable<String>(meta);
    map['auto_update_interval'] = Variable<int>(autoUpdateInterval);
    if (!nullToAbsent || downloadedFilePath != null) {
      map['downloaded_file_path'] = Variable<String>(downloadedFilePath);
    }
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<DateTime>(checkedAt);
    }
    return map;
  }

  AssetRemoteCompanion toCompanion(bool nullToAbsent) {
    return AssetRemoteCompanion(
      assetId: Value(assetId),
      url: Value(url),
      meta: Value(meta),
      autoUpdateInterval: Value(autoUpdateInterval),
      downloadedFilePath: downloadedFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedFilePath),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
    );
  }

  factory AssetRemoteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRemoteData(
      assetId: serializer.fromJson<int>(json['assetId']),
      url: serializer.fromJson<String>(json['url']),
      meta: serializer.fromJson<String>(json['meta']),
      autoUpdateInterval: serializer.fromJson<int>(json['autoUpdateInterval']),
      downloadedFilePath: serializer.fromJson<String?>(
        json['downloadedFilePath'],
      ),
      checkedAt: serializer.fromJson<DateTime?>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<int>(assetId),
      'url': serializer.toJson<String>(url),
      'meta': serializer.toJson<String>(meta),
      'autoUpdateInterval': serializer.toJson<int>(autoUpdateInterval),
      'downloadedFilePath': serializer.toJson<String?>(downloadedFilePath),
      'checkedAt': serializer.toJson<DateTime?>(checkedAt),
    };
  }

  AssetRemoteData copyWith({
    int? assetId,
    String? url,
    String? meta,
    int? autoUpdateInterval,
    Value<String?> downloadedFilePath = const Value.absent(),
    Value<DateTime?> checkedAt = const Value.absent(),
  }) => AssetRemoteData(
    assetId: assetId ?? this.assetId,
    url: url ?? this.url,
    meta: meta ?? this.meta,
    autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
    downloadedFilePath: downloadedFilePath.present
        ? downloadedFilePath.value
        : this.downloadedFilePath,
    checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
  );
  AssetRemoteData copyWithCompanion(AssetRemoteCompanion data) {
    return AssetRemoteData(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      url: data.url.present ? data.url.value : this.url,
      meta: data.meta.present ? data.meta.value : this.meta,
      autoUpdateInterval: data.autoUpdateInterval.present
          ? data.autoUpdateInterval.value
          : this.autoUpdateInterval,
      downloadedFilePath: data.downloadedFilePath.present
          ? data.downloadedFilePath.value
          : this.downloadedFilePath,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRemoteData(')
          ..write('assetId: $assetId, ')
          ..write('url: $url, ')
          ..write('meta: $meta, ')
          ..write('autoUpdateInterval: $autoUpdateInterval, ')
          ..write('downloadedFilePath: $downloadedFilePath, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assetId,
    url,
    meta,
    autoUpdateInterval,
    downloadedFilePath,
    checkedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRemoteData &&
          other.assetId == this.assetId &&
          other.url == this.url &&
          other.meta == this.meta &&
          other.autoUpdateInterval == this.autoUpdateInterval &&
          other.downloadedFilePath == this.downloadedFilePath &&
          other.checkedAt == this.checkedAt);
}

class AssetRemoteCompanion extends UpdateCompanion<AssetRemoteData> {
  final Value<int> assetId;
  final Value<String> url;
  final Value<String> meta;
  final Value<int> autoUpdateInterval;
  final Value<String?> downloadedFilePath;
  final Value<DateTime?> checkedAt;
  const AssetRemoteCompanion({
    this.assetId = const Value.absent(),
    this.url = const Value.absent(),
    this.meta = const Value.absent(),
    this.autoUpdateInterval = const Value.absent(),
    this.downloadedFilePath = const Value.absent(),
    this.checkedAt = const Value.absent(),
  });
  AssetRemoteCompanion.insert({
    this.assetId = const Value.absent(),
    required String url,
    this.meta = const Value.absent(),
    required int autoUpdateInterval,
    this.downloadedFilePath = const Value.absent(),
    this.checkedAt = const Value.absent(),
  }) : url = Value(url),
       autoUpdateInterval = Value(autoUpdateInterval);
  static Insertable<AssetRemoteData> custom({
    Expression<int>? assetId,
    Expression<String>? url,
    Expression<String>? meta,
    Expression<int>? autoUpdateInterval,
    Expression<String>? downloadedFilePath,
    Expression<DateTime>? checkedAt,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (url != null) 'url': url,
      if (meta != null) 'meta': meta,
      if (autoUpdateInterval != null)
        'auto_update_interval': autoUpdateInterval,
      if (downloadedFilePath != null)
        'downloaded_file_path': downloadedFilePath,
      if (checkedAt != null) 'checked_at': checkedAt,
    });
  }

  AssetRemoteCompanion copyWith({
    Value<int>? assetId,
    Value<String>? url,
    Value<String>? meta,
    Value<int>? autoUpdateInterval,
    Value<String?>? downloadedFilePath,
    Value<DateTime?>? checkedAt,
  }) {
    return AssetRemoteCompanion(
      assetId: assetId ?? this.assetId,
      url: url ?? this.url,
      meta: meta ?? this.meta,
      autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    if (autoUpdateInterval.present) {
      map['auto_update_interval'] = Variable<int>(autoUpdateInterval.value);
    }
    if (downloadedFilePath.present) {
      map['downloaded_file_path'] = Variable<String>(downloadedFilePath.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetRemoteCompanion(')
          ..write('assetId: $assetId, ')
          ..write('url: $url, ')
          ..write('meta: $meta, ')
          ..write('autoUpdateInterval: $autoUpdateInterval, ')
          ..write('downloadedFilePath: $downloadedFilePath, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }
}

class CoreType extends Table with TableInfo<CoreType, CoreTypeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CoreType(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_type';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoreTypeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreTypeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  CoreType createAlias(String alias) {
    return CoreType(attachedDatabase, alias);
  }
}

class CoreTypeData extends DataClass implements Insertable<CoreTypeData> {
  final int id;
  final String name;
  const CoreTypeData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CoreTypeCompanion toCompanion(bool nullToAbsent) {
    return CoreTypeCompanion(id: Value(id), name: Value(name));
  }

  factory CoreTypeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreTypeData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CoreTypeData copyWith({int? id, String? name}) =>
      CoreTypeData(id: id ?? this.id, name: name ?? this.name);
  CoreTypeData copyWithCompanion(CoreTypeCompanion data) {
    return CoreTypeData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreTypeData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreTypeData && other.id == this.id && other.name == this.name);
}

class CoreTypeCompanion extends UpdateCompanion<CoreTypeData> {
  final Value<int> id;
  final Value<String> name;
  const CoreTypeCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CoreTypeCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CoreTypeData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CoreTypeCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CoreTypeCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreTypeCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class Core extends Table with TableInfo<Core, CoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Core(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<int> coreTypeId = GeneratedColumn<int>(
    'core_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_type (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<bool> isExec = GeneratedColumn<bool>(
    'is_exec',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_exec" IN (0, 1))',
    ),
    defaultValue: const CustomExpression('1'),
  );
  late final GeneratedColumn<String> workingDir = GeneratedColumn<String>(
    'working_dir',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> envs = GeneratedColumn<String>(
    'envs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'{}\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    coreTypeId,
    version,
    updatedAt,
    isExec,
    workingDir,
    envs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      coreTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_type_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isExec: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_exec'],
      )!,
      workingDir: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_dir'],
      ),
      envs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}envs'],
      )!,
    );
  }

  @override
  Core createAlias(String alias) {
    return Core(attachedDatabase, alias);
  }
}

class CoreData extends DataClass implements Insertable<CoreData> {
  final int id;
  final int coreTypeId;
  final String? version;
  final DateTime updatedAt;
  final bool isExec;
  final String? workingDir;
  final String envs;
  const CoreData({
    required this.id,
    required this.coreTypeId,
    this.version,
    required this.updatedAt,
    required this.isExec,
    this.workingDir,
    required this.envs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['core_type_id'] = Variable<int>(coreTypeId);
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_exec'] = Variable<bool>(isExec);
    if (!nullToAbsent || workingDir != null) {
      map['working_dir'] = Variable<String>(workingDir);
    }
    map['envs'] = Variable<String>(envs);
    return map;
  }

  CoreCompanion toCompanion(bool nullToAbsent) {
    return CoreCompanion(
      id: Value(id),
      coreTypeId: Value(coreTypeId),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      updatedAt: Value(updatedAt),
      isExec: Value(isExec),
      workingDir: workingDir == null && nullToAbsent
          ? const Value.absent()
          : Value(workingDir),
      envs: Value(envs),
    );
  }

  factory CoreData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreData(
      id: serializer.fromJson<int>(json['id']),
      coreTypeId: serializer.fromJson<int>(json['coreTypeId']),
      version: serializer.fromJson<String?>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isExec: serializer.fromJson<bool>(json['isExec']),
      workingDir: serializer.fromJson<String?>(json['workingDir']),
      envs: serializer.fromJson<String>(json['envs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'coreTypeId': serializer.toJson<int>(coreTypeId),
      'version': serializer.toJson<String?>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isExec': serializer.toJson<bool>(isExec),
      'workingDir': serializer.toJson<String?>(workingDir),
      'envs': serializer.toJson<String>(envs),
    };
  }

  CoreData copyWith({
    int? id,
    int? coreTypeId,
    Value<String?> version = const Value.absent(),
    DateTime? updatedAt,
    bool? isExec,
    Value<String?> workingDir = const Value.absent(),
    String? envs,
  }) => CoreData(
    id: id ?? this.id,
    coreTypeId: coreTypeId ?? this.coreTypeId,
    version: version.present ? version.value : this.version,
    updatedAt: updatedAt ?? this.updatedAt,
    isExec: isExec ?? this.isExec,
    workingDir: workingDir.present ? workingDir.value : this.workingDir,
    envs: envs ?? this.envs,
  );
  CoreData copyWithCompanion(CoreCompanion data) {
    return CoreData(
      id: data.id.present ? data.id.value : this.id,
      coreTypeId: data.coreTypeId.present
          ? data.coreTypeId.value
          : this.coreTypeId,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isExec: data.isExec.present ? data.isExec.value : this.isExec,
      workingDir: data.workingDir.present
          ? data.workingDir.value
          : this.workingDir,
      envs: data.envs.present ? data.envs.value : this.envs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreData(')
          ..write('id: $id, ')
          ..write('coreTypeId: $coreTypeId, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isExec: $isExec, ')
          ..write('workingDir: $workingDir, ')
          ..write('envs: $envs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, coreTypeId, version, updatedAt, isExec, workingDir, envs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreData &&
          other.id == this.id &&
          other.coreTypeId == this.coreTypeId &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.isExec == this.isExec &&
          other.workingDir == this.workingDir &&
          other.envs == this.envs);
}

class CoreCompanion extends UpdateCompanion<CoreData> {
  final Value<int> id;
  final Value<int> coreTypeId;
  final Value<String?> version;
  final Value<DateTime> updatedAt;
  final Value<bool> isExec;
  final Value<String?> workingDir;
  final Value<String> envs;
  const CoreCompanion({
    this.id = const Value.absent(),
    this.coreTypeId = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isExec = const Value.absent(),
    this.workingDir = const Value.absent(),
    this.envs = const Value.absent(),
  });
  CoreCompanion.insert({
    this.id = const Value.absent(),
    required int coreTypeId,
    this.version = const Value.absent(),
    required DateTime updatedAt,
    this.isExec = const Value.absent(),
    this.workingDir = const Value.absent(),
    this.envs = const Value.absent(),
  }) : coreTypeId = Value(coreTypeId),
       updatedAt = Value(updatedAt);
  static Insertable<CoreData> custom({
    Expression<int>? id,
    Expression<int>? coreTypeId,
    Expression<String>? version,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isExec,
    Expression<String>? workingDir,
    Expression<String>? envs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (coreTypeId != null) 'core_type_id': coreTypeId,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isExec != null) 'is_exec': isExec,
      if (workingDir != null) 'working_dir': workingDir,
      if (envs != null) 'envs': envs,
    });
  }

  CoreCompanion copyWith({
    Value<int>? id,
    Value<int>? coreTypeId,
    Value<String?>? version,
    Value<DateTime>? updatedAt,
    Value<bool>? isExec,
    Value<String?>? workingDir,
    Value<String>? envs,
  }) {
    return CoreCompanion(
      id: id ?? this.id,
      coreTypeId: coreTypeId ?? this.coreTypeId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      isExec: isExec ?? this.isExec,
      workingDir: workingDir ?? this.workingDir,
      envs: envs ?? this.envs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (coreTypeId.present) {
      map['core_type_id'] = Variable<int>(coreTypeId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isExec.present) {
      map['is_exec'] = Variable<bool>(isExec.value);
    }
    if (workingDir.present) {
      map['working_dir'] = Variable<String>(workingDir.value);
    }
    if (envs.present) {
      map['envs'] = Variable<String>(envs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreCompanion(')
          ..write('id: $id, ')
          ..write('coreTypeId: $coreTypeId, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isExec: $isExec, ')
          ..write('workingDir: $workingDir, ')
          ..write('envs: $envs')
          ..write(')'))
        .toString();
  }
}

class CoreExec extends Table with TableInfo<CoreExec, CoreExecData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CoreExec(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> coreId = GeneratedColumn<int>(
    'core_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<String> args = GeneratedColumn<String>(
    'args',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'\''),
  );
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [coreId, args, assetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_exec';
  @override
  Set<GeneratedColumn> get $primaryKey => {coreId};
  @override
  CoreExecData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreExecData(
      coreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_id'],
      )!,
      args: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}args'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
    );
  }

  @override
  CoreExec createAlias(String alias) {
    return CoreExec(attachedDatabase, alias);
  }
}

class CoreExecData extends DataClass implements Insertable<CoreExecData> {
  final int coreId;
  final String args;
  final int assetId;
  const CoreExecData({
    required this.coreId,
    required this.args,
    required this.assetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['core_id'] = Variable<int>(coreId);
    map['args'] = Variable<String>(args);
    map['asset_id'] = Variable<int>(assetId);
    return map;
  }

  CoreExecCompanion toCompanion(bool nullToAbsent) {
    return CoreExecCompanion(
      coreId: Value(coreId),
      args: Value(args),
      assetId: Value(assetId),
    );
  }

  factory CoreExecData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreExecData(
      coreId: serializer.fromJson<int>(json['coreId']),
      args: serializer.fromJson<String>(json['args']),
      assetId: serializer.fromJson<int>(json['assetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coreId': serializer.toJson<int>(coreId),
      'args': serializer.toJson<String>(args),
      'assetId': serializer.toJson<int>(assetId),
    };
  }

  CoreExecData copyWith({int? coreId, String? args, int? assetId}) =>
      CoreExecData(
        coreId: coreId ?? this.coreId,
        args: args ?? this.args,
        assetId: assetId ?? this.assetId,
      );
  CoreExecData copyWithCompanion(CoreExecCompanion data) {
    return CoreExecData(
      coreId: data.coreId.present ? data.coreId.value : this.coreId,
      args: data.args.present ? data.args.value : this.args,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreExecData(')
          ..write('coreId: $coreId, ')
          ..write('args: $args, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(coreId, args, assetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreExecData &&
          other.coreId == this.coreId &&
          other.args == this.args &&
          other.assetId == this.assetId);
}

class CoreExecCompanion extends UpdateCompanion<CoreExecData> {
  final Value<int> coreId;
  final Value<String> args;
  final Value<int> assetId;
  const CoreExecCompanion({
    this.coreId = const Value.absent(),
    this.args = const Value.absent(),
    this.assetId = const Value.absent(),
  });
  CoreExecCompanion.insert({
    this.coreId = const Value.absent(),
    this.args = const Value.absent(),
    required int assetId,
  }) : assetId = Value(assetId);
  static Insertable<CoreExecData> custom({
    Expression<int>? coreId,
    Expression<String>? args,
    Expression<int>? assetId,
  }) {
    return RawValuesInsertable({
      if (coreId != null) 'core_id': coreId,
      if (args != null) 'args': args,
      if (assetId != null) 'asset_id': assetId,
    });
  }

  CoreExecCompanion copyWith({
    Value<int>? coreId,
    Value<String>? args,
    Value<int>? assetId,
  }) {
    return CoreExecCompanion(
      coreId: coreId ?? this.coreId,
      args: args ?? this.args,
      assetId: assetId ?? this.assetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coreId.present) {
      map['core_id'] = Variable<int>(coreId.value);
    }
    if (args.present) {
      map['args'] = Variable<String>(args.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreExecCompanion(')
          ..write('coreId: $coreId, ')
          ..write('args: $args, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }
}

class CoreLib extends Table with TableInfo<CoreLib, CoreLibData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CoreLib(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> coreId = GeneratedColumn<int>(
    'core_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [coreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_lib';
  @override
  Set<GeneratedColumn> get $primaryKey => {coreId};
  @override
  CoreLibData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreLibData(
      coreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_id'],
      )!,
    );
  }

  @override
  CoreLib createAlias(String alias) {
    return CoreLib(attachedDatabase, alias);
  }
}

class CoreLibData extends DataClass implements Insertable<CoreLibData> {
  final int coreId;
  const CoreLibData({required this.coreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['core_id'] = Variable<int>(coreId);
    return map;
  }

  CoreLibCompanion toCompanion(bool nullToAbsent) {
    return CoreLibCompanion(coreId: Value(coreId));
  }

  factory CoreLibData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreLibData(coreId: serializer.fromJson<int>(json['coreId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'coreId': serializer.toJson<int>(coreId)};
  }

  CoreLibData copyWith({int? coreId}) =>
      CoreLibData(coreId: coreId ?? this.coreId);
  CoreLibData copyWithCompanion(CoreLibCompanion data) {
    return CoreLibData(
      coreId: data.coreId.present ? data.coreId.value : this.coreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreLibData(')
          ..write('coreId: $coreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => coreId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreLibData && other.coreId == this.coreId);
}

class CoreLibCompanion extends UpdateCompanion<CoreLibData> {
  final Value<int> coreId;
  const CoreLibCompanion({this.coreId = const Value.absent()});
  CoreLibCompanion.insert({this.coreId = const Value.absent()});
  static Insertable<CoreLibData> custom({Expression<int>? coreId}) {
    return RawValuesInsertable({if (coreId != null) 'core_id': coreId});
  }

  CoreLibCompanion copyWith({Value<int>? coreId}) {
    return CoreLibCompanion(coreId: coreId ?? this.coreId);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coreId.present) {
      map['core_id'] = Variable<int>(coreId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreLibCompanion(')
          ..write('coreId: $coreId')
          ..write(')'))
        .toString();
  }
}

class CoreTypeSelected extends Table
    with TableInfo<CoreTypeSelected, CoreTypeSelectedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CoreTypeSelected(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> coreTypeId = GeneratedColumn<int>(
    'core_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_type (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<int> coreId = GeneratedColumn<int>(
    'core_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [coreTypeId, coreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_type_selected';
  @override
  Set<GeneratedColumn> get $primaryKey => {coreTypeId};
  @override
  CoreTypeSelectedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoreTypeSelectedData(
      coreTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_type_id'],
      )!,
      coreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_id'],
      )!,
    );
  }

  @override
  CoreTypeSelected createAlias(String alias) {
    return CoreTypeSelected(attachedDatabase, alias);
  }
}

class CoreTypeSelectedData extends DataClass
    implements Insertable<CoreTypeSelectedData> {
  final int coreTypeId;
  final int coreId;
  const CoreTypeSelectedData({required this.coreTypeId, required this.coreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['core_type_id'] = Variable<int>(coreTypeId);
    map['core_id'] = Variable<int>(coreId);
    return map;
  }

  CoreTypeSelectedCompanion toCompanion(bool nullToAbsent) {
    return CoreTypeSelectedCompanion(
      coreTypeId: Value(coreTypeId),
      coreId: Value(coreId),
    );
  }

  factory CoreTypeSelectedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoreTypeSelectedData(
      coreTypeId: serializer.fromJson<int>(json['coreTypeId']),
      coreId: serializer.fromJson<int>(json['coreId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coreTypeId': serializer.toJson<int>(coreTypeId),
      'coreId': serializer.toJson<int>(coreId),
    };
  }

  CoreTypeSelectedData copyWith({int? coreTypeId, int? coreId}) =>
      CoreTypeSelectedData(
        coreTypeId: coreTypeId ?? this.coreTypeId,
        coreId: coreId ?? this.coreId,
      );
  CoreTypeSelectedData copyWithCompanion(CoreTypeSelectedCompanion data) {
    return CoreTypeSelectedData(
      coreTypeId: data.coreTypeId.present
          ? data.coreTypeId.value
          : this.coreTypeId,
      coreId: data.coreId.present ? data.coreId.value : this.coreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoreTypeSelectedData(')
          ..write('coreTypeId: $coreTypeId, ')
          ..write('coreId: $coreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(coreTypeId, coreId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreTypeSelectedData &&
          other.coreTypeId == this.coreTypeId &&
          other.coreId == this.coreId);
}

class CoreTypeSelectedCompanion extends UpdateCompanion<CoreTypeSelectedData> {
  final Value<int> coreTypeId;
  final Value<int> coreId;
  const CoreTypeSelectedCompanion({
    this.coreTypeId = const Value.absent(),
    this.coreId = const Value.absent(),
  });
  CoreTypeSelectedCompanion.insert({
    this.coreTypeId = const Value.absent(),
    required int coreId,
  }) : coreId = Value(coreId);
  static Insertable<CoreTypeSelectedData> custom({
    Expression<int>? coreTypeId,
    Expression<int>? coreId,
  }) {
    return RawValuesInsertable({
      if (coreTypeId != null) 'core_type_id': coreTypeId,
      if (coreId != null) 'core_id': coreId,
    });
  }

  CoreTypeSelectedCompanion copyWith({
    Value<int>? coreTypeId,
    Value<int>? coreId,
  }) {
    return CoreTypeSelectedCompanion(
      coreTypeId: coreTypeId ?? this.coreTypeId,
      coreId: coreId ?? this.coreId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coreTypeId.present) {
      map['core_type_id'] = Variable<int>(coreTypeId.value);
    }
    if (coreId.present) {
      map['core_id'] = Variable<int>(coreId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoreTypeSelectedCompanion(')
          ..write('coreTypeId: $coreTypeId, ')
          ..write('coreId: $coreId')
          ..write(')'))
        .toString();
  }
}

class ProfileGroup extends Table
    with TableInfo<ProfileGroup, ProfileGroupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProfileGroup(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> coreTypeId = GeneratedColumn<int>(
    'core_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_type (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, updatedAt, type, coreTypeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_group';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileGroupData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileGroupData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      coreTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_type_id'],
      ),
    );
  }

  @override
  ProfileGroup createAlias(String alias) {
    return ProfileGroup(attachedDatabase, alias);
  }
}

class ProfileGroupData extends DataClass
    implements Insertable<ProfileGroupData> {
  final int id;
  final String name;
  final DateTime updatedAt;
  final int type;
  final int? coreTypeId;
  const ProfileGroupData({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.type,
    this.coreTypeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || coreTypeId != null) {
      map['core_type_id'] = Variable<int>(coreTypeId);
    }
    return map;
  }

  ProfileGroupCompanion toCompanion(bool nullToAbsent) {
    return ProfileGroupCompanion(
      id: Value(id),
      name: Value(name),
      updatedAt: Value(updatedAt),
      type: Value(type),
      coreTypeId: coreTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(coreTypeId),
    );
  }

  factory ProfileGroupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileGroupData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      type: serializer.fromJson<int>(json['type']),
      coreTypeId: serializer.fromJson<int?>(json['coreTypeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'type': serializer.toJson<int>(type),
      'coreTypeId': serializer.toJson<int?>(coreTypeId),
    };
  }

  ProfileGroupData copyWith({
    int? id,
    String? name,
    DateTime? updatedAt,
    int? type,
    Value<int?> coreTypeId = const Value.absent(),
  }) => ProfileGroupData(
    id: id ?? this.id,
    name: name ?? this.name,
    updatedAt: updatedAt ?? this.updatedAt,
    type: type ?? this.type,
    coreTypeId: coreTypeId.present ? coreTypeId.value : this.coreTypeId,
  );
  ProfileGroupData copyWithCompanion(ProfileGroupCompanion data) {
    return ProfileGroupData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      type: data.type.present ? data.type.value : this.type,
      coreTypeId: data.coreTypeId.present
          ? data.coreTypeId.value
          : this.coreTypeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('coreTypeId: $coreTypeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, updatedAt, type, coreTypeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileGroupData &&
          other.id == this.id &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt &&
          other.type == this.type &&
          other.coreTypeId == this.coreTypeId);
}

class ProfileGroupCompanion extends UpdateCompanion<ProfileGroupData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> updatedAt;
  final Value<int> type;
  final Value<int?> coreTypeId;
  const ProfileGroupCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.coreTypeId = const Value.absent(),
  });
  ProfileGroupCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime updatedAt,
    required int type,
    this.coreTypeId = const Value.absent(),
  }) : name = Value(name),
       updatedAt = Value(updatedAt),
       type = Value(type);
  static Insertable<ProfileGroupData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? updatedAt,
    Expression<int>? type,
    Expression<int>? coreTypeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (type != null) 'type': type,
      if (coreTypeId != null) 'core_type_id': coreTypeId,
    });
  }

  ProfileGroupCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? updatedAt,
    Value<int>? type,
    Value<int?>? coreTypeId,
  }) {
    return ProfileGroupCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      coreTypeId: coreTypeId ?? this.coreTypeId,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (coreTypeId.present) {
      map['core_type_id'] = Variable<int>(coreTypeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('coreTypeId: $coreTypeId')
          ..write(')'))
        .toString();
  }
}

class Profile extends Table with TableInfo<Profile, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Profile(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> coreTypeId = GeneratedColumn<int>(
    'core_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_type (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<String> coreCfg = GeneratedColumn<String>(
    'core_cfg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'{}\''),
  );
  late final GeneratedColumn<String> coreCfgFmt = GeneratedColumn<String>(
    'core_cfg_fmt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'json\''),
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> profileGroupId = GeneratedColumn<int>(
    'profile_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_group (id)',
    ),
    defaultValue: const CustomExpression('1'),
  );
  late final GeneratedColumn<int> httping = GeneratedColumn<int>(
    'httping',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    key,
    coreTypeId,
    coreCfg,
    coreCfgFmt,
    updatedAt,
    type,
    profileGroupId,
    httping,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      coreTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_type_id'],
      ),
      coreCfg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}core_cfg'],
      )!,
      coreCfgFmt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}core_cfg_fmt'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      profileGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_group_id'],
      )!,
      httping: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}httping'],
      ),
    );
  }

  @override
  Profile createAlias(String alias) {
    return Profile(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final int id;
  final String name;
  final String key;
  final int? coreTypeId;
  final String coreCfg;
  final String coreCfgFmt;
  final DateTime updatedAt;
  final int type;
  final int profileGroupId;
  final int? httping;
  const ProfileData({
    required this.id,
    required this.name,
    required this.key,
    this.coreTypeId,
    required this.coreCfg,
    required this.coreCfgFmt,
    required this.updatedAt,
    required this.type,
    required this.profileGroupId,
    this.httping,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || coreTypeId != null) {
      map['core_type_id'] = Variable<int>(coreTypeId);
    }
    map['core_cfg'] = Variable<String>(coreCfg);
    map['core_cfg_fmt'] = Variable<String>(coreCfgFmt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['type'] = Variable<int>(type);
    map['profile_group_id'] = Variable<int>(profileGroupId);
    if (!nullToAbsent || httping != null) {
      map['httping'] = Variable<int>(httping);
    }
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      name: Value(name),
      key: Value(key),
      coreTypeId: coreTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(coreTypeId),
      coreCfg: Value(coreCfg),
      coreCfgFmt: Value(coreCfgFmt),
      updatedAt: Value(updatedAt),
      type: Value(type),
      profileGroupId: Value(profileGroupId),
      httping: httping == null && nullToAbsent
          ? const Value.absent()
          : Value(httping),
    );
  }

  factory ProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      key: serializer.fromJson<String>(json['key']),
      coreTypeId: serializer.fromJson<int?>(json['coreTypeId']),
      coreCfg: serializer.fromJson<String>(json['coreCfg']),
      coreCfgFmt: serializer.fromJson<String>(json['coreCfgFmt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      type: serializer.fromJson<int>(json['type']),
      profileGroupId: serializer.fromJson<int>(json['profileGroupId']),
      httping: serializer.fromJson<int?>(json['httping']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'key': serializer.toJson<String>(key),
      'coreTypeId': serializer.toJson<int?>(coreTypeId),
      'coreCfg': serializer.toJson<String>(coreCfg),
      'coreCfgFmt': serializer.toJson<String>(coreCfgFmt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'type': serializer.toJson<int>(type),
      'profileGroupId': serializer.toJson<int>(profileGroupId),
      'httping': serializer.toJson<int?>(httping),
    };
  }

  ProfileData copyWith({
    int? id,
    String? name,
    String? key,
    Value<int?> coreTypeId = const Value.absent(),
    String? coreCfg,
    String? coreCfgFmt,
    DateTime? updatedAt,
    int? type,
    int? profileGroupId,
    Value<int?> httping = const Value.absent(),
  }) => ProfileData(
    id: id ?? this.id,
    name: name ?? this.name,
    key: key ?? this.key,
    coreTypeId: coreTypeId.present ? coreTypeId.value : this.coreTypeId,
    coreCfg: coreCfg ?? this.coreCfg,
    coreCfgFmt: coreCfgFmt ?? this.coreCfgFmt,
    updatedAt: updatedAt ?? this.updatedAt,
    type: type ?? this.type,
    profileGroupId: profileGroupId ?? this.profileGroupId,
    httping: httping.present ? httping.value : this.httping,
  );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      key: data.key.present ? data.key.value : this.key,
      coreTypeId: data.coreTypeId.present
          ? data.coreTypeId.value
          : this.coreTypeId,
      coreCfg: data.coreCfg.present ? data.coreCfg.value : this.coreCfg,
      coreCfgFmt: data.coreCfgFmt.present
          ? data.coreCfgFmt.value
          : this.coreCfgFmt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      type: data.type.present ? data.type.value : this.type,
      profileGroupId: data.profileGroupId.present
          ? data.profileGroupId.value
          : this.profileGroupId,
      httping: data.httping.present ? data.httping.value : this.httping,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('coreTypeId: $coreTypeId, ')
          ..write('coreCfg: $coreCfg, ')
          ..write('coreCfgFmt: $coreCfgFmt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('profileGroupId: $profileGroupId, ')
          ..write('httping: $httping')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    key,
    coreTypeId,
    coreCfg,
    coreCfgFmt,
    updatedAt,
    type,
    profileGroupId,
    httping,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.key == this.key &&
          other.coreTypeId == this.coreTypeId &&
          other.coreCfg == this.coreCfg &&
          other.coreCfgFmt == this.coreCfgFmt &&
          other.updatedAt == this.updatedAt &&
          other.type == this.type &&
          other.profileGroupId == this.profileGroupId &&
          other.httping == this.httping);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> key;
  final Value<int?> coreTypeId;
  final Value<String> coreCfg;
  final Value<String> coreCfgFmt;
  final Value<DateTime> updatedAt;
  final Value<int> type;
  final Value<int> profileGroupId;
  final Value<int?> httping;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.key = const Value.absent(),
    this.coreTypeId = const Value.absent(),
    this.coreCfg = const Value.absent(),
    this.coreCfgFmt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.profileGroupId = const Value.absent(),
    this.httping = const Value.absent(),
  });
  ProfileCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String key,
    this.coreTypeId = const Value.absent(),
    this.coreCfg = const Value.absent(),
    this.coreCfgFmt = const Value.absent(),
    required DateTime updatedAt,
    required int type,
    this.profileGroupId = const Value.absent(),
    this.httping = const Value.absent(),
  }) : name = Value(name),
       key = Value(key),
       updatedAt = Value(updatedAt),
       type = Value(type);
  static Insertable<ProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? key,
    Expression<int>? coreTypeId,
    Expression<String>? coreCfg,
    Expression<String>? coreCfgFmt,
    Expression<DateTime>? updatedAt,
    Expression<int>? type,
    Expression<int>? profileGroupId,
    Expression<int>? httping,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (key != null) 'key': key,
      if (coreTypeId != null) 'core_type_id': coreTypeId,
      if (coreCfg != null) 'core_cfg': coreCfg,
      if (coreCfgFmt != null) 'core_cfg_fmt': coreCfgFmt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (type != null) 'type': type,
      if (profileGroupId != null) 'profile_group_id': profileGroupId,
      if (httping != null) 'httping': httping,
    });
  }

  ProfileCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? key,
    Value<int?>? coreTypeId,
    Value<String>? coreCfg,
    Value<String>? coreCfgFmt,
    Value<DateTime>? updatedAt,
    Value<int>? type,
    Value<int>? profileGroupId,
    Value<int?>? httping,
  }) {
    return ProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      coreTypeId: coreTypeId ?? this.coreTypeId,
      coreCfg: coreCfg ?? this.coreCfg,
      coreCfgFmt: coreCfgFmt ?? this.coreCfgFmt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      profileGroupId: profileGroupId ?? this.profileGroupId,
      httping: httping ?? this.httping,
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
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (coreTypeId.present) {
      map['core_type_id'] = Variable<int>(coreTypeId.value);
    }
    if (coreCfg.present) {
      map['core_cfg'] = Variable<String>(coreCfg.value);
    }
    if (coreCfgFmt.present) {
      map['core_cfg_fmt'] = Variable<String>(coreCfgFmt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (profileGroupId.present) {
      map['profile_group_id'] = Variable<int>(profileGroupId.value);
    }
    if (httping.present) {
      map['httping'] = Variable<int>(httping.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('coreTypeId: $coreTypeId, ')
          ..write('coreCfg: $coreCfg, ')
          ..write('coreCfgFmt: $coreCfgFmt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type, ')
          ..write('profileGroupId: $profileGroupId, ')
          ..write('httping: $httping')
          ..write(')'))
        .toString();
  }
}

class ProfileLocal extends Table
    with TableInfo<ProfileLocal, ProfileLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProfileLocal(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [profileId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_local';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileLocalData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
    );
  }

  @override
  ProfileLocal createAlias(String alias) {
    return ProfileLocal(attachedDatabase, alias);
  }
}

class ProfileLocalData extends DataClass
    implements Insertable<ProfileLocalData> {
  final int profileId;
  const ProfileLocalData({required this.profileId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    return map;
  }

  ProfileLocalCompanion toCompanion(bool nullToAbsent) {
    return ProfileLocalCompanion(profileId: Value(profileId));
  }

  factory ProfileLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileLocalData(
      profileId: serializer.fromJson<int>(json['profileId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'profileId': serializer.toJson<int>(profileId)};
  }

  ProfileLocalData copyWith({int? profileId}) =>
      ProfileLocalData(profileId: profileId ?? this.profileId);
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

class ProfileLocalCompanion extends UpdateCompanion<ProfileLocalData> {
  final Value<int> profileId;
  const ProfileLocalCompanion({this.profileId = const Value.absent()});
  ProfileLocalCompanion.insert({this.profileId = const Value.absent()});
  static Insertable<ProfileLocalData> custom({Expression<int>? profileId}) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
    });
  }

  ProfileLocalCompanion copyWith({Value<int>? profileId}) {
    return ProfileLocalCompanion(profileId: profileId ?? this.profileId);
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
    return (StringBuffer('ProfileLocalCompanion(')
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }
}

class ProfileRemote extends Table
    with TableInfo<ProfileRemote, ProfileRemoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProfileRemote(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> autoUpdateInterval = GeneratedColumn<int>(
    'auto_update_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, url, autoUpdateInterval];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_remote';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileRemoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRemoteData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      autoUpdateInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_interval'],
      )!,
    );
  }

  @override
  ProfileRemote createAlias(String alias) {
    return ProfileRemote(attachedDatabase, alias);
  }
}

class ProfileRemoteData extends DataClass
    implements Insertable<ProfileRemoteData> {
  final int profileId;
  final String url;
  final int autoUpdateInterval;
  const ProfileRemoteData({
    required this.profileId,
    required this.url,
    required this.autoUpdateInterval,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['url'] = Variable<String>(url);
    map['auto_update_interval'] = Variable<int>(autoUpdateInterval);
    return map;
  }

  ProfileRemoteCompanion toCompanion(bool nullToAbsent) {
    return ProfileRemoteCompanion(
      profileId: Value(profileId),
      url: Value(url),
      autoUpdateInterval: Value(autoUpdateInterval),
    );
  }

  factory ProfileRemoteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRemoteData(
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

  ProfileRemoteData copyWith({
    int? profileId,
    String? url,
    int? autoUpdateInterval,
  }) => ProfileRemoteData(
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

class ProfileRemoteCompanion extends UpdateCompanion<ProfileRemoteData> {
  final Value<int> profileId;
  final Value<String> url;
  final Value<int> autoUpdateInterval;
  const ProfileRemoteCompanion({
    this.profileId = const Value.absent(),
    this.url = const Value.absent(),
    this.autoUpdateInterval = const Value.absent(),
  });
  ProfileRemoteCompanion.insert({
    this.profileId = const Value.absent(),
    required String url,
    required int autoUpdateInterval,
  }) : url = Value(url),
       autoUpdateInterval = Value(autoUpdateInterval);
  static Insertable<ProfileRemoteData> custom({
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

  ProfileRemoteCompanion copyWith({
    Value<int>? profileId,
    Value<String>? url,
    Value<int>? autoUpdateInterval,
  }) {
    return ProfileRemoteCompanion(
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
    return (StringBuffer('ProfileRemoteCompanion(')
          ..write('profileId: $profileId, ')
          ..write('url: $url, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }
}

class ProfileGroupLocal extends Table
    with TableInfo<ProfileGroupLocal, ProfileGroupLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProfileGroupLocal(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> profileGroupId = GeneratedColumn<int>(
    'profile_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_group (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [profileGroupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_group_local';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileGroupId};
  @override
  ProfileGroupLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileGroupLocalData(
      profileGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_group_id'],
      )!,
    );
  }

  @override
  ProfileGroupLocal createAlias(String alias) {
    return ProfileGroupLocal(attachedDatabase, alias);
  }
}

class ProfileGroupLocalData extends DataClass
    implements Insertable<ProfileGroupLocalData> {
  final int profileGroupId;
  const ProfileGroupLocalData({required this.profileGroupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_group_id'] = Variable<int>(profileGroupId);
    return map;
  }

  ProfileGroupLocalCompanion toCompanion(bool nullToAbsent) {
    return ProfileGroupLocalCompanion(profileGroupId: Value(profileGroupId));
  }

  factory ProfileGroupLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileGroupLocalData(
      profileGroupId: serializer.fromJson<int>(json['profileGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
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
    extends UpdateCompanion<ProfileGroupLocalData> {
  final Value<int> profileGroupId;
  const ProfileGroupLocalCompanion({
    this.profileGroupId = const Value.absent(),
  });
  ProfileGroupLocalCompanion.insert({
    this.profileGroupId = const Value.absent(),
  });
  static Insertable<ProfileGroupLocalData> custom({
    Expression<int>? profileGroupId,
  }) {
    return RawValuesInsertable({
      if (profileGroupId != null) 'profile_group_id': profileGroupId,
    });
  }

  ProfileGroupLocalCompanion copyWith({Value<int>? profileGroupId}) {
    return ProfileGroupLocalCompanion(
      profileGroupId: profileGroupId ?? this.profileGroupId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileGroupId.present) {
      map['profile_group_id'] = Variable<int>(profileGroupId.value);
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

class ProfileGroupRemote extends Table
    with TableInfo<ProfileGroupRemote, ProfileGroupRemoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProfileGroupRemote(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> profileGroupId = GeneratedColumn<int>(
    'profile_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_group (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> protocol = GeneratedColumn<int>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> autoUpdateInterval = GeneratedColumn<int>(
    'auto_update_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileGroupId,
    url,
    protocol,
    autoUpdateInterval,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_group_remote';
  @override
  Set<GeneratedColumn> get $primaryKey => {profileGroupId};
  @override
  ProfileGroupRemoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileGroupRemoteData(
      profileGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_group_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol'],
      )!,
      autoUpdateInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_interval'],
      )!,
    );
  }

  @override
  ProfileGroupRemote createAlias(String alias) {
    return ProfileGroupRemote(attachedDatabase, alias);
  }
}

class ProfileGroupRemoteData extends DataClass
    implements Insertable<ProfileGroupRemoteData> {
  final int profileGroupId;
  final String url;
  final int protocol;
  final int autoUpdateInterval;
  const ProfileGroupRemoteData({
    required this.profileGroupId,
    required this.url,
    required this.protocol,
    required this.autoUpdateInterval,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_group_id'] = Variable<int>(profileGroupId);
    map['url'] = Variable<String>(url);
    map['protocol'] = Variable<int>(protocol);
    map['auto_update_interval'] = Variable<int>(autoUpdateInterval);
    return map;
  }

  ProfileGroupRemoteCompanion toCompanion(bool nullToAbsent) {
    return ProfileGroupRemoteCompanion(
      profileGroupId: Value(profileGroupId),
      url: Value(url),
      protocol: Value(protocol),
      autoUpdateInterval: Value(autoUpdateInterval),
    );
  }

  factory ProfileGroupRemoteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileGroupRemoteData(
      profileGroupId: serializer.fromJson<int>(json['profileGroupId']),
      url: serializer.fromJson<String>(json['url']),
      protocol: serializer.fromJson<int>(json['protocol']),
      autoUpdateInterval: serializer.fromJson<int>(json['autoUpdateInterval']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileGroupId': serializer.toJson<int>(profileGroupId),
      'url': serializer.toJson<String>(url),
      'protocol': serializer.toJson<int>(protocol),
      'autoUpdateInterval': serializer.toJson<int>(autoUpdateInterval),
    };
  }

  ProfileGroupRemoteData copyWith({
    int? profileGroupId,
    String? url,
    int? protocol,
    int? autoUpdateInterval,
  }) => ProfileGroupRemoteData(
    profileGroupId: profileGroupId ?? this.profileGroupId,
    url: url ?? this.url,
    protocol: protocol ?? this.protocol,
    autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
  );
  ProfileGroupRemoteData copyWithCompanion(ProfileGroupRemoteCompanion data) {
    return ProfileGroupRemoteData(
      profileGroupId: data.profileGroupId.present
          ? data.profileGroupId.value
          : this.profileGroupId,
      url: data.url.present ? data.url.value : this.url,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
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
          ..write('protocol: $protocol, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileGroupId, url, protocol, autoUpdateInterval);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileGroupRemoteData &&
          other.profileGroupId == this.profileGroupId &&
          other.url == this.url &&
          other.protocol == this.protocol &&
          other.autoUpdateInterval == this.autoUpdateInterval);
}

class ProfileGroupRemoteCompanion
    extends UpdateCompanion<ProfileGroupRemoteData> {
  final Value<int> profileGroupId;
  final Value<String> url;
  final Value<int> protocol;
  final Value<int> autoUpdateInterval;
  const ProfileGroupRemoteCompanion({
    this.profileGroupId = const Value.absent(),
    this.url = const Value.absent(),
    this.protocol = const Value.absent(),
    this.autoUpdateInterval = const Value.absent(),
  });
  ProfileGroupRemoteCompanion.insert({
    this.profileGroupId = const Value.absent(),
    required String url,
    required int protocol,
    required int autoUpdateInterval,
  }) : url = Value(url),
       protocol = Value(protocol),
       autoUpdateInterval = Value(autoUpdateInterval);
  static Insertable<ProfileGroupRemoteData> custom({
    Expression<int>? profileGroupId,
    Expression<String>? url,
    Expression<int>? protocol,
    Expression<int>? autoUpdateInterval,
  }) {
    return RawValuesInsertable({
      if (profileGroupId != null) 'profile_group_id': profileGroupId,
      if (url != null) 'url': url,
      if (protocol != null) 'protocol': protocol,
      if (autoUpdateInterval != null)
        'auto_update_interval': autoUpdateInterval,
    });
  }

  ProfileGroupRemoteCompanion copyWith({
    Value<int>? profileGroupId,
    Value<String>? url,
    Value<int>? protocol,
    Value<int>? autoUpdateInterval,
  }) {
    return ProfileGroupRemoteCompanion(
      profileGroupId: profileGroupId ?? this.profileGroupId,
      url: url ?? this.url,
      protocol: protocol ?? this.protocol,
      autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileGroupId.present) {
      map['profile_group_id'] = Variable<int>(profileGroupId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<int>(protocol.value);
    }
    if (autoUpdateInterval.present) {
      map['auto_update_interval'] = Variable<int>(autoUpdateInterval.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileGroupRemoteCompanion(')
          ..write('profileGroupId: $profileGroupId, ')
          ..write('url: $url, ')
          ..write('protocol: $protocol, ')
          ..write('autoUpdateInterval: $autoUpdateInterval')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV9 extends GeneratedDatabase {
  DatabaseAtV9(QueryExecutor e) : super(e);
  late final Asset asset = Asset(this);
  late final AssetLocal assetLocal = AssetLocal(this);
  late final AssetRemote assetRemote = AssetRemote(this);
  late final CoreType coreType = CoreType(this);
  late final Core core = Core(this);
  late final CoreExec coreExec = CoreExec(this);
  late final CoreLib coreLib = CoreLib(this);
  late final CoreTypeSelected coreTypeSelected = CoreTypeSelected(this);
  late final ProfileGroup profileGroup = ProfileGroup(this);
  late final Profile profile = Profile(this);
  late final ProfileLocal profileLocal = ProfileLocal(this);
  late final ProfileRemote profileRemote = ProfileRemote(this);
  late final ProfileGroupLocal profileGroupLocal = ProfileGroupLocal(this);
  late final ProfileGroupRemote profileGroupRemote = ProfileGroupRemote(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    asset,
    assetLocal,
    assetRemote,
    coreType,
    core,
    coreExec,
    coreLib,
    coreTypeSelected,
    profileGroup,
    profile,
    profileLocal,
    profileRemote,
    profileGroupLocal,
    profileGroupRemote,
  ];
  @override
  int get schemaVersion => 9;
}
