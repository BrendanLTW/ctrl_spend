import 'dart:math' as math;

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S02's illustration of the dashboard, with fixed sample figures. Read as
/// one label by screen readers.
class WelcomePreview extends StatelessWidget {
  const new({super.key});

  static const _spentMinor = 76000;
  static const _leftMinor = 124000;
  static const _budgetMinor = 200000;
  static const _sampleExpenseMinor = 1820;
  static const _foodPercent = 82;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    const formatter = MoneyFormatter(Currency.myr);
    return Semantics(
      label: l10n.welcomePreviewLabel(formatter.format(_leftMinor)),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.hero,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _Chip(
                  icon: CategoryIconKey.food,
                  color: CategoryColorKey.orange,
                  label: l10n.categoryPercent(l10n.categoryFood, _foodPercent),
                ),
                const Spacer(),
                _Chip(
                  icon: CategoryIconKey.car,
                  color: CategoryColorKey.blue,
                  label: formatter.format(
                    _sampleExpenseMinor,
                    sign: MoneySign.expense,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _DonutPainter(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        // Whole units only, as in the design.
                        formatter.split(_spentMinor).head,
                        // White on the hero in both themes (DESIGN §7).
                        style: text.pageTitle.copyWith(color: Colors.white),
                      ),
                      Text(
                        l10n.spent,
                        style: text.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.leftToSpend.toUpperCase(),
                    style: text.label.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 2),
                  AmountText(
                    _leftMinor,
                    currency: Currency.myr,
                    style: text.amount.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 12),
                  const AppProgressBar(
                    value: _spentMinor / _budgetMinor,
                    semanticLabel: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const new({required this.icon, required this.color, required this.label});

  final CategoryIconKey icon;
  final CategoryColorKey color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tile = context.categoryColors.of(color);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      decoration: ShapeDecoration(
        color: colors.surface,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: tile.tile, shape: BoxShape.circle),
            child: Icon(categoryIcon(icon), size: 16, color: tile.icon),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: context.text.rowTitleSm.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}

/// Sample category arcs; an illustration, not a chart (S02).
class _DonutPainter extends CustomPainter {
  static const List<(Color, double)> _segments = [
    (ChartPalette.orange, 0.36),
    (ChartPalette.pink, 0.20),
    (ChartPalette.blue, 0.17),
    (ChartPalette.yellow, 0.12),
    (ChartPalette.purple, 0.08),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    // Room between arcs, beyond what the round caps take up (DESIGN S02).
    const gap = 0.55;
    final radius = math.min(size.width, size.height) / 2 - stroke;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final total = _segments.fold<double>(0, (sum, s) => sum + s.$2);
    final available = 2 * math.pi - gap * _segments.length;
    var start = -math.pi / 2.6;
    for (final (color, share) in _segments) {
      final sweep = share / total * available;
      canvas.drawArc(rect, start, sweep, false, paint..color = color);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) => false;
}
