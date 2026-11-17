/// Corner radii from DESIGN §5.
abstract final class AppRadius {
  /// Small inner elements.
  static const double r12 = 12;

  /// Icon tiles, keypad keys in sheets.
  static const double r16 = 16;

  /// Message boxes, text inputs, compact fields, picker tiles, segmented
  /// segments, day selector.
  static const double r18 = 18;

  /// Fields, toast, category tile buttons, empty-state icon.
  static const double r20 = 20;

  /// Rows, chart cards, segmented control track.
  static const double r24 = 24;

  /// List groups, budget cards, dialogs, empty-state card.
  static const double r28 = 28;

  /// Dialogs in the S49 style.
  static const double r30 = 30;

  /// Hero card, bottom-sheet top corners.
  static const double r32 = 32;

  /// Chips, search, bottom bar, progress bars, pill buttons, toggles.
  static const double pill = 999;
}
