import 'package:ctrl_spend/core/theme/brand_colors.dart';
import 'package:flutter/material.dart';

/// The ctrlSpend symbol: an amber coin with a navy ⌃ caret (DESIGN §2).
/// Decorative; pair it with the wordmark or a label.
// shortcut: drawn in code until the brand board's SVG is exported to
// assets/brand/ (needs flutter_svg, not yet approved).
class BrandSymbol extends StatelessWidget {
  const new({this.size = 124, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _SymbolPainter()),
  );
}

class _SymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.drawCircle(
      size.center(Offset.zero),
      s / 2,
      Paint()..color = BrandColors.amber,
    );
    final caret = Path()
      ..moveTo(s * 0.33, s * 0.56)
      ..lineTo(s * 0.5, s * 0.39)
      ..lineTo(s * 0.67, s * 0.56);
    canvas.drawPath(
      caret,
      Paint()
        ..color = BrandColors.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SymbolPainter oldDelegate) => false;
}
