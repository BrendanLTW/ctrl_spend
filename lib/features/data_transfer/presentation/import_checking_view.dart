import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_spacing.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_progress_bar.dart';
import 'package:ctrlspend/core/widgets/app_spinner.dart';
import 'package:ctrlspend/core/widgets/state_view.dart';
import 'package:ctrlspend/core/widgets/text_link.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// S51 Checking file: a spinner, "Row 128 of 214 · {file}", a progress
/// bar and Cancel, which stops the check and closes the flow.
class ImportCheckingView extends StatelessWidget {
  const new({
    required this.fileName,
    required this.checked,
    required this.total,
    super.key,
  });

  final String fileName;
  final int checked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final share = total == 0 ? 0.0 : checked / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 150, bottom: 24),
            children: [
              StateView(
                graphic: const AppSpinner(),
                title: l10n.importChecking,
                body: l10n.importCheckingRow(checked, total, fileName),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 22, 48, 0),
                child: AppProgressBar(
                  value: share,
                  semanticLabel: l10n.importCheckingLabel(
                    (share * 100).round(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 18, 40, 0),
                child: Text(
                  l10n.importCheckingNote,
                  textAlign: TextAlign.center,
                  style: context.text.caption.copyWith(color: colors.muted),
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
          child: Center(
            child: TextLink(label: l10n.cancel, onPressed: () => context.pop()),
          ),
        ),
      ],
    );
  }
}
