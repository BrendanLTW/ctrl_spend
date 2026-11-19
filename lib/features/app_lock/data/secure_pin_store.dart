import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:ctrlspend/features/app_lock/domain/pin_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [PinStore] in the Keychain or Android Keystore. Only a random salt and
/// the salted SHA-256 are kept, so the PIN itself is never stored. A
/// 4-digit PIN can't resist a brute force of its hash; the secure storage
/// is what protects it.
class SecurePinStore implements PinStore {
  new([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _hashKey = 'app_lock_pin_hash';
  static const _saltKey = 'app_lock_pin_salt';

  static String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  @override
  Future<bool> hasPin() async => await _storage.read(key: _hashKey) != null;

  @override
  Future<void> save(String pin) async {
    final random = Random.secure();
    final salt = base64Url.encode([
      for (var i = 0; i < 16; i++) random.nextInt(256),
    ]);
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: _hash(pin, salt));
  }

  @override
  Future<bool> check(String pin) async {
    final salt = await _storage.read(key: _saltKey);
    final hash = await _storage.read(key: _hashKey);
    return salt != null && hash != null && _hash(pin, salt) == hash;
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
  }
}
