import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet (DESIGN §6): `surface`, top corners 32, a handle,
/// then a header with an optional [leading] tile, [title] and [trailing]
/// (✕ close by default; Budgets passes "Remove"), then [builder]'s content.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  Widget? leading,
  Widget? trailing,
}) => showModalBottomSheet<T>(
  context: context,
  // Above the tab shell, so the floating bottom bar can't cover the
  // sheet's lower half (keypad keys, Save).
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r32)),
  ),
  builder: (context) => AppSheet(
    title: title,
    leading: leading,
    trailing: trailing,
    child: builder(context),
  ),
);

/// The sheet's frame; use [showAppSheet] to open one.
class AppSheet extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
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
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: context.text.header.copyWith(color: colors.ink),
                    ),
                  ),
                ),
                trailing ??
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: context.l10n.close,
                      iconSize: 24,
                      color: colors.ink,
                      icon: const Icon(Icons.close_rounded),
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
