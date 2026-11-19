import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_toggle.dart';
import 'package:ctrlspend/core/widgets/large_text.dart';
import 'package:flutter/material.dart';

const _padding = EdgeInsets.symmetric(horizontal: 18, vertical: 12);
const _minHeight = BoxConstraints(minHeight: 64);

/// A form row with [label] and a name typed in on the right (S28, S31).
class DetailNameRow extends StatelessWidget {
  const new({
    required this.label,
    required this.hint,
    required this.controller,
    required this.maxLength,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLength;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = text.body.copyWith(color: colors.ink);
    final field = TextField(
      controller: controller,
      maxLength: maxLength,
      textAlign: largeText(context) ? TextAlign.start : TextAlign.end,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      style: style,
      cursorColor: colors.ink,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration.collapsed(
        hintText: hint,
        hintStyle: style.copyWith(color: colors.muted),
      ).copyWith(counterText: ''),
    );
    final title = ExcludeSemantics(
      child: Text(label, style: text.rowTitle.copyWith(color: colors.ink)),
    );
    return Semantics(
      label: label,
      child: ConstrainedBox(
        constraints: _minHeight,
        child: Padding(
          padding: _padding,
          child: largeText(context)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [title, const SizedBox(height: 4), field],
                )
              : Row(
                  children: [
                    title,
                    const SizedBox(width: 16),
                    Expanded(child: field),
                  ],
                ),
        ),
      ),
    );
  }
}

/// A form row that opens a picker (S28, S31): the label, an optional
/// [tile], the value and a chevron. With large text the value goes under
/// the label.
class DetailRow extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.onTap,
    this.tile,
    super.key,
  });

  final String label;
  final String value;
  final Widget? tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final stacked = largeText(context);
    final valueRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tile case final tile?) ...[tile, const SizedBox(width: 10)],
        Flexible(
          child: Text(
            value,
            style: text.rowTitleSm.copyWith(color: colors.muted),
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: _minHeight,
          child: Padding(
            padding: _padding,
            child: Row(
              children: [
                Expanded(
                  child: stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: text.rowTitle.copyWith(color: colors.ink),
                            ),
                            valueRow,
                          ],
                        )
                      : Row(
                          children: [
                            Text(
                              label,
                              style: text.rowTitle.copyWith(color: colors.ink),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: valueRow,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                AppIconView(
                  AppIcon.chevronRight,
                  stroke: AppIconStroke.chevron,
                  size: 20,
                  color: colors.ink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A form row with a toggle, as S28's Remind me: title, detail and a
/// toggle. The whole row toggles.
class DetailToggleRow extends StatelessWidget {
  const new({
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    // Tapping anywhere on the row flips it; read as one toggle.
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: _minHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  // The toggle carries the label, so it's read once.
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.rowTitle.copyWith(color: colors.ink),
                        ),
                        Text(
                          detail,
                          style: text.body.copyWith(color: colors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AppToggle(
                  value: value,
                  onChanged: onChanged,
                  semanticLabel: '$title, $detail',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
