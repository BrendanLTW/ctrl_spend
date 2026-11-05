import 'package:ctrl_spend/core/money/amount_input.dart';
import 'package:flutter_test/flutter_test.dart';

int type(List<KeypadKey> keys, {int from = 0}) => keys.fold(from, applyKey);

List<KeypadKey> digits(String s) => [
  for (final c in s.split('')) DigitKey(int.parse(c)),
];

void main() {
  test('digits fill from the cents', () {
    expect(type(digits('1250')), 1250);
    expect(type(digits('1')), 1);
    expect(type(digits('12')), 12);
  });

  test('a leading 0 or 00 keeps the amount at 0', () {
    expect(type([const DigitKey(0), const DoubleZeroKey()]), 0);
    expect(type([const DoubleZeroKey(), ...digits('5')]), 5);
  });

  test('00 appends two zeros', () {
    expect(type([...digits('2'), const DoubleZeroKey()]), 200);
    expect(
      type([...digits('20'), const DoubleZeroKey(), const DoubleZeroKey()]),
      200000,
    );
  });

  test('backspace removes the last digit and stops at 0', () {
    expect(type([...digits('1250'), const BackspaceKey()]), 125);
    expect(type([const BackspaceKey()]), 0);
    expect(
      type([...digits('7'), const BackspaceKey(), const BackspaceKey()]),
      0,
    );
  });

  group('9-digit cap', () {
    test('a ninth digit is accepted', () {
      expect(type(digits('123456789')), 123456789);
      expect(type(digits('999999999')), maxKeypadMinor);
    });

    test('a tenth digit is ignored', () {
      expect(type(digits('1234567890')), 123456789);
    });

    test('00 needs room for both zeros', () {
      final eight = type(digits('12345678'));
      expect(applyKey(eight, const DoubleZeroKey()), eight);
      final seven = type(digits('1234567'));
      expect(applyKey(seven, const DoubleZeroKey()), 123456700);
    });

    test('backspace still works at the cap', () {
      expect(applyKey(maxKeypadMinor, const BackspaceKey()), 99999999);
    });
  });
}
