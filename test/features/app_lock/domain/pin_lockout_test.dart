import 'package:ctrlspend/features/app_lock/domain/pin_lockout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lockoutAfter', () {
    test('the first four wrong PINs and those in between do not pause', () {
      for (final count in [0, 1, 4, 6, 9, 11, 14]) {
        expect(lockoutAfter(count), isNull, reason: '$count');
      }
    });

    test('30 s after 5, doubling after each further 5', () {
      expect(
        [
          for (final count in [5, 10, 15, 20, 25]) lockoutAfter(count),
        ],
        const [
          Duration(seconds: 30),
          Duration(minutes: 1),
          Duration(minutes: 2),
          Duration(minutes: 4),
          Duration(minutes: 8),
        ],
      );
    });

    test('capped at 15 minutes, however many', () {
      expect(lockoutAfter(30), const Duration(minutes: 15));
      expect(lockoutAfter(35), const Duration(minutes: 15));
      expect(lockoutAfter(5000), const Duration(minutes: 15));
    });
  });

  group('lockoutLeft', () {
    final now = DateTime(2026, 11, 4, 9);

    test('counts down to the end', () {
      expect(
        lockoutLeft(now.add(const Duration(seconds: 28)), now),
        const Duration(seconds: 28),
      );
    });

    test('is zero when over or never set', () {
      expect(lockoutLeft(now, now), Duration.zero);
      expect(
        lockoutLeft(now.subtract(const Duration(seconds: 1)), now),
        Duration.zero,
      );
      expect(lockoutLeft(null, now), Duration.zero);
    });
  });
}
