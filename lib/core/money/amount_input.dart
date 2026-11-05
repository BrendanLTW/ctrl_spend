/// A money keypad key (PRD §6.1).
sealed class KeypadKey {
  const new();
}

final class DigitKey extends KeypadKey {
  const new(this.digit) : assert(digit >= 0 && digit <= 9, 'one digit');

  final int digit;
}

final class DoubleZeroKey extends KeypadKey {
  const new();
}

final class BackspaceKey extends KeypadKey {
  const new();
}

/// Largest amount the keypad accepts: 9 digits, RM 9,999,999.99.
const maxKeypadMinor = 999999999;

/// The amount in minor units after pressing [key]. Digits fill from the
/// cents: 1, 2, 5, 0 → 1250 (RM 12.50). A key that would pass
/// [maxKeypadMinor] is ignored.
int applyKey(int minor, KeypadKey key) {
  final next = switch (key) {
    DigitKey(:final digit) => minor * 10 + digit,
    DoubleZeroKey() => minor * 100,
    BackspaceKey() => minor ~/ 10,
  };
  return next > maxKeypadMinor ? minor : next;
}
