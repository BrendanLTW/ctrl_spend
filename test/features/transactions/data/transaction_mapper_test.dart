import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/transactions/data/transaction_mapper.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Food',
            type: 'expense',
            iconKey: 'food',
            colorKey: 'orange',
            sortOrder: 0,
          ),
        );
  });
  tearDown(() => db.close());

  Future<Transaction> roundTrip(Transaction transaction) async {
    await db.into(db.transactions).insert(transaction.toCompanion());
    final row = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(transaction.id))).getSingle();
    return row.toEntity();
  }

  test('a transaction with a note survives a round trip', () async {
    final lunch = Transaction(
      id: 1,
      amountMinor: 1250,
      type: TransactionType.expense,
      categoryId: 1,
      occurredAt: DateTime.utc(2026, 11, 6, 4, 30, 15, 123),
      title: 'Lunch',
      note: 'Nasi lemak',
    );
    expect(await roundTrip(lunch), lunch);
  });

  test('a transaction without a note survives a round trip', () async {
    final bus = Transaction(
      id: 2,
      amountMinor: 180,
      type: TransactionType.expense,
      categoryId: 1,
      occurredAt: DateTime.utc(2026, 11, 6),
      title: 'Bus',
    );
    expect(await roundTrip(bus), bus);
  });

  test('a local occurredAt is stored as the same instant in UTC', () async {
    final local = DateTime(2026, 11, 6, 21, 15);
    final saved = await roundTrip(
      Transaction(
        id: 3,
        amountMinor: 900,
        type: TransactionType.expense,
        categoryId: 1,
        occurredAt: local,
        title: 'Dinner',
      ),
    );
    expect(saved.occurredAt.isUtc, isTrue);
    expect(saved.occurredAt, local.toUtc());
  });
}
