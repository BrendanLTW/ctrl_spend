import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';

enum RepeatUnit { day, week, month, year }

/// How often a bill repeats: every [every] [unit]s (S44). Every 2 weeks
/// is (week, 2); Custom is any other pair. For month and year, [day] is
/// the day of the month to come back to, so a bill due on the 31st
/// returns to it after a shorter month; it is null for day and week.
@freezed
abstract class BillRepeat with _$BillRepeat {
  const factory({required RepeatUnit unit, @Default(1) int every, int? day}) =
      _BillRepeat;
}

/// A recurring bill (PRD §5.11, v1.1).
@freezed
abstract class Bill with _$Bill {
  const factory({
    required int id,
    required String name,
    required int amountMinor,
    required int categoryId,
    required BillRepeat repeat,

    /// A local calendar date, at midnight.
    required DateTime nextDue,

    /// Its tile on S27, picked on S28.
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,

    /// Days before [nextDue] to remind; null means no reminder.
    int? remindDaysBefore,

    /// Left out of Upcoming totals, "Left after bills" and reminders
    /// (PRD §5.11).
    @Default(false) bool paused,
  }) = _Bill;
}
