import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The loading spinner (DESIGN §7): a 64 px ring, 6 px stroke, `raised`
/// track and an `ink` arc. Decorative: label what it's waiting for.
class AppSpinner extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: 64,
        child: CircularProgressIndicator(
          strokeWidth: 6,
          strokeAlign: BorderSide.strokeAlignInside,
          backgroundColor: colors.raised,
          color: colors.ink,
        ),
      ),
    );
  }
}
