import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field (DESIGN §7): 56 high, radius 20, `surface`, 22 px leading
/// icon, 15/500 text. [hint] doubles as its screen-reader label.
class AppTextField extends StatelessWidget {
  const new({
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLength,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;

  /// Stops typing past this many characters, without a counter.
  final int? maxLength;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.body.copyWith(
      color: colors.ink,
      fontWeight: FontWeight.w500,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.r20),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: style,
      cursorColor: colors.ink,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      inputFormatters: [
        if (maxLength case final max?) LengthLimitingTextInputFormatter(max),
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: colors.muted),
        filled: true,
        fillColor: colors.surface,
        constraints: const BoxConstraints(minHeight: 56),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 17,
        ),
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 20, right: 14),
                child: Icon(icon, size: 22, color: colors.muted),
              ),
        prefixIconConstraints: const BoxConstraints(),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.control, width: 1.5),
        ),
      ),
    );
  }
}
