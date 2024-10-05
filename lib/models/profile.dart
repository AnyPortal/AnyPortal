import 'package:drift/drift.dart';
import 'package:fv2ray/models/core.dart';
import 'package:fv2ray/models/profile_group.dart';

class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get coreTypeId => integer().references(CoreType, #id)();
  TextColumn get coreCfg => text().withDefault(const Constant("{}"))();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get type => integer().map(const ProfileTypeConverter())();
  IntColumn get profileGroupId =>
    integer().references(ProfileGroup, #id).withDefault(const Constant(1))();
}

// Separate table for local profiles (no additional fields)
class ProfileLocal extends Table {
  IntColumn get profileId => integer().references(Profile, #id)();
  
  @override
  Set<Column<Object>>? get primaryKey => {profileId};
}

// Separate table for remote profiles
class ProfileRemote extends Table {
  IntColumn get profileId => integer().references(Profile, #id)();
  TextColumn get url => text()();
  IntColumn get autoUpdateInterval => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {profileId};
}

enum ProfileType {
  local,
  remote,
}

class ProfileTypeConverter extends TypeConverter<ProfileType, int> {
  const ProfileTypeConverter();

  @override
  ProfileType fromSql(int fromDb) {
    return ProfileType.values[fromDb];
  }

  @override
  int toSql(ProfileType value) {
    return value.index;
  }
}
