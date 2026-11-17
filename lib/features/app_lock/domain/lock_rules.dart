/// Whether coming back to the app needs the PIN again: it went to the
/// background at [awaySince] and has been away at least
/// [lockAfterMinutes] by [now] (S68; 0 is "Immediately").
bool shouldLock({
  required DateTime? awaySince,
  required DateTime now,
  required int lockAfterMinutes,
}) =>
    awaySince != null &&
    now.difference(awaySince) >= Duration(minutes: lockAfterMinutes);
