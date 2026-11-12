import 'dart:io';

import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/screens.dart';

/// Matches money in any supported currency: "RM 12.50", "S$ 5", "€ 3".
final _amount = RegExp(r'(RM|\$|€|Rp)\s?\d');

/// Every screen lays out at 200% text without errors, and no amount is cut
/// short with an ellipsis (DESIGN §10).
void main() {
  // The real font: the test font's square glyphs are far wider than
  // Poppins and would overflow where the app doesn't.
  setUpAll(() async {
    final loader = FontLoader('Poppins');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      final bytes = File('assets/fonts/Poppins-$weight.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  });

  for (final MapEntry(key: name, value: pump) in screens.entries) {
    testWidgets('$name works at 200% text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(tester, AppTheme.light);
      await tester.pumpAndSettle();
      final cut = [
        // Visible text only; screens under the current one don't count.
        for (final p in tester.renderObjectList<RenderParagraph>(
          find.byType(RichText),
        ))
          if (p.didExceedMaxLines && _amount.hasMatch(p.text.toPlainText()))
            p.text.toPlainText(),
      ];
      expect(cut, isEmpty, reason: 'amounts cut short');
      hideAppToast();
    });
  }
}
