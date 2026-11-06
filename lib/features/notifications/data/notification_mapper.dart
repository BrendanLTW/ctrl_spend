import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:drift/drift.dart';

extension NotificationRowMapper on NotificationRow {
  AppNotification toEntity() => AppNotification(
    id: id,
    kind: NotificationKind.values.byName(kind),
    title: title,
    body: body,
    createdAt: createdAt,
    readAt: readAt,
  );
}

extension NotificationMapper on AppNotification {
  /// The row to update. For a new notification, leave out the id with
  /// `toCompanion().copyWith(id: const Value.absent())`.
  NotificationsCompanion toCompanion() => NotificationsCompanion(
    id: Value(id),
    kind: Value(kind.name),
    title: Value(title),
    body: Value(body),
    createdAt: Value(createdAt.toUtc()),
    readAt: Value(readAt?.toUtc()),
  );
}
