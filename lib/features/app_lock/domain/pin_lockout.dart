import 'dart:math';

/// Wrong PINs in a row before entry pauses (S66).
const pinAttemptsBeforeLockout = 5;

/// The first pause, and the longest (PRD §5.8).
const firstLockout = Duration(seconds: 30);
const maxLockout = Duration(minutes: 15);

/// How long entry pauses after the [failedCount]th wrong PIN in a row, or
/// null if it doesn't. It pauses on every fifth: 30 s after the 5th, then
/// doubling after each further 5 (60 s, 2 min, 4 min, 8 min), up to
/// 15 min (PRD §5.8, S66).
Duration? lockoutAfter(int failedCount) {
  if (failedCount < pinAttemptsBeforeLockout ||
      failedCount % pinAttemptsBeforeLockout != 0) {
    return null;
  }
  final doublings = failedCount ~/ pinAttemptsBeforeLockout - 1;
  // Past 5 doublings it's over the cap anyway; this keeps the shift small.
  final seconds = firstLockout.inSeconds << min(doublings, 10);
  return Duration(seconds: min(seconds, maxLockout.inSeconds));
}

/// Time left on a lockout ending at [until], or zero once it's over: the
/// "Try again in 0:28" on S66.
Duration lockoutLeft(DateTime? until, DateTime now) {
  if (until == null || !until.isAfter(now)) return Duration.zero;
  return until.difference(now);
}
