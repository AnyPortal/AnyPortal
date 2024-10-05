import 'package:drift/drift.dart';

class ProfileGroup extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get type => integer().map(const ProfileGroupTypeConverter())();
}

class ProfileGroupLocal extends Table {
  IntColumn get profileGroupId => integer().references(ProfileGroup, #id)();
  
  @override
  Set<Column<Object>>? get primaryKey => {profileGroupId};
}

class ProfileGroupRemote extends Table {
  IntColumn get profileGroupId => integer().references(ProfileGroup, #id)();
  TextColumn get url => text()();
  IntColumn get format => integer().map(const ProfileGroupFormatConverter())();
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

enum ProfileGroupRemoteFormat {
  fv2rayRest,
}

class ProfileGroupFormatConverter extends TypeConverter<ProfileGroupRemoteFormat, int> {
  const ProfileGroupFormatConverter();

  @override
  ProfileGroupRemoteFormat fromSql(int fromDb) {
    return ProfileGroupRemoteFormat.values[fromDb];
  }

  @override
  int toSql(ProfileGroupRemoteFormat value) {
    return value.index;
  }
}

