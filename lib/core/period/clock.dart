import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Returns the current time. Domain code reads time through this, never
/// `DateTime.now()` directly, so tests can fix it.
typedef Clock = DateTime Function();

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => DateTime.now;
