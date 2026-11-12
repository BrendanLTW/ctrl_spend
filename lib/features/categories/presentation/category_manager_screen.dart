import 'dart:async';

import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/pill_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/swipe_to_delete.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/categories/presentation/add_category_sheet.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S22 Category manager: expense and income categories, the archived ones
/// with Restore, and Add (S24). Swipe a row left to remove it: the
/// repository deletes it if unused, otherwise archives it.
class CategoryManagerScreen extends ConsumerWidget {
  const new({super.key});

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = context.l10n;
    final result = await ref
        .read(categoryRepositoryProvider)
        .remove(category.id);
    if (!context.mounted) return;
    showAppToast(
      context,
      message: switch (result) {
        CategoryRemoval.deleted => l10n.categoryDeleted,
        CategoryRemoval.archived => l10n.categoryArchived(category.name),
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final all = ref.watch(categoriesProvider()).value ?? const <Category>[];
    final active = [
      for (final c in all)
        if (!c.archived) c,
    ];
    final archived = [
      for (final c in all)
        if (c.archived) c,
    ];

    Widget group(String label, List<Category> categories) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        ListGroup(
          children: [
            for (final c in categories)
              SwipeToDelete(
                key: ValueKey(c.id),
                deleteLabel: l10n.delete,
                radius: 0,
                onDelete: () => _remove(context, ref, c),
                child: ColoredBox(
                  color: colors.surface,
                  child: ListGroupRow(
                    leading: CategoryTile.forKey(c.iconKey, color: c.colorKey),
                    title: c.name,
                    onTap: () => unawaited(context.push(Routes.category(c.id))),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionTop),
      ],
    );

    final expense = [
      for (final c in active)
        if (c.type == TransactionType.expense) c,
    ];
    final income = [
      for (final c in active)
        if (c.type == TransactionType.income) c,
    ];

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
          l10n.categories,
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => showAddCategorySheet(context),
            style: TextButton.styleFrom(foregroundColor: colors.ink),
            child: Text(
              l10n.add,
              style: text.rowTitle.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          if (expense.isNotEmpty) group(l10n.expenseLabel, expense),
          if (income.isNotEmpty) group(l10n.incomeLabel, income),
          if (archived.isNotEmpty) ...[
            SectionLabel(l10n.archivedSection),
            ListGroup(
              children: [
                for (final c in archived)
                  _ArchivedRow(
                    category: c,
                    onRestore: () =>
                        ref.read(categoryRepositoryProvider).restore(c.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.textX - AppSpacing.screenX,
            ),
            child: Text(
              l10n.categoriesNote,
              style: text.body.copyWith(color: colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// An archived category, muted, with a Restore pill.
class _ArchivedRow extends StatelessWidget {
  const new({required this.category, required this.onRestore});

  final Category category;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
        child: Row(
          children: [
            Opacity(
              opacity: 0.6,
              child: CategoryTile.forKey(
                category.iconKey,
                color: category.colorKey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category.name,
                style: context.text.rowTitle.copyWith(color: colors.muted),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: PillButton(
                label: context.l10n.restore,
                style: PillButtonStyle.soft,
                onPressed: onRestore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
