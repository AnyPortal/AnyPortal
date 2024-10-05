import 'package:drift/drift.dart';

class EnumTypeConverter<T extends Enum> extends TypeConverter<T, int> {
  final List<T> enumValues;

  const EnumTypeConverter(this.enumValues);

  @override
  T fromSql(int fromDb) {
    return enumValues[fromDb];
  }

  @override
  int toSql(T value) {
    return value.index;
  }
}