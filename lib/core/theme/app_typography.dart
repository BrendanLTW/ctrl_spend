import 'package:flutter/widgets.dart';

const _family = 'Poppins';
const _tabular = [FontFeature.tabularFigures()];

/// Text styles from DESIGN §4. Read them with `context.text`.
///
/// Styles carry no colour, so text takes `ink` from the theme unless a widget
/// sets one. `label` and `labelSm` are uppercase in the designs; the ARB copy
/// holds the uppercase text.
@immutable
class AppTypography {
  const new();

  TextStyle get display => const TextStyle(
    fontFamily: _family,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
    fontFeatures: _tabular,
  );

  /// Amount display inside sheets (Budgets edit).
  TextStyle get displaySm => const TextStyle(
    fontFamily: _family,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.1,
    fontFeatures: _tabular,
  );
  TextStyle get amount => const TextStyle(
    fontFamily: _family,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
    fontFeatures: _tabular,
  );
  TextStyle get pageTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    fontFeatures: _tabular,
  );
  TextStyle get header => const TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: _tabular,
  );
  TextStyle get rowTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    fontFeatures: _tabular,
  );
  TextStyle get rowTitleSm => const TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    fontFeatures: _tabular,
  );
  TextStyle get body => const TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFeatures: _tabular,
  );
  TextStyle get button => const TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1,
    fontFeatures: _tabular,
  );
  TextStyle get caption => const TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    fontFeatures: _tabular,
  );
  TextStyle get label => const TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    height: 1.3,
    fontFeatures: _tabular,
  );
  TextStyle get labelSm => const TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Active bottom-bar tab label.
  TextStyle get navLabel => const TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// Money keypad key, full screen.
  TextStyle get keypadKey => const TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1,
    fontFeatures: _tabular,
  );

  /// Money keypad key, in sheets.
  TextStyle get keypadKeySm => const TextStyle(
    fontFamily: _family,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1,
    fontFeatures: _tabular,
  );
  TextStyle get statValue => const TextStyle(
    fontFamily: _family,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: _tabular,
  );

  /// The Welcome headline (S02).
  TextStyle get welcomeTitle => const TextStyle(
    fontFamily: _family,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.15,
    fontFeatures: _tabular,
  );

  /// The splash wordmark: "ctrl" at this weight, "Spend" at w500 (DESIGN §2).
  TextStyle get wordmark => const TextStyle(
    fontFamily: _family,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    height: 1.1,
  );

  TextStyle get amountRow => const TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: _tabular,
  );
}

extension AppTypographyContext on BuildContext {
  AppTypography get text => const AppTypography();
}
