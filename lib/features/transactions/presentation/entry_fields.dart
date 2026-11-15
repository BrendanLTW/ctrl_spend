import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_picker_tile.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S12's Category: the label and More, then one scrolling row of tiles
/// (DESIGN §6). A newly selected tile scrolls into view, so one picked on
/// S46 shows.
class CategoryTileRow extends StatefulWidget {
  const new({
    required this.choices,
    required this.selected,
    required this.onSelected,
    required this.onMore,
    super.key,
  });

  /// Active categories of the current type, in display order, plus the
  /// selected one if it's archived.
  final List<Category> choices;
  final Category? selected;
  final ValueChanged<Category> onSelected;
  final VoidCallback onMore;

  @override
  State<CategoryTileRow> createState() => _CategoryTileRowState();
}

class _CategoryTileRowState extends State<CategoryTileRow> {
  static const _tileWidth = 66.0;
  static const _gap = 10.0;
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(CategoryTileRow old) {
    super.didUpdateWidget(old);
    final id = widget.selected?.id;
    if (id == null || id == old.selected?.id) return;
    final index = widget.choices.indexWhere((c) => c.id == id);
    if (index < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final position = _scroll.position;
      final start = index * (_tileWidth + _gap);
      final end = start + _tileWidth + AppSpacing.screenX * 2;
      final target = start < position.pixels
          ? start
          : end > position.pixels + position.viewportDimension
          ? end - position.viewportDimension
          : null;
      if (target != null) {
        _scroll.jumpTo(target.clamp(0, position.maxScrollExtent));
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choices = widget.choices;
    final selected = widget.selected;
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    // The tile, its gap and its label, which grows with the text size.
    final height =
        56 +
        8 +
        MediaQuery.textScalerOf(context).scale(text.pillLabel.fontSize! * 1.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.textX,
            6,
            AppSpacing.textX - 12,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.categoryRowLabel.toUpperCase(),
                    style: text.label.copyWith(color: colors.muted),
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onMore,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: colors.ink,
                  overlayColor: colors.raised,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.more,
                      style: text.rowTitleSm.copyWith(color: colors.ink),
                    ),
                    const SizedBox(width: 2),
                    AppIconView(
                      AppIcon.chevronRight,
                      stroke: AppIconStroke.chevron,
                      size: 18,
                      color: colors.ink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
            itemCount: choices.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, i) => SizedBox(
              width: _tileWidth,
              child: CategoryPickerTile(
                icon: categoryIcon(choices[i].iconKey),
                label: choices[i].name,
                selected: choices[i].id == selected?.id,
                onTap: () => widget.onSelected(choices[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A 48 high field on the entry screens (DESIGN §7, Field): radius 18,
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
      color: colors.surface,
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
