import 'package:flutter/material.dart';

/// Colour tokens from DESIGN §3.1–3.2. Read them with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const new({
    required this.ground,
    required this.surface,
    required this.raised,
    required this.ink,
    required this.onInk,
    required this.inkPressed,
    required this.muted,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.hero,
    required this.heroTrack,
    required this.divider,
    required this.fillSoft,
    required this.control,
    required this.stepOff,
    required this.disabled,
    required this.chipText,
    required this.navSelected,
  });

  static const light = AppColors(
    ground: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEEF1F6),
    ink: Color(0xFF101828),
    onInk: Color(0xFFFFFFFF),
    inkPressed: Color(0xFF1D2939),
    muted: Color(0xFF5B6B86),
    positive: Color(0xFF067647),
    negative: Color(0xFFD92D20),
    warning: Color(0xFFB54708),
    hero: Color(0xFF101828),
    heroTrack: Color(0xFF475467),
    divider: Color(0xFFEEF1F6),
    fillSoft: Color(0xFFF2F4F7),
    control: Color(0xFFD0D5DD),
    stepOff: Color(0xFFE4E7EC),
    disabled: Color(0xFF98A2B3),
    chipText: Color(0xFF344054),
    navSelected: Color(0xFFEEF1F6),
  );

  static const dark = AppColors(
    ground: Color(0xFF0B1018),
    surface: Color(0xFF161D29),
    raised: Color(0xFF232C3A),
    ink: Color(0xFFF2F4F7),
    onInk: Color(0xFF0B1018),
    inkPressed: Color(0xFFD0D5DD),
    muted: Color(0xFF98A2B3),
    positive: Color(0xFF47CD89),
    negative: Color(0xFFF97066),
    warning: Color(0xFFFDB022),
    hero: Color(0xFF1C2536),
    heroTrack: Color(0xFF344054),
    divider: Color(0xFF232C3A),
    fillSoft: Color(0xFF232C3A),
    control: Color(0xFF344054),
    stepOff: Color(0xFF344054),
    disabled: Color(0xFF5B6B86),
    chipText: Color(0xFFD0D5DD),
    navSelected: Color(0xFF2A3444),
  );

  /// Screen background.
  final Color ground;

  /// Cards, rows, list groups, chips, fields, sheets, nav bar.
  final Color surface;

  /// Icon buttons, empty-state tiles, progress tracks, pressed rows.
  final Color raised;

  /// Primary text and primary accent.
  final Color ink;

  /// Text and icons on ink fills.
  final Color onInk;

  /// Pressed state of ink fills.
  final Color inkPressed;

  /// Secondary text, captions, labels, unselected segments.
  final Color muted;

  /// Income amounts, under results.
  final Color positive;

  /// Expense amounts, over budget, destructive actions.
  final Color negative;

  /// 80–99% of a budget or limit.
  final Color warning;

  /// Budget hero card background.
  final Color hero;

  /// Progress track on the hero card.
  final Color heroTrack;

  /// Lines between rows in a list group.
  final Color divider;

  /// Keypad keys and segmented track inside sheets, chip pressed.
  final Color fillSoft;

  /// Toggle off, radio border, today ring in the calendar.
  final Color control;

  /// Inactive step-indicator segment.
  final Color stepOff;

  /// Past dates, disabled text.
  final Color disabled;

  /// Unselected filter chip label.
  final Color chipText;

  /// Active tab pill in the bottom bar.
  final Color navSelected;

  /// Every token by name, so tests can check both palettes cover them all.
  @visibleForTesting
  Map<String, Color> get tokens => {
    'ground': ground,
    'surface': surface,
    'raised': raised,
    'ink': ink,
    'onInk': onInk,
    'inkPressed': inkPressed,
    'muted': muted,
    'positive': positive,
    'negative': negative,
    'warning': warning,
    'hero': hero,
    'heroTrack': heroTrack,
    'divider': divider,
    'fillSoft': fillSoft,
    'control': control,
    'stepOff': stepOff,
    'disabled': disabled,
    'chipText': chipText,
    'navSelected': navSelected,
  };

  @override
  AppColors copyWith({
    Color? ground,
    Color? surface,
    Color? raised,
    Color? ink,
    Color? onInk,
    Color? inkPressed,
    Color? muted,
    Color? positive,
    Color? negative,
    Color? warning,
    Color? hero,
    Color? heroTrack,
    Color? divider,
    Color? fillSoft,
    Color? control,
    Color? stepOff,
    Color? disabled,
    Color? chipText,
    Color? navSelected,
  }) {
    return AppColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      raised: raised ?? this.raised,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      inkPressed: inkPressed ?? this.inkPressed,
      muted: muted ?? this.muted,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      warning: warning ?? this.warning,
      hero: hero ?? this.hero,
      heroTrack: heroTrack ?? this.heroTrack,
      divider: divider ?? this.divider,
      fillSoft: fillSoft ?? this.fillSoft,
      control: control ?? this.control,
      stepOff: stepOff ?? this.stepOff,
      disabled: disabled ?? this.disabled,
      chipText: chipText ?? this.chipText,
      navSelected: navSelected ?? this.navSelected,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      inkPressed: Color.lerp(inkPressed, other.inkPressed, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      heroTrack: Color.lerp(heroTrack, other.heroTrack, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      fillSoft: Color.lerp(fillSoft, other.fillSoft, t)!,
      control: Color.lerp(control, other.control, t)!,
      stepOff: Color.lerp(stepOff, other.stepOff, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
