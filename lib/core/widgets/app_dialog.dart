import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_shadows.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/theme/category_palette.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/pill_button.dart';
import 'package:ctrlspend/core/widgets/primary_button.dart';
import 'package:ctrlspend/core/widgets/text_link.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// How a dialog is drawn. Each screen uses the one its design shows.
enum AppDialogLayout {
  /// S42: radius 28, a 60 px icon, pill buttons.
  compact,

  /// S49 (DESIGN §6): radius 30, 20 px from the edges, a 96 px state
  /// icon, a 56 px confirm button and a plain Cancel.
  state,
}

/// Opens a confirmation dialog (DESIGN §6, S42). Resolves to true when the
/// confirm action is chosen, false on Cancel or dismiss.
Future<bool> showAppDialog(
  BuildContext context, {
  required AppIcon icon,
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
  AppDialogLayout layout = AppDialogLayout.compact,
  Widget? link,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: context.colors.scrim,
      builder: (_) => AppDialog(
        icon: icon,
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        destructive: destructive,
        layout: layout,
        link: link,
      ),
    ) ??
    false;

/// The dialog's content; use [showAppDialog] to open one.
class AppDialog extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.destructive = false,
    this.layout = AppDialogLayout.compact,
    this.link,
    super.key,
  });

  final AppDialogLayout layout;

  final AppIcon icon;
  final String title;
  final String body;
  final String confirmLabel;

  /// Red confirm button and icon, e.g. Delete.
  final bool destructive;

  /// A text link above the buttons, e.g. "Export first" before Delete all
  /// data.
  final Widget? link;

  @override
  Widget build(BuildContext context) {
    if (layout == AppDialogLayout.state) return _buildState(context);
    final colors = context.colors;
    final text = context.text;
    final tint = context.categoryColors.of(
      destructive ? CategoryColorKey.red : CategoryColorKey.neutral,
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
          boxShadow: context.shadows.dialog,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: tint.tile,
                  shape: BoxShape.circle,
                ),
                child: AppIconView(icon, size: 26, color: tint.icon),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: text.header.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.muted),
            ),
            if (link case final link?) ...[
              const SizedBox(height: 8),
              link,
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 24),
            PillButton(
              label: confirmLabel,
              style: destructive
                  ? PillButtonStyle.destructive
                  : PillButtonStyle.primary,
              expand: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            PillButton(
              label: context.l10n.cancel,
              style: PillButtonStyle.soft,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildState(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final (circle, glyph) = destructive
        ? (colors.errorBox, colors.negative)
        : (colors.raised, colors.ink);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r30),
          boxShadow: context.shadows.dialog,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: circle,
                      shape: BoxShape.circle,
                    ),
                    child: AppIconView(
                      icon,
                      size: 40,
                      stroke: 1.7,
                      color: glyph,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: text.header.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: text.body.copyWith(color: colors.muted),
              ),
              if (link case final link?) ...[
                const SizedBox(height: 4),
                Center(child: link),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: confirmLabel,
                size: PrimaryButtonSize.sheet,
                destructive: destructive,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 6),
              TextLink(
                label: context.l10n.cancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
