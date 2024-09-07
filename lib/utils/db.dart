import 'dart:async'; // Add Completer for async handling
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/profile.dart';

part 'db.g.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  late final LazyDatabase _db;
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  DatabaseManager._internal();

  // Singleton accessor
  factory DatabaseManager() {
    return _instance;
  }

  // Async initializer (call once at app startup)
  Future<void> init() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fv2ray', 'db.sqlite'));
    _db = LazyDatabase(() async => NativeDatabase(file));
    _completer.complete(); // Signal that initialization is complete
  }

  // Getter for synchronous access (ensure db is initialized before using this)
  LazyDatabase get db {
    if (!_completer.isCompleted) {
      throw Exception('Database has not been initialized. Call init() first.');
    }
    return _db;
  }
}

// Drift database definition
@DriftDatabase(tables: [
  Profiles, ProfileLocals, ProfileRemotes
])
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 2;
}

final db = Database(DatabaseManager().db);