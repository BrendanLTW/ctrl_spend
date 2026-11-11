import 'dart:async';

import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// The toast (DESIGN §7): `ink` fill, message, optional action. The action
/// is amber on the dark toast and dark amber on the light (dark-mode) one,
/// which are the other theme's `warning`.
class AppToast extends StatelessWidget {
  const new({required this.message, this.actionLabel, this.onAction, super.key})
    : assert((actionLabel == null) == (onAction == null), 'label + action');

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final actionColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.dark.warning
        : AppColors.light.warning;
    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.only(left: 20, right: 8),
        decoration: BoxDecoration(
          color: colors.ink,
          borderRadius: BorderRadius.circular(AppRadius.r20),
          boxShadow: context.shadows.toast,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  message,
                  style: text.body.copyWith(
                    color: colors.onInk,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if ((actionLabel, onAction) case (final label?, final onTap?))
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor: actionColor,
                  overlayColor: colors.onInk,
                ),
                child: Text(
                  label,
                  style: text.rowTitleSm.copyWith(
                    color: actionColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

({OverlayEntry entry, Timer timer})? _current;

/// Shows a toast above the bottom bar for [duration], replacing any toast
/// already showing. Tapping the action runs [onAction] and hides it.
void showAppToast(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 5),
}) {
  hideAppToast();
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 16,
      right: 16,
      // DESIGN §7: 106 px from the bottom, clear of the bar.
      bottom: 106 + MediaQuery.paddingOf(context).bottom,
      child: Material(
        type: MaterialType.transparency,
        child: AppToast(
          message: message,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  hideAppToast();
                  onAction();
                },
        ),
      ),
    ),
  );
  overlay.insert(entry);
  _current = (entry: entry, timer: Timer(duration, hideAppToast));
}

/// Hides the current toast, if any.
void hideAppToast() {
  final current = _current;
  _current = null;
  if (current == null) return;
  current.timer.cancel();
  // If its overlay is already gone (the app was torn down), there's
  // nothing to remove, and disposing would assert.
  if (current.entry.mounted) {
    current.entry
      ..remove()
      ..dispose();
  }
}
