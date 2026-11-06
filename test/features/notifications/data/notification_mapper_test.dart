import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/notifications/data/notification_mapper.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<AppNotification> roundTrip(AppNotification notification) async {
    await db.into(db.notifications).insert(notification.toCompanion());
    final row = await (db.select(
      db.notifications,
    )..where((n) => n.id.equals(notification.id))).getSingle();
    return row.toEntity();
  }

  test('every kind survives a round trip, read and unread', () async {
    for (final (i, kind) in NotificationKind.values.indexed) {
      final notification = AppNotification(
        id: i + 1,
        kind: kind,
        title: 'Title $i',
        body: 'Body $i',
        createdAt: DateTime.utc(2026, 11, 6, 9, i),
        readAt: i.isEven ? DateTime.utc(2026, 11, 6, 10, i) : null,
      );
      expect(await roundTrip(notification), notification);
    }
  });
}
