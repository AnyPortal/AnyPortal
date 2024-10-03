import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesWithDefaults {
  final SharedPreferences _prefs;
  final Map<String, dynamic> defaults;

  SharedPreferencesWithDefaults(this._prefs, this.defaults);

  Object? getWithDefault(String key) {
    final val = _prefs.get(key);
    if (val == null && defaults.containsKey(key)) {
      return defaults[key];
    }
    return val;
  }

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Returns true if the persistent storage contains the given [key].
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Reads a value of any type from persistent storage.
  Object? get(String key) {
    return _prefs.get(key);
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool? getBool(String key) {
    return getWithDefault(key) as bool?;
  }

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int? getInt(String key) {
    return getWithDefault(key) as int?;
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double? getDouble(String key) {
    return getWithDefault(key) as double?;
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String? getString(String key) {
    return getWithDefault(key) as String?;
  }

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string list.
  List<String>? getStringList(String key) {
    return getWithDefault(key) as List<String>?;
  }

  /// Saves a boolean [value] to persistent storage in the background.
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Saves an integer [value] to persistent storage in the background.
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// Note: Due to limitations in Android's SharedPreferences,
  /// values cannot start with any one of the following:
  ///
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu'
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy'
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu'
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Saves a list of strings [value] to persistent storage in the background.
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    return await _prefs.reload();
  }

  Future<bool> set(String key, dynamic value) async {
    if (value == null) {
      return await _prefs.remove(key);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    }
    return false;
  }
}
