import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A rounded card of rows with dividers between them (DESIGN §7).
class ListGroup extends StatelessWidget {
  const new({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r28),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: colors.divider),
            child,
          ],
        ],
      ),
    );
  }
}

/// A row in a [ListGroup]: optional leading tile, title, optional value,
/// and a chevron when it can be tapped (S21, S22).
class ListGroupRow extends StatelessWidget {
  const new({
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String title;

  /// A muted second line, e.g. S03's step descriptions.
  final String? subtitle;
  final Widget? leading;
  final String? value;

  /// Defaults to `muted`; a status colour for results like "Over by RM 10"
  /// (S25).
  final Color? valueColor;

  /// A widget in the value's place, e.g. S23's icon tile. Not read out.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shows a check instead of the chevron, for single-choice lists.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: [title, ?subtitle, ?value].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                if (leading case final leading?) ...[
                  leading,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                      ),
                      if (subtitle case final subtitle?) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: text.body.copyWith(color: colors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (value case final value?)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      value,
                      style: text.rowTitleSm.copyWith(
                        color: valueColor ?? colors.muted,
                      ),
                    ),
                  ),
                if (trailing case final trailing?)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: trailing,
                  ),
                if (selected || onTap != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: colors.ink,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A label on the left and a value on the right in 600 (S41, S26).
class KeyValueRow extends StatelessWidget {
  const new({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      label: '$label, $value',
      excludeSemantics: true,
      child: SizedBox(
        height: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: text.body.copyWith(color: colors.muted),
                ),
              ),
              Text(value, style: text.rowTitleSm.copyWith(color: colors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
