import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2, 3]) {
    test(
      'v$from upgrades to v4 with the same schema as a new database',
      () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 4);
        await db.close();
      },
    );
  }

  test('v3 bills keep their data and get the Bills look', () async {
    final schema = await verifier.schemaAt(3);
    schema.rawDatabase
      ..execute(
        'INSERT INTO categories (name, type, icon_key, color_key, sort_order) '
        "VALUES ('Bills', 'expense', 'bolt', 'yellow', 0)",
      )
      ..execute(
        'INSERT INTO bills (name, amount_minor, category_id, repeat_unit, '
        'repeat_every, repeat_day, next_due) '
        "VALUES ('Unifi', 12900, 1, 'month', 1, 8, "
        "'2026-11-08T00:00:00.000Z')",
      );
    final db = AppDatabase(schema.newConnection());
    final bill = await db.select(db.bills).getSingle();
    expect(bill.name, 'Unifi');
    expect(bill.repeatDay, 8);
    expect((bill.iconKey, bill.colorKey), ('bolt', 'yellow'));
    await db.close();
  });

  test('v2 transactions keep their data and come from no bill', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase
      ..execute(
        'INSERT INTO categories (name, type, icon_key, color_key, sort_order) '
        "VALUES ('Food', 'expense', 'food', 'orange', 0)",
      )
      ..execute(
        'INSERT INTO transactions '
        '(amount_minor, type, category_id, occurred_at, title) '
        "VALUES (1250, 'expense', 1, '2026-11-03T12:00:00.000Z', 'Lunch')",
      );
    final db = AppDatabase(schema.newConnection());
    final rows = await db.select(db.transactions).get();
    expect(rows.single.title, 'Lunch');
    expect(rows.single.amountMinor, 1250);
    expect(rows.single.billId, isNull);
    expect(await db.select(db.bills).get(), isEmpty);
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
