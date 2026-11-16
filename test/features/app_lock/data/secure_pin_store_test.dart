import 'package:ctrl_spend/features/app_lock/data/secure_pin_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('saves a salted hash, never the PIN, and checks against it', () async {
    final store = SecurePinStore();
    expect(await store.hasPin(), isFalse);
    expect(await store.check('2580'), isFalse);
    await store.save('2580');
    expect(await store.hasPin(), isTrue);
    expect(await store.check('2580'), isTrue);
    expect(await store.check('2581'), isFalse);
    final stored = await const FlutterSecureStorage().readAll();
    expect(stored.values, isNot(contains('2580')));
    expect(stored['app_lock_pin_hash'], hasLength(64), reason: 'SHA-256');
  });

  test('the same PIN saved twice gets a new salt', () async {
    final store = SecurePinStore();
    await store.save('2580');
    final first = await const FlutterSecureStorage().read(
      key: 'app_lock_pin_hash',
    );
    await store.save('2580');
    final second = await const FlutterSecureStorage().read(
      key: 'app_lock_pin_hash',
    );
    expect(first, isNot(second));
    expect(await store.check('2580'), isTrue);
  });

  test('clear forgets it', () async {
    final store = SecurePinStore();
    await store.save('2580');
    await store.clear();
    expect(await store.hasPin(), isFalse);
    expect(await store.check('2580'), isFalse);
    expect(await const FlutterSecureStorage().readAll(), isEmpty);
  });
}
