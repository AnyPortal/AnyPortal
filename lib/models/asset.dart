import 'package:drift/drift.dart';

class Asset extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  /// remote, local
  IntColumn get type => integer().map(const AssetTypeConverter())();
  TextColumn get path => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

class AssetLocal extends Table {
  IntColumn get assetId => integer().references(Asset, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>>? get primaryKey => {assetId};
}

class AssetRemote extends Table {
  IntColumn get assetId => integer().references(Asset, #id, onDelete: KeyAction.cascade)();
  /// github://owner/repo/asset.ext/sub/path
  TextColumn get url => text()();
  TextColumn get meta => text().withDefault(const Constant("{}"))();
  IntColumn get autoUpdateInterval => integer()();
  TextColumn get downloadedFilePath => text().nullable()();
  DateTimeColumn get checkedAt => dateTime().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {assetId};
}

enum AssetType {
  local,
  remote,
}

class AssetTypeConverter extends TypeConverter<AssetType, int> {
  const AssetTypeConverter();

  @override
  AssetType fromSql(int fromDb) {
    return AssetType.values[fromDb];
  }

  @override
  int toSql(AssetType value) {
    return value.index;
  }
}
