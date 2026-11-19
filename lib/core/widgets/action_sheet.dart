import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/text_link.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// One action in an [showActionSheet]: a tile, a title, a short subtitle.
typedef ActionSheetItem<T> = ({
  T value,
  Widget tile,
  String title,
  String subtitle,
  bool destructive,
});

/// An action sheet (DESIGN §6, S62): a title, a list of actions on the
/// ground colour (the destructive one last, in `negative`, with no
/// chevron), then Cancel. Resolves to the chosen value, or null.
Future<T?> showActionSheet<T>(
  BuildContext context, {
  required String title,
  required List<ActionSheetItem<T>> items,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colors.surface,
  barrierColor: context.colors.scrim,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r32)),
  ),
  builder: (sheet) {
    final colors = sheet.colors;
    final text = sheet.text;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: text.header.copyWith(color: colors.ink),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: colors.ground,
                borderRadius: BorderRadius.circular(AppRadius.r28),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (i, item) in items.indexed) ...[
                      if (i > 0)
                        Divider(height: 1, thickness: 1, color: colors.divider),
                      _ActionRow(
                        item: item,
                        onTap: () => Navigator.of(sheet).pop(item.value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextLink(
              label: sheet.l10n.cancel,
              onPressed: () => Navigator.of(sheet).pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  },
);

class _ActionRow<T> extends StatelessWidget {
  const new({required this.item, required this.onTap});

  final ActionSheetItem<T> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      button: true,
      label: '${item.title}, ${item.subtitle}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              item.tile,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: text.rowTitle.copyWith(
                        color: item.destructive ? colors.negative : colors.ink,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: text.caption.copyWith(color: colors.muted),
                    ),
                  ],
                ),
              ),
              if (!item.destructive) ...[
                const SizedBox(width: 12),
                AppIconView(
                  AppIcon.chevronRight,
                  stroke: AppIconStroke.chevron,
                  size: 20,
                  color: colors.ink,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
