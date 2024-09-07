import 'package:drift/drift.dart';

// Drift table definition for the base table
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get json => text().withDefault(const Constant("{}"))();
  DateTimeColumn get lastUpdated => dateTime()();
  IntColumn get type => integer().map(const ProfileTypeConverter())();
}

// Separate table for local profiles (no additional fields)
class ProfileLocals extends Table {
  IntColumn get profileId => integer().references(Profiles, #id)();
  
  @override
  Set<Column<Object>>? get primaryKey => {profileId};
}

// Separate table for remote profiles
class ProfileRemotes extends Table {
  IntColumn get profileId => integer().references(Profiles, #id)();
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