import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/categories/presentation/category_style_pickers.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S23's Name sheet: the name with its tile, saved on Save. A name another
/// category of the same type has shows S24's error and keeps the sheet.
Future<void> showCategoryNameSheet(BuildContext context, Category category) =>
    showAppSheet<void>(
      context,
      title: context.l10n.nameLabel,
      builder: (_) => _NameBody(category),
    );

/// S23's Icon & colour sheet: a preview tile, the icon grid and the
/// colour dots, saved on Save.
Future<void> showCategoryStyleSheet(BuildContext context, Category category) =>
    showAppSheet<void>(
      context,
      title: context.l10n.iconAndColour,
      builder: (_) => _StyleBody(category),
    );

class _NameBody extends ConsumerStatefulWidget {
  const new(this.category);

  final Category category;

  @override
  ConsumerState<_NameBody> createState() => _NameBodyState();
}

class _NameBodyState extends ConsumerState<_NameBody> {
  late final _name = TextEditingController(text: widget.category.name);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    try {
      await ref
          .read(categoryRepositoryProvider)
          .update(widget.category.copyWith(name: name));
      if (mounted) Navigator.of(context).pop();
    } on DuplicateCategoryNameException {
      setState(
        () => _error = context.l10n.duplicateCategory(
          widget.category.type.name,
          name,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CategoryNameField(
          controller: _name,
          icon: widget.category.iconKey,
          colour: widget.category.colorKey,
          maxLength: maxCategoryNameLength,
          onChanged: () => setState(() => _error = null),
        ),
        if (_error case final error?)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              error,
              style: text.caption.copyWith(
                color: colors.negative,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: context.l10n.save,
          onPressed: _name.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}

class _StyleBody extends ConsumerStatefulWidget {
  const new(this.category);

  final Category category;

  @override
  ConsumerState<_StyleBody> createState() => _StyleBodyState();
}

class _StyleBodyState extends ConsumerState<_StyleBody> {
  late CategoryIconKey _icon = widget.category.iconKey;
  late CategoryColorKey _colour = widget.category.colorKey;

  Future<void> _save() async {
    await ref
        .read(categoryRepositoryProvider)
        .update(widget.category.copyWith(iconKey: _icon, colorKey: _colour));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: CategoryTile.forKey(_icon, color: _colour)),
        const SizedBox(height: 20),
        SectionLabel(l10n.iconSection),
        CategoryIconGrid(
          selected: _icon,
          onSelected: (icon) => setState(() => _icon = icon),
        ),
        const SizedBox(height: 20),
        SectionLabel(l10n.colourSection),
        CategoryColourSwatches(
          selected: _colour,
          onSelected: (colour) => setState(() => _colour = colour),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: l10n.save, onPressed: _save),
      ],
    );
  }
}
