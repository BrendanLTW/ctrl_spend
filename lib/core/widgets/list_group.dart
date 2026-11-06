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
    this.leading,
    this.value,
    this.onTap,
    super.key,
  });

  final String title;
  final Widget? leading;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      button: onTap != null,
      label: [title, ?value].join(', '),
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
                  child: Text(
                    title,
                    style: text.rowTitle.copyWith(color: colors.ink),
                  ),
                ),
                if (value case final value?)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      value,
                      style: text.rowTitleSm.copyWith(color: colors.muted),
                    ),
                  ),
                if (onTap != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      Icons.chevron_right_rounded,
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
