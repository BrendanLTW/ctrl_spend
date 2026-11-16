import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_auth.g.dart';

/// The phone's own ways to confirm it's you: biometrics, or its passcode
/// (S37, S38, S67).
abstract interface class DeviceAuth {
  /// Whether Face ID or a fingerprint is set up and can be used.
  Future<bool> canUseBiometrics();

  /// Shows the phone's prompt with [reason]. With [biometricOnly] false the
  /// phone's passcode is offered too. True when confirmed.
  Future<bool> confirm(String reason, {bool biometricOnly = true});
}

/// Overridden in `main.dart` with the local_auth one.
@Riverpod(keepAlive: true)
DeviceAuth deviceAuth(Ref ref) =>
    throw UnimplementedError('Override deviceAuthProvider');
