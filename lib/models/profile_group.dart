import 'package:drift/drift.dart';

import 'core.dart';

class ProfileGroup extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get type => integer().map(const ProfileGroupTypeConverter())();
  IntColumn get coreTypeId => integer().nullable().references(
    CoreType,
    #id,
    onDelete: KeyAction.cascade,
  )();
}

class ProfileGroupLocal extends Table {
  IntColumn get profileGroupId =>
      integer().references(ProfileGroup, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>>? get primaryKey => {profileGroupId};
}

class ProfileGroupRemote extends Table {
  IntColumn get profileGroupId =>
      integer().references(ProfileGroup, #id, onDelete: KeyAction.cascade)();
  TextColumn get url => text()();
  IntColumn get protocol =>
      integer().map(const ProfileGroupRemoteProtocolConverter())();
  IntColumn get autoUpdateInterval => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {profileGroupId};
}

enum ProfileGroupType {
  local,
  remote,
}

class ProfileGroupTypeConverter extends TypeConverter<ProfileGroupType, int> {
  const ProfileGroupTypeConverter();

  @override
  ProfileGroupType fromSql(int fromDb) {
    return ProfileGroupType.values[fromDb];
  }

  @override
  int toSql(ProfileGroupType value) {
    return value.index;
  }
}

enum ProfileGroupRemoteProtocol {
  anyportalRest,
  file,
  generic,
}

class ProfileGroupRemoteProtocolConverter
    extends TypeConverter<ProfileGroupRemoteProtocol, int> {
  const ProfileGroupRemoteProtocolConverter();

  @override
  ProfileGroupRemoteProtocol fromSql(int fromDb) {
    return ProfileGroupRemoteProtocol.values[fromDb];
  }

  @override
  int toSql(ProfileGroupRemoteProtocol value) {
    return value.index;
  }
}
