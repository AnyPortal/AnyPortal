import 'dart:async'; // Add Completer for async handling
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/asset.dart';
import '../models/core.dart';
import '../models/profile.dart';
import '../models/profile_group.dart';

part 'db.g.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  late final Database _db;
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
    _db = Database(_openConnection(file));

    _completer.complete(); // Signal that initialization is complete
  }

  static QueryExecutor _openConnection(File file) {
    return NativeDatabase.createInBackground(file);
  }

  // Getter for synchronous access (ensure db is initialized before using this)
  Database get db {
    if (!_completer.isCompleted) {
      throw Exception('Database has not been initialized. Call init() first.');
    }
    return _db;
  }
}

// Drift database definition
@DriftDatabase(tables: [
  Asset,
  AssetLocal,
  AssetRemote,
  Core,
  CoreExec,
  CoreLib,
  CoreType,
  CoreTypeSelected,
  Profile,
  ProfileLocal,
  ProfileRemote,
  ProfileGroup,
  ProfileGroupLocal,
  ProfileGroupRemote,
])
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // Runs on the first database creation
        onCreate: (Migrator m) async {
          await m.createAll();
          await into(profileGroup).insertOnConflictUpdate(ProfileGroupCompanion(
              id: const Value(1),
              name: const Value(""),
              updatedAt: Value(DateTime.now()),
              type: const Value(ProfileGroupType.local)));
          for (var e in CoreTypeDefault.values) {
            await into(coreType).insertOnConflictUpdate(CoreTypeCompanion(
              id: Value(e.index),
              name: Value(e.toString()),
            ));
          }
        },
      );
}

final db = DatabaseManager().db;
