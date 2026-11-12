import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_repository.g.dart';

/// The notifications inbox (PRD §5.4).
abstract interface class NotificationRepository {
  /// Every notification, newest first.
  Stream<List<AppNotification>> watch();

  /// Saves an unread notification.
  Future<void> add({
    required NotificationKind kind,
    required String title,
    required String body,
    required DateTime createdAt,
  });

  /// Marks every unread notification read at [at] (S14 on open).
  Future<void> markAllRead(DateTime at);
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    throw UnimplementedError('Override notificationRepositoryProvider');

/// The inbox, live.
@riverpod
Stream<List<AppNotification>> notifications(Ref ref) =>
    ref.watch(notificationRepositoryProvider).watch();
