import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/brand_symbol.dart';
import 'package:ctrl_spend/features/app_lock/domain/device_auth.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_lockout.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_store.dart';
import 'package:ctrl_spend/features/app_lock/presentation/pin_attempts.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S38 Lock screen, and S66 while entry is paused: "Welcome back", the
/// PIN dots, a round keypad with the biometric key and delete, and
/// Forgot PIN?. Dark in both themes. Biometrics, when on, prompt as it
/// opens. [preview] (from S37) has a close button, no Forgot PIN?, and
/// doesn't count wrong PINs.
class LockScreen extends ConsumerStatefulWidget {
  const new({
    required this.onUnlocked,
    this.onForgot,
    this.preview = false,
    super.key,
  });

  final VoidCallback onUnlocked;
  final VoidCallback? onForgot;
  final bool preview;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entered = '';
  bool _wrong = false;
  bool _busy = false;
  late final Timer _ticker;

  Preferences get _prefs =>
      ref.read(preferencesProvider).value ?? const Preferences();

  @override
  void initState() {
    super.initState();
    // Redraws the S66 countdown and lifts it when it ends.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    if (!widget.preview) {
      // The lock screen first, then the prompt on top of it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_prefs.biometricsOn) unawaited(_biometrics());
      });
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _biometrics() async {
    final ok = await ref
        .read(deviceAuthProvider)
        .confirm(context.l10n.unlockReason);
    if (!ok || !mounted) return;
    if (!widget.preview) await clearWrongPins(ref);
    widget.onUnlocked();
  }

  void _digit(int d) {
    if (_busy || _entered.length >= pinLength) return;
    setState(() {
      _entered += '$d';
      _wrong = false;
    });
    if (_entered.length == pinLength) unawaited(_check());
  }

  void _backspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _check() async {
    _busy = true;
    final ok = await ref.read(pinStoreProvider).check(_entered);
    if (!mounted) return;
    if (ok) {
      if (!widget.preview) await clearWrongPins(ref);
      widget.onUnlocked();
      return;
    }
    if (!widget.preview) await recordWrongPin(ref);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _wrong = true;
      _entered = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    // White on the hero colour in both themes, like the S09 hero.
    const onHero = AppColors.dark;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final left = widget.preview
        ? Duration.zero
        : lockoutLeft(prefs.lockoutUntil, ref.read(clockProvider)());
    final paused = left > Duration.zero;
    final time =
        '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';
    final name = prefs.userName.trim();

    return Scaffold(
      backgroundColor: context.colors.hero,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                    children: [
                      const Center(child: BrandSymbol(size: 76)),
                      const SizedBox(height: 20),
                      Semantics(
                        header: true,
                        child: Text(
                          name.isEmpty
                              ? l10n.welcomeBack
                              : l10n.welcomeBackName(name),
                          textAlign: TextAlign.center,
                          style: text.stateTitle.copyWith(color: onHero.ink),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (paused) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            l10n.tooManyWrongPins,
                            textAlign: TextAlign.center,
                            style: text.rowTitleSm.copyWith(
                              color: onHero.negative,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prefs.biometricsOn
                              ? l10n.tryAgainInOrBiometrics(time)
                              : l10n.tryAgainIn(time),
                          textAlign: TextAlign.center,
                          style: text.navLabel.copyWith(
                            color: onHero.chipText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ] else
                        Text(
                          l10n.enterYourPin,
                          textAlign: TextAlign.center,
                          style: text.body.copyWith(color: onHero.chipText),
                        ),
                      const SizedBox(height: 28),
                      _LockDots(
                        count: _entered.length,
                        error: paused || _wrong,
                        label: paused
                            ? l10n.pinEntryPaused
                            : l10n.pinDotsLabel(_entered.length),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: _LockPad(
                    enabled: !paused,
                    onDigit: _digit,
                    onBackspace: _backspace,
                    onBiometrics: prefs.biometricsOn ? _biometrics : null,
                  ),
                ),
                SizedBox(
                  height: 76,
                  child: widget.onForgot == null
                      ? null
                      : Center(
                          child: TextButton(
                            onPressed: widget.onForgot,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: onHero.ink,
                            ),
                            child: Text(
                              l10n.forgotPin,
                              style: text.rowTitleSm.copyWith(
                                color: onHero.ink,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
            // Last, so it sits above the scrolling content.
            if (widget.preview)
              Positioned(
                left: 8,
                top: 4,
                child: IconButton(
                  tooltip: l10n.close,
                  icon: const AppIconView(AppIcon.close),
                  color: onHero.ink,
                  onPressed: widget.onUnlocked,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 14 px white dots; red rings when wrong or paused (S66).
class _LockDots extends StatelessWidget {
  const new({required this.count, required this.error, required this.label});

  final int count;
  final bool error;
  final String label;

  @override
  Widget build(BuildContext context) {
    const onHero = AppColors.dark;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < pinLength; i++) ...[
            if (i > 0) const SizedBox(width: 18),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < count ? onHero.ink : Colors.transparent,
                border: Border.all(
                  color: error
                      ? onHero.negative
                      : i < count
                      ? onHero.ink
                      : onHero.muted,
                  width: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The lock screen's round keypad: 76 px keys, the biometric key bottom
/// left and delete bottom right. Paused (S66) dims the digits; the
/// biometric key stays active.
class _LockPad extends StatelessWidget {
  const new({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
    required this.onBiometrics,
  });

  final bool enabled;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometrics;

  @override
  Widget build(BuildContext context) {
    const onHero = AppColors.dark;
    final l10n = context.l10n;
    Widget key({
      required Widget child,
      required VoidCallback? onTap,
      bool ghost = false,
      String? label,
      bool dim = true,
    }) {
      final active = onTap != null && (enabled || !dim);
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Opacity(
              opacity: active || onTap == null ? 1 : 0.35,
              child: Semantics(
                button: true,
                // Paused keys read as disabled (and are exempt from the
                // contrast rule, as dimmed controls).
                enabled: active,
                label: label,
                child: Material(
                  color: ghost
                      ? Colors.transparent
                      : onHero.ink.withValues(alpha: 0.08),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: active ? onTap : null,
                    child: SizedBox.square(
                      dimension: 76,
                      child: Center(child: child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget digit(int d) => key(
      child: Text(
        '$d',
        style: context.text.pinKey.copyWith(
          color: onHero.ink,
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => onDigit(d),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            if (onBiometrics case final onBiometrics?)
              key(
                child: AppIconView(
                  AppIcon.scanFace,
                  size: 30,
                  color: onHero.ink,
                ),
                onTap: onBiometrics,
                ghost: true,
                label: l10n.unlockWithBiometrics,
                dim: false,
              )
            else
              const Expanded(child: SizedBox(height: 92)),
            digit(0),
            key(
              child: AppIconView(
                AppIcon.backspace,
                size: 28,
                color: onHero.ink,
              ),
              onTap: onBackspace,
              ghost: true,
              label: l10n.keypadBackspace,
            ),
          ],
        ),
      ],
    );
  }
}
