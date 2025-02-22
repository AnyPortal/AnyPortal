// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:anyportal/utils/db.dart';
import 'package:test/test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    final versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = Database(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test("migration from v1 to v2 does not corrupt data", () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldAssetData = <v1.AssetData>[];
    final expectedNewAssetData = <v2.AssetData>[];

    final oldAssetLocalData = <v1.AssetLocalData>[];
    final expectedNewAssetLocalData = <v2.AssetLocalData>[];

    final oldAssetRemoteData = <v1.AssetRemoteData>[];
    final expectedNewAssetRemoteData = <v2.AssetRemoteData>[];

    final oldCoreTypeData = <v1.CoreTypeData>[];
    final expectedNewCoreTypeData = <v2.CoreTypeData>[];

    final oldCoreData = <v1.CoreData>[];
    final expectedNewCoreData = <v2.CoreData>[];

    final oldCoreExecData = <v1.CoreExecData>[];
    final expectedNewCoreExecData = <v2.CoreExecData>[];

    final oldCoreLibData = <v1.CoreLibData>[];
    final expectedNewCoreLibData = <v2.CoreLibData>[];

    final oldCoreTypeSelectedData = <v1.CoreTypeSelectedData>[];
    final expectedNewCoreTypeSelectedData = <v2.CoreTypeSelectedData>[];

    final oldProfileGroupData = <v1.ProfileGroupData>[];
    final expectedNewProfileGroupData = <v2.ProfileGroupData>[];

    final oldProfileData = <v1.ProfileData>[];
    final expectedNewProfileData = <v2.ProfileData>[];

    final oldProfileLocalData = <v1.ProfileLocalData>[];
    final expectedNewProfileLocalData = <v2.ProfileLocalData>[];

    final oldProfileRemoteData = <v1.ProfileRemoteData>[];
    final expectedNewProfileRemoteData = <v2.ProfileRemoteData>[];

    final oldProfileGroupLocalData = <v1.ProfileGroupLocalData>[];
    final expectedNewProfileGroupLocalData = <v2.ProfileGroupLocalData>[];

    final oldProfileGroupRemoteData = <v1.ProfileGroupRemoteData>[];
    final expectedNewProfileGroupRemoteData = <v2.ProfileGroupRemoteData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: Database.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.asset, oldAssetData);
        batch.insertAll(oldDb.assetLocal, oldAssetLocalData);
        batch.insertAll(oldDb.assetRemote, oldAssetRemoteData);
        batch.insertAll(oldDb.coreType, oldCoreTypeData);
        batch.insertAll(oldDb.core, oldCoreData);
        batch.insertAll(oldDb.coreExec, oldCoreExecData);
        batch.insertAll(oldDb.coreLib, oldCoreLibData);
        batch.insertAll(oldDb.coreTypeSelected, oldCoreTypeSelectedData);
        batch.insertAll(oldDb.profileGroup, oldProfileGroupData);
        batch.insertAll(oldDb.profile, oldProfileData);
        batch.insertAll(oldDb.profileLocal, oldProfileLocalData);
        batch.insertAll(oldDb.profileRemote, oldProfileRemoteData);
        batch.insertAll(oldDb.profileGroupLocal, oldProfileGroupLocalData);
        batch.insertAll(oldDb.profileGroupRemote, oldProfileGroupRemoteData);
      },
      validateItems: (newDb) async {
        expect(expectedNewAssetData, await newDb.select(newDb.asset).get());
        expect(expectedNewAssetLocalData,
            await newDb.select(newDb.assetLocal).get());
        expect(expectedNewAssetRemoteData,
            await newDb.select(newDb.assetRemote).get());
        expect(
            expectedNewCoreTypeData, await newDb.select(newDb.coreType).get());
        expect(expectedNewCoreData, await newDb.select(newDb.core).get());
        expect(
            expectedNewCoreExecData, await newDb.select(newDb.coreExec).get());
        expect(expectedNewCoreLibData, await newDb.select(newDb.coreLib).get());
        expect(expectedNewCoreTypeSelectedData,
            await newDb.select(newDb.coreTypeSelected).get());
        expect(expectedNewProfileGroupData,
            await newDb.select(newDb.profileGroup).get());
        expect(expectedNewProfileData, await newDb.select(newDb.profile).get());
        expect(expectedNewProfileLocalData,
            await newDb.select(newDb.profileLocal).get());
        expect(expectedNewProfileRemoteData,
            await newDb.select(newDb.profileRemote).get());
        expect(expectedNewProfileGroupLocalData,
            await newDb.select(newDb.profileGroupLocal).get());
        expect(expectedNewProfileGroupRemoteData,
            await newDb.select(newDb.profileGroupRemote).get());
      },
    );
  });
}
