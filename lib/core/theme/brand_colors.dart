import 'package:flutter/painting.dart';

/// Brand colours (DESIGN §2): the logo, the app icon and the splash only.
/// The same in light and dark.
abstract final class BrandColors {
  /// The budget ring and the splash loader. Never elsewhere in the UI.
  static const green = Color(0xFF22C55E);

  /// The splash background in light mode.
  static const navy = Color(0xFF101828);

  /// The wordmark: "ctrl" grey and "Spend" ink, on light and dark.
  static const wordmarkCtrl = Color(0xFF5D6169);
  static const wordmarkSpend = Color(0xFF15171C);
  static const wordmarkCtrlOnDark = Color(0xFF8A8F99);
  static const wordmarkSpendOnDark = Color(0xFFFFFFFF);
}
