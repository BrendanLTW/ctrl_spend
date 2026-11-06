import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A 52 × 32 pill switch (DESIGN §7): `control` with a white thumb off,
/// `ink` with an `onInk` thumb on (so it stays visible in dark mode).
/// Custom so it looks the same on iOS and Android; it still reads as a
/// toggle. The touch area is 44 high.
class AppToggle extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: SizedBox(
          width: 52,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 52,
              height: 32,
              padding: const EdgeInsets.all(3),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: ShapeDecoration(
                color: value ? colors.ink : colors.control,
                shape: const StadiumBorder(),
              ),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: value ? colors.onInk : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Color.fromRGBO(16, 24, 40, 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
