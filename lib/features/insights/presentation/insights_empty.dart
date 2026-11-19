import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/widgets/empty_state.dart';
import 'package:ctrlspend/features/insights/presentation/spending_donut.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// S40: no spending to chart yet, with an empty ring and Add an expense.
class InsightsEmpty extends StatelessWidget {
  const new({required this.currency, super.key});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: EmptyState(
        card: false,
        graphic: SpendingDonut(
          segments: const [],
          caption: l10n.spentLabel,
          totalMinor: 0,
          currency: currency,
          semanticLabel: '',
        ),
        title: l10n.insightsEmptyTitle,
        body: l10n.insightsEmptyBody,
        actionLabel: l10n.addAnExpense,
        onAction: () => context.push(Routes.add),
      ),
    );
  }
}
