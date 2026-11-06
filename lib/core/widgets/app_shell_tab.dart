import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// One bottom-bar item. Icon-only, or a `navSelected` pill with icon and
/// label when [selected]. Screen readers always hear the label.
class AppShellTab extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 52;

  /// Narrowest an icon-only tab may get (CLAUDE.md touch target).
  static const double minWidth = 44;
  static const double iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.navSelected : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 0),
              child: Row(
                mainAxisSize: selected ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: iconSize, color: colors.ink),
                  if (selected)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.navLabel.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
