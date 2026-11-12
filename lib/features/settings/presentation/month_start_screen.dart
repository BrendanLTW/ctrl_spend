import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/day_selector.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S32 Month start: a day 1–28 or the last day of the month, with the
/// current and next period it gives. Save stores it; back discards it.
/// Every period, figure and chart follows through `periodFor`.
class MonthStartScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<MonthStartScreen> createState() => _MonthStartScreenState();
}

class _MonthStartScreenState extends ConsumerState<MonthStartScreen> {
  late MonthStartDay _selected =
      (ref.read(preferencesProvider).value ?? const Preferences())
          .monthStartDay;

  static const _perRow = 7;

  Future<void> _save() async {
    final chosen = _selected;
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(monthStartDay: chosen));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final current = periodFor(ref.watch(clockProvider)(), _selected);
    final next = periodFor(
      DateTime(current.end.year, current.end.month, current.end.day + 1),
      _selected,
    );

    Widget day(int d) => DaySelector(
      label: '$d',
      semanticLabel: l10n.ordinalDay('$d'),
      compact: true,
      selected: _selected == DayOfMonth(d),
      onTap: () => setState(() => _selected = DayOfMonth(d)),
    );

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const AppIconView(
            AppIcon.chevronLeft,
            stroke: AppIconStroke.chevron,
            size: 30,
          ),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.monthStartsOn,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  4,
                  AppSpacing.screenX,
                  16,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.textX - AppSpacing.screenX,
                    ),
                    child: Text(
                      l10n.monthStartSubtitle,
                      style: text.body.copyWith(color: colors.muted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (var row = 0; row * _perRow < 28; row++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          for (var col = 0; col < _perRow; col++) ...[
                            if (col > 0) const SizedBox(width: 8),
                            Expanded(child: day(row * _perRow + col + 1)),
                          ],
                        ],
                      ),
                    ),
                  DaySelector(
                    label: l10n.lastDayOfMonth,
                    compact: true,
                    selected: _selected is LastDayOfMonth,
                    onTap: () =>
                        setState(() => _selected = const LastDayOfMonth()),
                  ),
                  const SizedBox(height: 20),
                  ListGroup(
                    children: [
                      KeyValueRow(
                        label: l10n.currentPeriod,
                        value: formatPeriod(current, locale),
                      ),
                      KeyValueRow(
                        label: l10n.nextPeriod,
                        value: formatPeriod(next, locale),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                12,
              ),
              child: PrimaryButton(label: l10n.save, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}
