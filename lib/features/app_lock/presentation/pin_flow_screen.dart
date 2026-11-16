import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/message_box.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_lockout.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_store.dart';
import 'package:ctrl_spend/features/app_lock/presentation/pin_pad.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What the PIN screen is for.
enum PinFlow {
  /// S64 → S65: a new PIN, when turning app lock on (or after S67).
  create,

  /// The current PIN, then a new one (Change PIN).
  change,

  /// Just the current PIN, e.g. before turning app lock off.
  verify,
}

enum _Step { current, create, confirm }

/// S64/S65 Create PIN, and the current-PIN check before changes. Pops
/// with true once done. Wrong current PINs count toward the S66 lockout.
class PinFlowScreen extends ConsumerStatefulWidget {
  const new({required this.flow, super.key});

  final PinFlow flow;

  @override
  ConsumerState<PinFlowScreen> createState() => _PinFlowScreenState();
}

class _PinFlowScreenState extends ConsumerState<PinFlowScreen> {
  late _Step _step = widget.flow == PinFlow.create
      ? _Step.create
      : _Step.current;
  String _entered = '';
  String _first = '';
  String? _error;
  bool _busy = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Redraws the lockout countdown, and lifts it when it's over.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lockoutLeft > Duration.zero || _wasLocked) setState(() {});
    });
  }

  bool _wasLocked = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Preferences get _prefs =>
      ref.read(preferencesProvider).value ?? const Preferences();

  Duration get _lockoutLeft => _step == _Step.current
      ? lockoutLeft(_prefs.lockoutUntil, ref.read(clockProvider)())
      : Duration.zero;

  void _digit(int d) {
    if (_busy || _entered.length >= pinLength) return;
    setState(() {
      _entered += '$d';
      if (_step != _Step.confirm) _error = null;
    });
    if (_entered.length == pinLength) unawaited(_complete());
  }

  void _backspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _complete() async {
    final l10n = context.l10n;
    final pins = ref.read(pinStoreProvider);
    final repository = ref.read(preferencesRepositoryProvider);
    switch (_step) {
      case _Step.current:
        _busy = true;
        final ok = await pins.check(_entered);
        if (ok) {
          await repository.update(
            (p) => p.copyWith(failedPinCount: 0, lockoutUntil: null),
          );
          if (!mounted) return;
          if (widget.flow == PinFlow.verify) {
            context.pop(true);
            return;
          }
          setState(() => _step = _Step.create);
        } else {
          final failed = _prefs.failedPinCount + 1;
          final pause = lockoutAfter(failed);
          final now = ref.read(clockProvider)();
          await repository.update(
            (p) => p.copyWith(
              failedPinCount: failed,
              lockoutUntil: pause == null ? p.lockoutUntil : now.add(pause),
            ),
          );
          if (!mounted) return;
          setState(() => _error = l10n.pinWrong);
        }
        _busy = false;
        setState(() => _entered = '');
      case _Step.create:
        setState(() {
          _first = _entered;
          _entered = '';
          _step = _Step.confirm;
        });
      case _Step.confirm:
        if (_entered == _first) {
          _busy = true;
          await pins.save(_entered);
          if (mounted) context.pop(true);
          return;
        }
        // Mismatch: back to step 1, with the dots red (S65).
        setState(() {
          _error = l10n.pinMismatch;
          _entered = '';
          _first = '';
          _step = _Step.create;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    // Rebuilds when the lockout or failed count changes.
    ref.watch(preferencesProvider);
    final left = _lockoutLeft;
    final locked = left > Duration.zero;
    _wasLocked = locked;
    final error = locked
        ? l10n.pinLockedOut(
            '${left.inMinutes}:'
            '${(left.inSeconds % 60).toString().padLeft(2, '0')}',
          )
        : _error;
    final (step, title, body) = switch (_step) {
      _Step.current => (null, l10n.pinCurrentTitle, l10n.pinCurrentBody),
      _Step.create => (1, l10n.pinCreateTitle, l10n.pinCreateBody),
      _Step.confirm => (2, l10n.pinConfirmTitle, l10n.pinConfirmBody),
    };

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const AppIconView(AppIcon.close),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.appLock,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(32, 30, 32, 16),
                children: [
                  if (step != null)
                    Text(
                      l10n.pinStep(step).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: text.label.copyWith(color: colors.muted),
                    ),
                  const SizedBox(height: 10),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: text.stateTitle.copyWith(color: colors.ink),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: text.body.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 26),
                  PinDots(
                    count: _entered.length,
                    error: error != null && _entered.isEmpty,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 20),
                    MessageBox(error, kind: MessageKind.error),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(37, 0, 37, 24),
              child: PinPad(
                enabled: !locked,
                onDigit: _digit,
                onBackspace: _backspace,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
