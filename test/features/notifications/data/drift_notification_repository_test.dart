import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/notifications/data/drift_notification_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftNotificationRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftNotificationRepository(db);
  });
  tearDown(() => db.close());

  Future<void> add(String title, DateTime at) => repo.add(
    kind: NotificationKind.dailyReminder,
    title: title,
    body: 'body',
    createdAt: at,
  );

  test('adds unread notifications, newest first', () async {
    await add('older', DateTime(2026, 11, 3, 21));
    await add('newer', DateTime(2026, 11, 4, 9));
    final all = await repo.watch().first;
    expect([for (final n in all) n.title], ['newer', 'older']);
    expect(all.first.kind, NotificationKind.dailyReminder);
    expect(all.first.createdAt, DateTime(2026, 11, 4, 9).toUtc());
    expect(all.every((n) => n.readAt == null), isTrue);
  });

  test('markAllRead stamps only the unread ones', () async {
    await add('first', DateTime(2026, 11, 3));
    await repo.markAllRead(DateTime(2026, 11, 3, 12));
    await add('second', DateTime(2026, 11, 4));
    await repo.markAllRead(DateTime(2026, 11, 4, 12));
    final byTitle = {for (final n in await repo.watch().first) n.title: n};
    expect(byTitle['first']!.readAt, DateTime(2026, 11, 3, 12).toUtc());
    expect(byTitle['second']!.readAt, DateTime(2026, 11, 4, 12).toUtc());
  });
}
