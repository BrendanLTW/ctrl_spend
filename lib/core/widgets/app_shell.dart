import 'dart:math' as math;

import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/widgets/app_shell_tab.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The tab scaffold (DESIGN §6): content runs full height under a floating
/// pill bottom bar, with a separate round add button to its right.
///
/// Tab screens keep [contentBottomPadding] at the end of their scroll views
/// so the last item clears the bar.
class AppShell extends StatelessWidget {
  const new({
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAdd,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAdd;
  final Widget child;

  static const double contentBottomPadding = 120;
  static const double barHeight = 68;
  static const double barMaxWidth = 278;
  static const double addSize = 64;

  static const double _edge = 16;
  static const double _barBottom = 24;
  static const double _addBottom = 26;
  static const double _barInset = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.shadows;
    final l10n = context.l10n;
    // shortcut: Material outlined icons stand in for the designs' 1.7-stroke
    // line icons; swap for an AppIcon set once the SVGs are exported.
    final tabs = [
      (Icons.home_outlined, l10n.tabHome),
      (Icons.receipt_long_outlined, l10n.tabActivity),
      (Icons.pie_chart_outline, l10n.tabBudgets),
      (Icons.insert_chart_outlined, l10n.tabInsights),
    ];
    // Narrow phones shrink the bar so it never meets the add button.
    final barWidth = math.min(
      barMaxWidth,
      MediaQuery.sizeOf(context).width - _edge * 3 - addSize,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: _edge,
            bottom: _barBottom,
            width: barWidth,
            height: barHeight,
            // shortcut: the label is sized for up to 1.3x text; larger scales
            // clamp here, since the bar has a fixed height.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: shadows.bottomBar,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_barInset),
                  child: Row(
                    children: [
                      for (final (i, (icon, label)) in tabs.indexed)
                        if (i == currentIndex)
                          // The label ellipsizes before the other tabs drop
                          // under their minimum width.
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  barWidth -
                                  _barInset * 2 -
                                  AppShellTab.minWidth * (tabs.length - 1),
                            ),
                            child: AppShellTab(
                              icon: icon,
                              label: label,
                              selected: true,
                              onTap: () => onTabSelected(i),
                            ),
                          )
                        else
                          Expanded(
                            child: AppShellTab(
                              icon: icon,
                              label: label,
                              selected: false,
                              onTap: () => onTabSelected(i),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: _edge,
            bottom: _addBottom,
            width: addSize,
            height: addSize,
            child: Tooltip(
              message: l10n.addTransaction,
              excludeFromSemantics: true,
              child: Semantics(
                button: true,
                label: l10n.addTransaction,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: shadows.addButton,
                  ),
                  child: Material(
                    color: colors.ink,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onAdd,
                      child: Icon(Icons.add, size: 28, color: colors.onInk),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
