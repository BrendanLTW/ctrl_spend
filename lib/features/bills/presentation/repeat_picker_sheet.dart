import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_radio.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S44's presets. Months and years take their day from Next due on S28.
const repeatPresets = [
  BillRepeat(unit: RepeatUnit.week),
  BillRepeat(unit: RepeatUnit.week, every: 2),
  BillRepeat(unit: RepeatUnit.month),
  BillRepeat(unit: RepeatUnit.month, every: 3),
  BillRepeat(unit: RepeatUnit.year),
];

/// Whether [a] and [b] repeat alike, ignoring the day.
bool sameRepeat(BillRepeat a, BillRepeat b) =>
    a.unit == b.unit && a.every == b.every;

/// S44 Picker · Repeats, then the Custom sheet if chosen. [day] is the
/// next due day, shown under Every month. Resolves to the new repeat, or
/// null if dismissed.
Future<BillRepeat?> showRepeatPicker(
  BuildContext context, {
  required BillRepeat current,
  required int day,
}) async {
  final l10n = context.l10n;
  // Null pops mean dismissed; this marks Custom….
  const custom = BillRepeat(unit: RepeatUnit.day, every: 0);
  final picked = await showAppSheet<BillRepeat>(
    context,
    title: l10n.billRepeatsRow,
    builder: (sheet) => SheetListGroup(
      children: [
        for (final preset in repeatPresets)
          _RepeatRow(
            title: l10n.repeatLabel(preset),
            subtitle: preset == repeatPresets[2]
                ? l10n.repeatOnDay(l10n.ordinalDay(day.toString()))
                : null,
            selected: sameRepeat(preset, current),
            onTap: () => Navigator.of(sheet).pop(preset),
          ),
        _RepeatRow(
          title: l10n.repeatCustom,
          subtitle: repeatPresets.any((p) => sameRepeat(p, current))
              ? null
              : l10n.repeatLabel(current),
          onTap: () => Navigator.of(sheet).pop(custom),
        ),
      ],
    ),
  );
  if (picked != custom || !context.mounted) return picked;
  return await showAppSheet<BillRepeat>(
    context,
    title: l10n.customRepeatTitle,
    builder: (_) => _CustomRepeatBody(initial: current),
  );
}

/// Rows on a `fillSoft` card with dividers: a list inside a sheet, as
/// S44 shows it, so it stands out from the sheet in both themes.
class SheetListGroup extends StatelessWidget {
  const new({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.fillSoft,
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

/// A preset with a radio, or Custom… ([selected] null) with a chevron.
class _RepeatRow extends StatelessWidget {
  const new({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected,
  });

  final String title;
  final String? subtitle;
  final bool? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final isSelected = selected;
    return Semantics(
      container: true,
      button: true,
      selected: isSelected ?? false,
      inMutuallyExclusiveGroup: isSelected != null,
      label: [title, ?subtitle].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                      ),
                      if (subtitle case final subtitle?)
                        Text(
                          subtitle,
                          style: text.body.copyWith(color: colors.muted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isSelected == null)
                  AppIconView(
                    AppIcon.chevronRight,
                    stroke: AppIconStroke.chevron,
                    size: 20,
                    color: colors.ink,
                  )
                else
                  AppRadio(selected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom…: "Every" with a 1–12 stepper and days, weeks or months, then
/// Set (PRD §5.11).
class _CustomRepeatBody extends StatefulWidget {
  const new({required this.initial});

  final BillRepeat initial;

  @override
  State<_CustomRepeatBody> createState() => _CustomRepeatBodyState();
}

class _CustomRepeatBodyState extends State<_CustomRepeatBody> {
  // A preset in years (Every year) starts the sheet at every 1 month.
  late int _every = widget.initial.unit == RepeatUnit.year
      ? 1
      : widget.initial.every.clamp(1, maxCustomEvery);
  late RepeatUnit _unit = widget.initial.unit == RepeatUnit.year
      ? RepeatUnit.month
      : widget.initial.unit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    Widget step(AppIcon icon, String label, int by) {
      final next = _every + by;
      final enabled = next >= 1 && next <= maxCustomEvery;
      return IconButton(
        tooltip: label,
        onPressed: enabled ? () => setState(() => _every = next) : null,
        style: IconButton.styleFrom(
          backgroundColor: colors.raised,
          disabledBackgroundColor: colors.raised,
          minimumSize: const Size(48, 48),
        ),
        icon: AppIconView(
          icon,
          size: 22,
          color: enabled ? colors.ink : colors.disabled,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.repeatEvery,
                style: text.rowTitle.copyWith(color: colors.ink),
              ),
            ),
            step(AppIcon.minus, l10n.repeatFewer, -1),
            SizedBox(
              width: 64,
              child: Semantics(
                liveRegion: true,
                child: Text(
                  '$_every',
                  textAlign: TextAlign.center,
                  style: text.amount.copyWith(color: colors.ink),
                ),
              ),
            ),
            step(AppIcon.add, l10n.repeatMore, 1),
          ],
        ),
        const SizedBox(height: 20),
        SegmentedControl<RepeatUnit>(
          inSheet: true,
          segments: [
            (value: RepeatUnit.day, label: l10n.repeatDays),
            (value: RepeatUnit.week, label: l10n.repeatWeeks),
            (value: RepeatUnit.month, label: l10n.repeatMonths),
          ],
          selected: _unit,
          onChanged: (unit) => setState(() => _unit = unit),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.repeatLabel(BillRepeat(unit: _unit, every: _every)),
          textAlign: TextAlign.center,
          style: text.body.copyWith(color: colors.muted),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: l10n.setRepeat,
          onPressed: () =>
              Navigator.of(context).pop(BillRepeat(unit: _unit, every: _every)),
        ),
      ],
    );
  }
}
