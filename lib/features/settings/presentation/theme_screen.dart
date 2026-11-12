import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_radio.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S33 Theme: Light, Dark or System, each with a small preview. A choice is
/// saved as soon as it's tapped and the app follows it at once.
class ThemeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final selected =
        (ref.watch(preferencesProvider).value ?? const Preferences()).theme;

    void choose(AppTheme theme) => ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(theme: theme));

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.themeRow,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          16,
          AppSpacing.screenX,
          32,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, (theme, label)) in [
                (AppTheme.light, l10n.themeLight),
                (AppTheme.dark, l10n.themeDark),
                (AppTheme.system, l10n.themeSystem),
              ].indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _ThemeOption(
                    theme: theme,
                    label: label,
                    selected: theme == selected,
                    onTap: () => choose(theme),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              l10n.themeNote,
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const new({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppTheme theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.r28);
    final preview = switch (theme) {
      AppTheme.light => const _PhonePreview(AppColors.light),
      AppTheme.dark => const _PhonePreview(AppColors.dark),
      // Light on the left, dark on the right.
      AppTheme.system => const Stack(
        fit: StackFit.expand,
        children: [
          _PhonePreview(AppColors.light),
          ClipRect(clipper: _RightHalf(), child: _PhonePreview(AppColors.dark)),
        ],
      ),
    };
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 113 / 200,
              child: Container(
                foregroundDecoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: selected ? colors.ink : colors.stepOff,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: ClipRRect(borderRadius: radius, child: preview),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppRadio(selected: selected),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.rowTitle.copyWith(color: colors.ink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A tiny Home screen in [palette]'s colours: the hero and three rows.
class _PhonePreview extends StatelessWidget {
  const new(this.palette);

  final AppColors palette;

  @override
  Widget build(BuildContext context) {
    Widget block(double height, Color color, double radius) => Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    return ColoredBox(
      color: palette.ground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            block(55, palette.hero, AppRadius.r16),
            for (var i = 0; i < 3; i++) ...[
              const SizedBox(height: 8),
              block(22, palette.surface, AppRadius.r12),
            ],
          ],
        ),
      ),
    );
  }
}

class _RightHalf extends CustomClipper<Rect> {
  const new();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width / 2, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightHalf oldClipper) => false;
}
