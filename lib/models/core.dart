import 'package:drift/drift.dart';

import 'asset.dart';

class Core extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// V2Ray, Xray, sing-box
  IntColumn get coreTypeId => integer().references(CoreType, #id)();
  TextColumn get version => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isExec => boolean().withDefault(const Constant(true))();

  TextColumn get workingDir => text()();
  TextColumn get envs => text()();
}

class CoreExec extends Table {
  IntColumn get coreId => integer().references(Core, #id)();
  TextColumn get args => text().withDefault(const Constant("[]"))();
  IntColumn get assetId => integer().references(Asset, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {coreId};
}

class CoreLib extends Table {
  IntColumn get coreId => integer().references(Core, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {coreId};
}

class CoreTypeSelected extends Table {
  IntColumn get coreTypeId => integer().references(CoreType, #id)();
  IntColumn get coreId => integer().references(Core, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {coreTypeId};
}

enum CoreTypeDefault {
  v2ray,
  xray,
  singBox;

  @override
  String toString() {
    switch (name) {
      case "singBox":
        return "sing-box";
      default:
        return name;
    }
  }
}

class CoreType extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}
