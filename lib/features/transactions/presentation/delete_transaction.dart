import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks with the S42 dialog, then deletes [transaction]. Resolves to true
/// if it was deleted. Income leaves out "goes back to your budget".
Future<bool> confirmAndDeleteTransaction(
  BuildContext context,
  WidgetRef ref, {
  required Transaction transaction,
  required Currency currency,
  Category? category,
}) async {
  final l10n = context.l10n;
  final amount = MoneyFormatter(currency).format(transaction.amountMinor);
  final confirmed = await showAppDialog(
    context,
    icon: Icons.delete_outline_rounded,
    title: l10n.deleteTransactionTitle,
    body: transaction.type == TransactionType.expense && category != null
        ? l10n.deleteExpenseBody(transaction.title, amount, category.name)
        : l10n.deleteIncomeBody(transaction.title, amount),
    confirmLabel: l10n.delete,
    destructive: true,
  );
  if (!confirmed) return false;
  await ref.read(transactionRepositoryProvider).delete(transaction.id);
  return true;
}
