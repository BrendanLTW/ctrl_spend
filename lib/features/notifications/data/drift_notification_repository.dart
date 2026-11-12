import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/notifications/data/notification_mapper.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';
import 'package:drift/drift.dart';

class DriftNotificationRepository implements NotificationRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<AppNotification>> watch() {
    final n = _db.notifications;
    final query = _db.select(n)
      ..orderBy([
        (n) => OrderingTerm.desc(n.createdAt),
        (n) => OrderingTerm.desc(n.id),
      ]);
    return query.watch().map((rows) => [for (final r in rows) r.toEntity()]);
  }

  @override
  Future<void> add({
    required NotificationKind kind,
    required String title,
    required String body,
    required DateTime createdAt,
    int? categoryId,
  }) => _db
      .into(_db.notifications)
      .insert(
        NotificationsCompanion.insert(
          kind: kind.name,
          title: title,
          body: body,
          createdAt: createdAt.toUtc(),
          categoryId: Value(categoryId),
        ),
      );

  @override
  Future<void> markAllRead(DateTime at) =>
      (_db.update(_db.notifications)..where((n) => n.readAt.isNull())).write(
        NotificationsCompanion(readAt: Value(at.toUtc())),
      );
}
