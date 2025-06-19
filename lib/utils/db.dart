import 'dart:async'; // Add Completer for async handling
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;

import '../models/asset.dart';
import '../models/core.dart';
import '../models/profile.dart';
import '../models/profile_group.dart';

import 'db.steps.dart';
import 'db/connection.dart' as impl;
import 'global.dart';
import 'logger.dart';
import 'runtime_platform.dart';

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
    logger.d("starting: DatabaseManager.init");
    if (!RuntimePlatform.isWeb) {
      final dbFolder = global.applicationDocumentsDirectory;
      final file = File(p.join(dbFolder.path, "AnyPortal", "db.sqlite"));
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
    }
    _db = Database();

    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: DatabaseManager.init");
  }

  // Getter for synchronous access (ensure db is initialized before using this)
  Database get db {
    if (!_completer.isCompleted) {
      throw Exception('Database has not been initialized. Call init() first.');
    }
    return _db;
  }
}

Future<String> getDatabasePath() async {
  final dbFolder = global.applicationDocumentsDirectory;
  return p.join(dbFolder.path, "AnyPortal", "db.sqlite");
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
  Database([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'AnyPortal',
                native: const DriftNativeOptions(
                  databasePath: getDatabasePath,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      logger.w(
                        'Using ${result.chosenImplementation} due to unsupported '
                        'browser features: ${result.missingFeatures}',
                      );
                    }
                  },
                ),
              ),
        );

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // Runs on the first database creation
        onCreate: (Migrator m) async {
          await m.createAll();
          // default profile group 1
          await into(profileGroup).insertOnConflictUpdate(ProfileGroupCompanion(
            id: const Value(1),
            name: const Value(""),
            updatedAt: Value(DateTime.now()),
            type: const Value(ProfileGroupType.local),
          ));
          // default core types
          for (var e in CoreTypeDefault.values) {
            await into(coreType).insertOnConflictUpdate(CoreTypeCompanion(
              id: Value(e.index),
              name: Value(e.toString()),
            ));
          }
          // android embedded core
          if (RuntimePlatform.isAndroid) {
            final coreId =
                await into(core).insertOnConflictUpdate(CoreCompanion(
              coreTypeId: Value(CoreTypeDefault.xray.index),
              version: const Value("libv2raymobile"),
              updatedAt: Value(DateTime.now()),
              isExec: const Value(false),
              workingDir: const Value(""),
              envs: const Value("{}"),
            ));
            await into(coreTypeSelected)
                .insertOnConflictUpdate(CoreTypeSelectedCompanion(
              coreTypeId: Value(CoreTypeDefault.xray.index),
              coreId: Value(coreId),
            ));
          }
        },
        onUpgrade: stepByStep(
          from1To2: (m, schema) async {
            await m.addColumn(
                schema.assetRemote, schema.assetRemote.downloadedFilePath);
          },
          from2To3: (m, schema) async {
            await m.alterTable(TableMigration(schema.assetLocal));
            await m.alterTable(TableMigration(schema.assetRemote));
          },
          from3To4: (m, schema) async {
            await m.addColumn(schema.assetRemote, schema.assetRemote.checkedAt);
          },
        ),
        beforeOpen: (details) async {
          // This follows the recommendation to validate that the database schema
          // matches what drift expects (https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime).
          // It allows catching bugs in the migration logic early.
          await impl.validateDatabaseSchema(this);
        },
      );
}

final db = DatabaseManager().db;
