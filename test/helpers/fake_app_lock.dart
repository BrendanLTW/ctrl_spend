import 'package:ctrlspend/features/app_lock/domain/device_auth.dart';
import 'package:ctrlspend/features/app_lock/domain/pin_store.dart';
import 'package:ctrlspend/features/app_lock/domain/secure_window.dart';

/// Keeps the PIN in memory.
class FakePinStore implements PinStore {
  new([this.pin]);

  String? pin;

  @override
  Future<bool> hasPin() async => pin != null;

  @override
  Future<void> save(String pin) async => this.pin = pin;

  @override
  Future<bool> check(String pin) async => this.pin == pin;

  @override
  Future<void> clear() async => pin = null;
}

/// Answers the phone's prompts with [confirms]; records each reason.
class FakeDeviceAuth implements DeviceAuth {
  new({this.biometrics = true, this.confirms = true, this.secure = true});

  bool biometrics;

  /// Whether the phone has a passcode or biometrics at all.
  bool secure;
  bool confirms;
  final List<({String reason, bool biometricOnly})> prompts = [];

  @override
  Future<bool> isDeviceSecure() async => secure;

  @override
  Future<bool> canUseBiometrics() async => biometrics;

  @override
  Future<bool> confirm(String reason, {bool biometricOnly = true}) async {
    prompts.add((reason: reason, biometricOnly: biometricOnly));
    return confirms;
  }
}

/// Records whether the window is hidden from the app switcher.
class FakeSecureWindow implements SecureWindow {
  bool hidden = false;

  @override
  Future<void> setHidden({required bool hidden}) async => this.hidden = hidden;
}
