import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// A 48 high field (DESIGN §7, Field), as S60's label and date: radius 18,
/// `surface`, a 20 px icon and 15/500 text; the placeholder in
/// `disabled`. [controller] makes it a text field, [onTap] a button.
class EntryField extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    this.controller,
    this.maxLength,
    this.onTap,
    this.compact = false,
    this.background,
    super.key,
  });

  final AppIcon icon;

  /// The placeholder of a text field, or a button's text.
  final String label;
  final TextEditingController? controller;
  final int? maxLength;
  final VoidCallback? onTap;

  /// 14 px side padding, for the half-width chips.
  final bool compact;

  /// Replaces `surface`, e.g. `ground` inside a sheet (S60).
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.body.copyWith(
      color: colors.ink,
      fontWeight: FontWeight.w500,
    );
    final field = controller;
    final content = Row(
      children: [
        AppIconView(icon, size: 20, color: colors.ink),
        const SizedBox(width: 12),
        Expanded(
          child: field == null
              ? Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                )
              : TextField(
                  controller: field,
                  maxLength: maxLength,
                  style: style,
                  cursorColor: colors.ink,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration.collapsed(
                    hintText: label,
                    hintStyle: style.copyWith(color: colors.disabled),
                  ).copyWith(counterText: ''),
                ),
        ),
      ],
    );
    final box = Material(
      color: background ?? colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: 8,
            ),
            child: content,
          ),
        ),
      ),
    );
    return field == null
        ? Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            child: box,
          )
        : Semantics(textField: true, label: label, child: box);
  }
}
