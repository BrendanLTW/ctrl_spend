import 'package:flutter/painting.dart';

/// Chart series colours (DESIGN §3.4). The same in light and dark.
abstract final class ChartPalette {
  static const orange = Color(0xFFFB8C00);
  static const pink = Color(0xFFF0457A);
  static const blue = Color(0xFF2196F3);
  static const yellow = Color(0xFFF5B800);
  static const purple = Color(0xFF7C4DDB);

  // shortcut: DESIGN §3.4 has no green or red series; these reuse the light
  // category icon colours. Replace once the design defines them.
  static const green = Color(0xFF1E8A43);
  static const red = Color(0xFFD92D20);

  /// Over budget or over pace.
  static const over = Color(0xFFF97066);

  /// Under budget or under pace.
  static const under = Color(0xFF98A2B3);
}
