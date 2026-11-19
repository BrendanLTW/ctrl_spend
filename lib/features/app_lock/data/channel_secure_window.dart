import 'dart:io';

import 'package:ctrlspend/features/app_lock/domain/secure_window.dart';
import 'package:flutter/services.dart';

/// [SecureWindow] through `MainActivity`'s channel. A no-op off Android.
class ChannelSecureWindow implements SecureWindow {
  static const _channel = MethodChannel('ctrlspend/secure_window');

  @override
  Future<void> setHidden({required bool hidden}) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('setSecure', hidden);
  }
}
