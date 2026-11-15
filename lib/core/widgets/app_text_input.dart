import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A text input with a counter (DESIGN §7; S03a, S47): 56 high, radius 18,
/// `surface`, 17/500. Focus draws a 2 px `ink` outline, [error] a 2 px
/// `negative` one. The counter ("4/30") sits under it on the right.
/// [label] is its screen-reader name.
class AppTextInput extends StatefulWidget {
  const new({
    required this.controller,
    required this.label,
    required this.maxLength,
    this.hint,
    this.error = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLength;
  final bool error;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(AppTextInput old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = text.rowTitle.copyWith(
      fontSize: text.button.fontSize,
      fontWeight: FontWeight.w500,
      color: colors.ink,
    );
    final outline = widget.error
        ? colors.negative
        : _focus.hasFocus
        ? colors.ink
        : Colors.transparent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r18),
            border: Border.all(color: outline, width: 2),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: style,
            cursorColor: colors.ink,
            decoration: InputDecoration.collapsed(
              hintText: widget.hint,
              hintStyle: style.copyWith(color: colors.disabled),
            ).copyWith(counterText: ''),
          ),
        ),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Text(
            '${widget.controller.text.characters.length}/${widget.maxLength}',
            textAlign: TextAlign.right,
            style: text.caption.copyWith(color: colors.muted),
          ),
        ),
      ],
    );
  }
}
