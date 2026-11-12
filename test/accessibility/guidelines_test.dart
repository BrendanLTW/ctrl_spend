import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/screens.dart';

/// Every screen in both themes meets Flutter's accessibility guidelines:
/// tap targets (Android 48, iOS 44), labelled tap targets and text
/// contrast (DESIGN §10).
void main() {
  for (final MapEntry(key: name, value: pump) in screens.entries) {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('$name meets the guidelines in ${theme.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pump(tester, theme);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
        hideAppToast();
      });
    }
  }
}
