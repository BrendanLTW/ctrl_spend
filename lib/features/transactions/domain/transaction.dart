import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// The longest title and note (PRD §5.3, §8).
const maxTitleLength = 40;
const maxNoteLength = 200;

/// Throws [ArgumentError] for a [title] over [maxTitleLength], a [note]
/// over [maxNoteLength], or an [occurredAt] on a local day after [now]'s:
/// the date can't be in the future (PRD §5.3, §8). Later today is fine, so
/// an imported row with no time (noon) can be dated today.
void checkTransactionFields({
  required String title,
  required String? note,
  required DateTime occurredAt,
  required DateTime now,
}) {
  if (title.length > maxTitleLength) {
    throw ArgumentError.value(title, 'title', 'is over $maxTitleLength');
  }
  if ((note?.length ?? 0) > maxNoteLength) {
    throw ArgumentError.value(note, 'note', 'is over $maxNoteLength');
  }
  if (isFutureDay(occurredAt, now)) {
    throw ArgumentError.value(occurredAt, 'occurredAt', 'is in the future');
  }
}

/// Whether [date]'s local calendar day is after [now]'s.
bool isFutureDay(DateTime date, DateTime now) {
  final d = date.toLocal();
  final n = now.toLocal();
  return DateTime(d.year, d.month, d.day).isAfter(
    DateTime(n.year, n.month, n.day),
  );
}

/// Whether money goes out or comes in. Categories have a type too, and a
/// transaction's type matches its category's (PRD §8).
enum TransactionType { expense, income }

/// An expense or income entry (PRD §8).
@freezed
abstract class Transaction with _$Transaction {
  const factory({
    required int id,
    required int amountMinor,
    required TransactionType type,
    required int categoryId,

    /// In UTC; shown in local time.
    required DateTime occurredAt,
    required String title,
    String? note,

    /// The bill this pays, if it came from "Mark paid" (v1.1).
    int? billId,
  }) = _Transaction;
}
