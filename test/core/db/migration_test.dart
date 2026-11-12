import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 upgrades to v2 with the same schema as a new database', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v1 notifications keep their data and get no category', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      'INSERT INTO notifications (kind, title, body, created_at) '
      "VALUES ('dailyReminder', 'Daily reminder', 'body', "
      "'2026-11-03T21:00:00.000Z')",
    );
    final db = AppDatabase(schema.newConnection());
    final rows = await db.select(db.notifications).get();
    expect(rows.single.title, 'Daily reminder');
    expect(rows.single.categoryId, isNull);
    await db.close();
  });
}
