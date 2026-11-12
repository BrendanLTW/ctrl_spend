import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_transfer/presentation/import_test.dart'
    show pumpSettings, transactions;

void main() {
  testWidgets('debug builds can add 5,000 sample transactions', (tester) async {
    await pumpSettings(tester);
    await tester.scrollUntilVisible(
      find.text('Add 5,000 sample transactions'),
      200,
    );
    expect(find.text('DEVELOPER'), findsOneWidget);
    await tester.ensureVisible(find.text('Add 5,000 sample transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 5,000 sample transactions'));
    // Let the save start before settling, or settle can return first.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(transactions.all, hasLength(5000));
    expect(find.text('Added 5,000 sample transactions'), findsOneWidget);
    hideAppToast();
  });
}
