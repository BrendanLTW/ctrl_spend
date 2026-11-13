import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Colours outside `core/theme/` that are deliberate, with how many times
/// each file may use them and why (docs/quality-audit.md). Anything
/// else must come from the theme tokens.
const _allowed = {
  // White on the hero, which is dark in both themes (DESIGN §7).
  'lib/core/widgets/budget_hero.dart': 2,
  'lib/core/widgets/app_progress_bar.dart': 1,
  'lib/features/onboarding/presentation/welcome_preview.dart': 2,
  // White text and a darker press on the light theme's red, for 4.5:1.
  'lib/core/widgets/pill_button.dart': 2,
  'lib/core/widgets/swipe_to_delete.dart': 1,
  // The toggle's knob is white when off in both themes (DESIGN §7).
  'lib/core/widgets/app_toggle.dart': 1,
};

final _literal = RegExp(
  r'\bColor\(0x|\bColor\.from(RGBO|ARGB)|\bColors\.(?!transparent\b)\w+',
);

void main() {
  test('widgets take colours from the theme', () {
    final found = <String, int>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              !f.path.startsWith('lib/core/theme/') &&
              !f.path.endsWith('.g.dart') &&
              !f.path.endsWith('.freezed.dart') &&
              !f.path.startsWith('lib/l10n/app_localizations'),
        );
    for (final file in files) {
      final count = _literal.allMatches(file.readAsStringSync()).length;
      if (count > 0) found[file.path] = count;
    }
    expect(found, _allowed);
  });
}
