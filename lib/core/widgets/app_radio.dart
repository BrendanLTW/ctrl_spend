import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A 24 px radio (DESIGN §7): 2 px `control` ring off, 7 px `ink` ring on.
/// Custom so it looks the same on iOS and Android; with [onTap] it reads
/// as a radio button with a 44 px touch area.
class AppRadio extends StatelessWidget {
  const new({
    required this.selected,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final bool selected;
  final VoidCallback? onTap;

  /// Leave null when a label beside it already names the choice and the
  /// row is read as one.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final circle = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.ink : colors.control,
          width: selected ? 7 : 2,
        ),
      ),
    );
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      label: semanticLabel,
      onTap: onTap,
      child: onTap == null
          ? circle
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: SizedBox.square(
                dimension: 44,
                child: Center(child: circle),
              ),
            ),
    );
  }
}
