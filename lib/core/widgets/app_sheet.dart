import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet (DESIGN §6): `surface`, top corners 32, a handle,
/// then a header with an optional [leading] tile, [title] and [trailing]
/// (✕ close by default; Budgets passes "Remove"), then [builder]'s content.
/// A [floating] sheet (S47) sits 8 px in from the sides, rounded on all
/// corners, right above the keyboard.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  String? subtitle,
  Widget? leading,
  Widget? trailing,
  bool floating = false,
}) {
  final colors = context.colors;
  Widget sheet(BuildContext context) => AppSheet(
    title: title,
    subtitle: subtitle,
    leading: leading,
    trailing: trailing,
    child: builder(context),
  );
  return showModalBottomSheet<T>(
    context: context,
    // Above the tab shell, so the floating bottom bar can't cover the
    // sheet's lower half (keypad keys, Save).
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: floating ? Colors.transparent : colors.surface,
    elevation: 0,
    barrierColor: colors.scrim,
    shape: floating
        ? null
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.r32),
            ),
          ),
    builder: floating
        ? (context) {
            final keyboard = MediaQuery.viewInsetsOf(context).bottom;
            return Padding(
              // The keyboard inset goes outside the card, not inside it.
              padding: EdgeInsets.fromLTRB(
                8,
                0,
                8,
                keyboard > 0 ? keyboard : 8,
              ),
              child: MediaQuery.removeViewInsets(
                context: context,
                removeBottom: true,
                child: Material(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r32),
                  clipBehavior: Clip.antiAlias,
                  child: Builder(builder: sheet),
                ),
              ),
            );
          }
        : sheet,
  );
}

/// The sheet's frame; use [showAppSheet] to open one.
class AppSheet extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;

  /// A muted line under the title, e.g. S57's bill name.
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      // Keeps fields above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: ShapeDecoration(
                color: colors.stepOff,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
            child: Row(
              children: [
                if (leading case final leading?) ...[
                  leading,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: context.text.header.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ),
                      if (subtitle case final subtitle?)
                        Text(
                          subtitle,
                          style: context.text.body.copyWith(
                            color: colors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: context.l10n.close,
                      iconSize: 24,
                      color: colors.ink,
                      icon: const AppIconView(AppIcon.close),
                    ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
