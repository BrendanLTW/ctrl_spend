import 'package:ctrlspend/features/app_lock/domain/lock_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final left = DateTime(2026, 11, 4, 9);

  test('never away: no lock', () {
    expect(
      shouldLock(awaySince: null, now: left, lockAfterMinutes: 0),
      isFalse,
    );
  });

  test('Immediately locks after any time away', () {
    expect(shouldLock(awaySince: left, now: left, lockAfterMinutes: 0), isTrue);
  });

  test('locks once the Lock after time has passed, not before', () {
    bool after(Duration away, int minutes) => shouldLock(
      awaySince: left,
      now: left.add(away),
      lockAfterMinutes: minutes,
    );
    expect(after(const Duration(minutes: 4, seconds: 59), 5), isFalse);
    expect(after(const Duration(minutes: 5), 5), isTrue);
    expect(after(const Duration(minutes: 59), 60), isFalse);
    expect(after(const Duration(hours: 2), 60), isTrue);
  });
}
