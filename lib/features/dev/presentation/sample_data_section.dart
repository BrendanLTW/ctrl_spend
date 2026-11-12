import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/dev/domain/sample_data.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S21's Developer section, in debug builds only: adds 5,000 sample
/// transactions for performance checks (task 4.3). Nothing in release.
class SampleDataSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();
    final l10n = context.l10n;

    Future<void> add() async {
      await ref
          .read(transactionRepositoryProvider)
          .importAll(sampleTransactions(today: ref.read(clockProvider)()));
      if (context.mounted) {
        showAppToast(context, message: l10n.devSampleDataAdded, success: true);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sectionTop),
        SectionLabel(l10n.devSection),
        ListGroup(
          children: [
            ListGroupRow(
              title: l10n.devAddSampleData,
              subtitle: l10n.devAddSampleDataDetail,
              onTap: add,
            ),
          ],
        ),
      ],
    );
  }
}
