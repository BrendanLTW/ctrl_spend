import 'package:ctrl_spend/core/period/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the clock defaults to the system time', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final before = DateTime.now();
    final now = container.read(clockProvider)();
    expect(now.isBefore(before), isFalse);
  });

  test('tests can fix the clock', () {
    final fixed = DateTime(2026, 11, 6, 9);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => fixed)],
    );
    addTearDown(container.dispose);
    expect(container.read(clockProvider)(), fixed);
  });
}
