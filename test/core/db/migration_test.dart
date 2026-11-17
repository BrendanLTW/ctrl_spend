import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2, 3, 4, 5]) {
    test(
      'v$from upgrades to v6 with the same schema as a new database',
      () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 6);
        await db.close();
      },
    );
  }

  test('v5 bills keep everything but their icon and colour', () async {
    final schema = await verifier.schemaAt(5);
    schema.rawDatabase
      ..execute(
        'INSERT INTO categories (name, type, icon_key, color_key, sort_order) '
        "VALUES ('Bills', 'expense', 'bolt', 'yellow', 0)",
      )
      ..execute(
        'INSERT INTO bills (name, amount_minor, category_id, repeat_unit, '
        'repeat_every, repeat_day, next_due, remind_days_before, icon_key, '
        'color_key, paused) '
        "VALUES ('Unifi', 12900, 1, 'month', 1, 8, "
        "'2026-11-08T00:00:00.000Z', 2, 'wifi', 'blue', 1)",
      )
      ..execute(
        'INSERT INTO transactions (amount_minor, type, category_id, '
        'occurred_at, title, bill_id) '
        "VALUES (12900, 'expense', 1, '2026-10-08T00:00:00.000Z', 'Unifi', "
        '1)',
      );
    final db = AppDatabase(schema.newConnection());
    final bill = await db.select(db.bills).getSingle();
    expect(
      (bill.id, bill.name, bill.amountMinor, bill.remindDaysBefore),
      (1, 'Unifi', 12900, 2),
    );
    expect((bill.repeatUnit, bill.repeatDay, bill.paused), ('month', 8, true));
    final payment = await db.select(db.transactions).getSingle();
    expect(payment.billId, 1, reason: 'still linked to its bill');
    await db.close();
  });

  group('v4 data in v6', () {
    late AppDatabase db;

    setUp(() async {
      final schema = await verifier.schemaAt(4);
      schema.rawDatabase
        ..execute(
          'INSERT INTO categories '
          '(name, type, icon_key, color_key, sort_order) '
          "VALUES ('Bills', 'expense', 'bolt', 'yellow', 0)",
        )
        ..execute(
          'INSERT INTO bills (name, amount_minor, category_id, repeat_unit, '
          'repeat_every, repeat_day, next_due, icon_key, color_key) '
          "VALUES ('Unifi', 12900, 1, 'month', 1, 8, "
          "'2026-11-08T00:00:00.000Z', 'wifi', 'blue')",
        )
        ..execute(
          'INSERT INTO goals (name, icon_key, target_minor, target_month) '
          "VALUES ('Bali trip', 'travel', 500000, "
          "'2027-03-01T00:00:00.000Z'), "
          "('Car', 'car', 1000000, '2028-01-01T00:00:00.000Z')",
        )
        ..execute(
          'INSERT INTO goal_contributions (goal_id, amount_minor, label, date) '
          "VALUES (1, 40000, 'From salary', '2026-11-03T00:00:00.000Z'), "
          "(1, 50000, 'From salary', '2026-09-03T00:00:00.000Z')",
        )
        ..execute(
          'INSERT INTO notifications (kind, title, body, created_at) '
          "VALUES ('billReminder', 'Unifi is due in 2 days', 'x', "
          "'2026-11-06T01:00:00.000Z'), "
          "('dailyReminder', 'Daily reminder', 'x', "
          "'2026-11-03T13:00:00.000Z')",
        );
      db = AppDatabase(schema.newConnection());
    });
    tearDown(() => db.close());

    test('bills keep their data and are not paused', () async {
      final bill = await db.select(db.bills).getSingle();
      expect((bill.name, bill.paused), ('Unifi', false));
    });

    test('goals were created on their first contribution', () async {
      final goals = await db.select(db.goals).get();
      final bali = goals.firstWhere((g) => g.name == 'Bali trip');
      expect(bali.createdAt, DateTime.utc(2026, 9, 3));
      expect(bali.targetMinor, 500000);
      expect(await db.select(db.goalContributions).get(), hasLength(2));
    });

    test('a goal with no contributions was created at the upgrade', () async {
      final before = DateTime.now().toUtc().subtract(
        const Duration(minutes: 1),
      );
      final car = (await db.select(db.goals).get()).firstWhere(
        (g) => g.name == 'Car',
      );
      expect(car.createdAt.isAfter(before), isTrue);
    });

    test('bill reminders become billDue; other kinds stay', () async {
      final kinds = [
        for (final n in await db.select(db.notifications).get()) n.kind,
      ];
      expect(kinds, unorderedEquals(['billDue', 'dailyReminder']));
    });

    test('there are no snapshots yet', () async {
      expect(await db.select(db.periodSnapshots).get(), isEmpty);
    });
  });

  test('v3 bills keep their data', () async {
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
