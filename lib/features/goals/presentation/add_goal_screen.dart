import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/detail_rows.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/month_picker_sheet.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/presentation/category_style_pickers.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/domain/goal_calculations.dart';
import 'package:ctrl_spend/features/goals/domain/goal_repository.dart';
import 'package:ctrl_spend/features/goals/presentation/goal_style.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_amount_card.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S31 New goal, and Edit goal from S30 (with Delete). New goals open the
/// keypad straight away. Edit pops with true when the goal was deleted,
/// so S30 can close too.
class AddGoalScreen extends ConsumerStatefulWidget {
  const new({this.goalId, super.key});

  /// Set to edit that goal.
  final int? goalId;

  static const maxNameLength = 40;

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  int _target = 0;
  final _name = TextEditingController();
  late DateTime _month = DateTime(_today.year + 1, _today.month);
  CategoryIconKey _icon = CategoryIconKey.travel;
  Goal? _editing;

  bool get _isEdit => widget.goalId != null;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openKeypad());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _prefill(Goal goal) {
    _editing = goal;
    _target = goal.targetMinor;
    _name.text = goal.name;
    _month = goal.targetMonth;
    _icon = goal.iconKey;
  }

  Future<void> _openKeypad() => showKeypadSheet(
    context,
    initialMinor: _target,
    onChanged: (minor) => setState(() => _target = minor),
  );

  Future<void> _pickMonth() async {
    final month = await showMonthPickerSheet(
      context,
      title: context.l10n.targetDateRow,
      initial: _month,
      firstMonth: _today,
    );
    if (month != null) setState(() => _month = month);
  }

  Future<void> _save() async {
    final repository = ref.read(goalRepositoryProvider);
    final editing = _editing;
    if (editing == null) {
      await repository.add(
        name: _name.text,
        iconKey: _icon,
        targetMinor: _target,
        targetMonth: _month,
        createdAt: ref.read(clockProvider)(),
      );
    } else {
      await repository.update(
        editing.copyWith(
          name: _name.text,
          iconKey: _icon,
          targetMinor: _target,
          targetMonth: _month,
        ),
      );
    }
    if (mounted) context.pop();
  }

  Future<void> _delete(Goal goal) async {
    final l10n = context.l10n;
    final confirmed = await showAppDialog(
      context,
      icon: AppIcon.trash,
      title: l10n.deleteGoalTitle(goal.name),
      body: l10n.deleteGoalBody,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(goalRepositoryProvider).delete(goal.id);
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (_isEdit && _editing == null) {
      final found = ref
          .watch(goalsProvider)
          .value
          ?.where((g) => g.id == widget.goalId)
          .firstOrNull;
      if (found != null) _prefill(found);
    }
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final formatter = MoneyFormatter(currency);
    final editing = _editing;
    // The hint for a new goal: nothing saved yet.
    final preview = Goal(
      id: 0,
      name: '',
      iconKey: _icon,
      targetMinor: _target,
      targetMonth: _month,
      createdAt: _today,
    );

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const AppIconView(AppIcon.close),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEdit ? l10n.editGoal : l10n.newGoal,
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          if (editing != null)
            TextButton(
              onPressed: () => _delete(editing),
              style: TextButton.styleFrom(foregroundColor: colors.negative),
              child: Text(
                l10n.delete,
                style: text.rowTitle.copyWith(color: colors.negative),
              ),
            ),
        ],
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
                  8,
                  AppSpacing.screenX,
                  16,
                ),
                children: [
                  TransactionAmountCard(
                    label: l10n.targetAmount,
                    minor: _target,
                    currency: currency,
                    income: false,
                    onTap: _openKeypad,
                  ),
                  const SizedBox(height: AppSpacing.sectionTop),
                  SectionLabel(l10n.details),
                  ListGroup(
                    children: [
                      DetailNameRow(
                        label: l10n.billNameRow,
                        hint: l10n.goalNameHint,
                        controller: _name,
                        maxLength: AddGoalScreen.maxNameLength,
                        onChanged: () => setState(() {}),
                      ),
                      DetailRow(
                        label: l10n.targetDateRow,
                        value: DateFormat('MMM y', locale).format(_month),
                        onTap: _pickMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionTop),
                  SectionLabel(l10n.iconSection),
                  CategoryIconGrid(
                    icons: goalIcons,
                    tileColor: colors.surface,
                    selected: _icon,
                    onSelected: (icon) => setState(() => _icon = icon),
                  ),
                  if (_target > 0 && editing == null) ...[
                    const SizedBox(height: AppSpacing.cardGap),
                    _HintCard(
                      amount: l10n.goalHintAmount(
                        formatter.formatCompact(
                          monthlyNeedMinor(preview, 0, _today),
                        ),
                      ),
                      body: l10n.goalHintBody(
                        formatter.formatCompact(_target),
                        DateFormat.yMMMM(locale).format(_month),
                      ),
                    ),
                  ],
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
              child: PrimaryButton(
                label: _isEdit ? l10n.saveGoal : l10n.createGoal,
                onPressed: _target > 0 && _name.text.trim().isNotEmpty
                    ? _save
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "RM 616 a month / to reach RM 8,000 by December 2027", live.
class _HintCard extends StatelessWidget {
  const new({required this.amount, required this.body});

  final String amount;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$amount $body',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
        ),
        child: Row(
          children: [
            const CategoryTile(
              icon: AppIcon.calendar,
              color: CategoryColorKey.blue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amount,
                    style: text.rowTitle.copyWith(color: colors.ink),
                  ),
                  Text(body, style: text.body.copyWith(color: colors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
