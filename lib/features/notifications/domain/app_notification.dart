import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

/// The notification types in PRD §5.4.
enum NotificationKind {
  budgetWarning,
  overBudget,
  dailyReminder,
  incomeRecorded,
  weeklySummary,
  periodStarted,
}

/// An inbox entry (PRD §5.4). Not `Notification`, which Flutter already has.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory({
    required int id,
    required NotificationKind kind,
    required String title,
    required String body,
    required DateTime createdAt,

    /// Null while unread.
    DateTime? readAt,
  }) = _AppNotification;
}
