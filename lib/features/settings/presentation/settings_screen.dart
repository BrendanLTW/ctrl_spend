import 'package:ctrl_spend/core/app/app_version.dart';
import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_text_input.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/csv_import_flow.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/delete_all_data.dart';
import 'package:ctrl_spend/features/dev/presentation/sample_data_section.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S21a Settings (S21 in v1.1): the profile, preferences, data and a
/// version footer. v1.1 rows (App lock, Recurring bills, Savings goals)
/// are hidden in release builds.
class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  static const nameMaxLength = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    // The count includes archived categories (PRD §8).
    final categoryCount =
        (ref.watch(categoriesProvider()).value ?? const <Category>[]).length;
    final notificationsOn = [
      prefs.dailyReminderOn,
      prefs.budgetAlertsOn,
      prefs.weeklySummaryOn,
      // Bill reminders are v1.1, shown with the bills rows.
      if (kDebugMode) prefs.billRemindersOn,
    ].where((on) => on).length;
    final version = ref.watch(appVersionProvider).value;

    CategoryTile tile(AppIcon icon, CategoryColorKey color) =>
        CategoryTile(icon: icon, color: color);

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
          l10n.settings,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          _ProfileCard(
            name: prefs.userName,
            onTap: () => _editName(context, ref, prefs.userName),
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          SectionLabel(l10n.preferencesSection),
          ListGroup(
            children: [
              ListGroupRow(
                leading: tile(AppIcon.calendar, CategoryColorKey.orange),
                title: l10n.monthStartsOn,
                value: l10n.startDayLabel(prefs.monthStartDay),
                onTap: () => context.push(Routes.monthStart),
              ),
              ListGroupRow(
                leading: tile(AppIcon.palette, CategoryColorKey.purple),
                title: l10n.themeRow,
                value: switch (prefs.theme) {
                  AppTheme.light => l10n.themeLight,
                  AppTheme.dark => l10n.themeDark,
                  AppTheme.system => l10n.themeSystem,
                },
                onTap: () => context.push(Routes.theme),
              ),
              ListGroupRow(
                leading: tile(AppIcon.currency, CategoryColorKey.green),
                title: l10n.currency,
                value: Currency.fromCode(prefs.currencyCode).symbol,
                onTap: () => context.push(Routes.currency),
              ),
              ListGroupRow(
                leading: tile(AppIcon.bell, CategoryColorKey.yellow),
                title: l10n.notificationsRow,
                value: l10n.notificationsOnCount(notificationsOn),
                onTap: () => context.push(Routes.notificationSettings),
              ),
              // v1.1, shown in debug builds until task 5.9.
              if (kDebugMode)
                ListGroupRow(
                  leading: tile(AppIcon.lock, CategoryColorKey.red),
                  title: l10n.appLock,
                  value: prefs.appLockOn ? l10n.onLabel : l10n.offLabel,
                  onTap: () => context.push(Routes.appLock),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          SectionLabel(l10n.manageSection),
          ListGroup(
            children: [
              ListGroupRow(
                leading: tile(AppIcon.grid, CategoryColorKey.pink),
                title: l10n.categories,
                value: '$categoryCount',
                onTap: () => context.push(Routes.categories),
              ),
              // v1.1 rows show in debug builds until task 5.9 unhides them.
              if (kDebugMode)
                ListGroupRow(
                  leading: tile(AppIcon.receipt, CategoryColorKey.yellow),
                  title: l10n.recurringBills,
                  onTap: () => context.push(Routes.bills),
                ),
              if (kDebugMode)
                ListGroupRow(
                  leading: tile(AppIcon.target, CategoryColorKey.green),
                  title: l10n.savingsGoals,
                  onTap: () => context.push(Routes.goals),
                ),
              ListGroupRow(
                leading: tile(AppIcon.download, CategoryColorKey.blue),
                title: l10n.exportCsv,
                onTap: () => context.push(Routes.export),
              ),
              ListGroupRow(
                leading: tile(AppIcon.upload, CategoryColorKey.blue),
                title: l10n.importCsv,
                onTap: () => importCsv(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          SectionLabel(l10n.dataSection),
          ListGroup(
            children: [
              ListGroupRow(
                leading: tile(AppIcon.trash, CategoryColorKey.red),
                title: l10n.eraseAllData,
                titleColor: colors.negative,
                onTap: () => confirmAndDeleteAllData(context, ref),
              ),
            ],
          ),
          if (version != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
              child: Text(
                l10n.settingsFooter(shortVersion(version)),
                style: text.caption.copyWith(color: colors.muted),
              ),
            ),
          const SampleDataSection(),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final name = await showAppSheet<String>(
      context,
      title: context.l10n.nameSheetTitle,
      floating: true,
      builder: (_) => _NameSheetBody(initial: current),
    );
    if (name == null) return;
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(userName: name));
  }
}

/// The avatar, name and "Data stored on this phone"; tap to rename.
class _ProfileCard extends StatelessWidget {
  const new({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final trimmed = name.trim();
    return Semantics(
      button: true,
      label: l10n.profileLabel(
        trimmed.isEmpty ? l10n.greetingNoName : trimmed,
        l10n.profileSubtitle,
      ),
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: trimmed.isEmpty
                      ? AppIconView(AppIcon.user, color: colors.onInk)
                      : Text(
                          trimmed.characters.first.toUpperCase(),
                          style: text.stateTitle.copyWith(color: colors.onInk),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trimmed.isEmpty ? l10n.greetingNoName : trimmed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.profileName.copyWith(color: colors.ink),
                      ),
                      Text(
                        l10n.profileSubtitle,
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppIconView(AppIcon.chevronRight, size: 20, color: colors.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// S47: the name field, a helper line with the counter, and Save, with
/// S03a's rules: trimmed, at most 30 characters, not blank. Pops with the
/// new name.
class _NameSheetBody extends StatefulWidget {
  const new({required this.initial});

  final String initial;

  @override
  State<_NameSheetBody> createState() => _NameSheetBodyState();
}

class _NameSheetBodyState extends State<_NameSheetBody> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextInput(
          controller: _name,
          label: l10n.firstName,
          hint: l10n.firstName,
          helper: l10n.nameHelper,
          background: context.colors.ground,
          maxLength: SettingsScreen.nameMaxLength,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: l10n.save,
          size: PrimaryButtonSize.sheet,
          onPressed: _name.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}
