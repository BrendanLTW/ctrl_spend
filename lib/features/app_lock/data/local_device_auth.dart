import 'package:ctrlspend/features/app_lock/domain/device_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// [DeviceAuth] on local_auth.
// shortcut: only exercised through fakes in tests; prompts are unverified
// on real devices until the next device run.
class LocalDeviceAuth implements DeviceAuth {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isDeviceSecure() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> canUseBiometrics() async {
    try {
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> confirm(String reason, {bool biometricOnly = true}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
      );
    } on PlatformException {
      return false;
    } on LocalAuthException {
      return false;
    }
  }
}
