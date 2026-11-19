import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_spacing.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/list_group.dart';
import 'package:ctrlspend/core/widgets/primary_button.dart';
import 'package:ctrlspend/core/widgets/state_view.dart';
import 'package:ctrlspend/core/widgets/text_link.dart';
import 'package:ctrlspend/features/data_transfer/domain/import_summary.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/l10n/date_labels.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What was imported: the rows' summary, how many, and how many
/// duplicates were skipped.
typedef ImportDone = ({ImportSummary summary, int count, int skipped});

/// S53 Success: "Imported {n} transactions", what was skipped and added,
/// the counts and periods, then See in Activity or Back to Settings.
class ImportDoneView extends ConsumerWidget {
  const new({required this.done, super.key});

  final ImportDone done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final startDay =
        (ref.watch(preferencesProvider).value ?? const Preferences())
            .monthStartDay;
    final ImportDone(:summary, :count, :skipped) = done;
    final added = summary.newCategories;
    final periods = periodsSpanned(summary.first, summary.last, startDay);
    final body = [
      if (skipped > 0) l10n.importDuplicatesSkipped(skipped),
      if (added.isNotEmpty)
        l10n.importCategoriesAdded(
          added.length,
          added.length == 1
              ? added.single
              : l10n.listAnd(
                  added.take(added.length - 1).join(', '),
                  added.last,
                ),
        ),
    ].join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 110, bottom: 24),
            children: [
              StateView(
                icon: AppIcon.check,
                tone: StateTone.success,
                title: l10n.importedTransactions(count),
                body: body,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenX,
                ),
                child: ListGroup(
                  children: [
                    KeyValueRow(
                      label: l10n.expensesLabel,
                      value: '${summary.expenses}',
                    ),
                    KeyValueRow(
                      label: l10n.incomeLabel,
                      value: '${summary.income}',
                    ),
                    KeyValueRow(
                      label: l10n.periodsUpdated,
                      value: monthRangeLabel(
                        periods.start,
                        periods.end,
                        locale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            0,
            AppSpacing.screenX,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                label: l10n.seeInActivity,
                onPressed: () => context.go(Routes.activity),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextLink(
                  label: l10n.backToSettings,
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
