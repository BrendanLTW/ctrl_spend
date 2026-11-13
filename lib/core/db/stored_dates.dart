/// Calendar dates (a bill's due date, a goal's target month) are stored
/// as UTC midnight (schema v3), so a time zone change can't move them,
/// and used as local midnight.
DateTime storedDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

DateTime localDate(DateTime stored) {
  final utc = stored.toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}
