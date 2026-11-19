import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/features/app_lock/domain/pin_lockout.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Counts a wrong PIN, starting the S66 pause on every fifth.
Future<void> recordWrongPin(WidgetRef ref) {
  final now = ref.read(clockProvider)();
  return ref.read(preferencesRepositoryProvider).update((p) {
    final failed = p.failedPinCount + 1;
    final pause = lockoutAfter(failed);
    return p.copyWith(
      failedPinCount: failed,
      lockoutUntil: pause == null ? p.lockoutUntil : now.add(pause),
    );
  });
}

/// Clears the count once the right PIN (or a reset) gets in.
Future<void> clearWrongPins(WidgetRef ref) => ref
    .read(preferencesRepositoryProvider)
    .update((p) => p.copyWith(failedPinCount: 0, lockoutUntil: null));
