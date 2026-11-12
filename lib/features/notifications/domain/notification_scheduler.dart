import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_scheduler.g.dart';

/// The phone's notification system. Everything is local: nothing is sent
/// to a server (PRD §5.4). Times are local wall-clock times.
abstract interface class NotificationScheduler {
  /// Asks the OS for permission (S07). True when granted.
  Future<bool> requestPermission();

  /// Repeats every day at [minutes] after local midnight.
  Future<void> scheduleDaily({
    required int id,
    required int minutes,
    required String title,
    required String body,
  });

  /// Repeats every week on [weekday] (`DateTime.monday`…`sunday`) at
  /// [minutes] after local midnight.
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int minutes,
    required String title,
    required String body,
  });

  /// Shows once at [at].
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  });

  Future<void> cancel(int id);
}

/// Overridden in `main.dart` with the flutter_local_notifications one.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) =>
    throw UnimplementedError('Override notificationSchedulerProvider');
