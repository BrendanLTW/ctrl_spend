import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// A ring of round-capped arcs, one per segment, sized by its weight
/// (S02, S18, S40). [gap] is the angle between arcs, beyond what the round
/// caps take up; a single segment is drawn as a full ring. The ring's
/// centre line sits one [stroke] in from the edge, leaving half a stroke
/// of margin.
class DonutPainter extends CustomPainter {
  const new({
    required this.segments,
    required this.stroke,
    required this.gap,
    this.startAngle = -math.pi / 2,
  });

  final List<(Color, double)> segments;
  final double stroke;
  final double gap;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.$2);
    if (total <= 0) return;
    final radius = math.min(size.width, size.height) / 2 - stroke;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    if (segments.length == 1) {
      canvas.drawCircle(rect.center, radius, paint..color = segments.first.$1);
      return;
    }
    final available = 2 * math.pi - gap * segments.length;
    var start = startAngle;
    for (final (color, weight) in segments) {
      final sweep = weight / total * available;
      canvas.drawArc(rect, start, sweep, false, paint..color = color);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(DonutPainter oldDelegate) =>
      !_sameSegments(segments, oldDelegate.segments) ||
      stroke != oldDelegate.stroke ||
      gap != oldDelegate.gap ||
      startAngle != oldDelegate.startAngle;

  static bool _sameSegments(List<(Color, double)> a, List<(Color, double)> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
