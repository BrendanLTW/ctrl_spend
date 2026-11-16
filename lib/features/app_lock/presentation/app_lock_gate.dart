import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/features/app_lock/domain/lock_rules.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_store.dart';
import 'package:ctrl_spend/features/app_lock/presentation/forgot_pin_screen.dart';
import 'package:ctrl_spend/features/app_lock/presentation/lock_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puts the lock screen (S38) over the whole app while app lock is on:
/// at launch, and on coming back after the Lock after time (S68). The
/// screens underneath stay as they were. It has its own navigator, for
/// Forgot PIN (S67) and Create PIN, and holds back the system Back
/// button while locked.
class AppLockGate extends ConsumerStatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  bool _locked = false;
  bool _checkedLaunch = false;
  DateTime? _awaySince;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(preferencesProvider, (_, next) {
      final prefs = next.value;
      if (prefs == null) return;
      if (!_checkedLaunch) {
        _checkedLaunch = true;
        unawaited(_lockIfOn(prefs));
      }
      // Turned off, or erased from S67: nothing to unlock with.
      if (!prefs.appLockOn && _locked) setState(() => _locked = false);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _lockIfOn(Preferences prefs) async {
    if (!prefs.appLockOn || !await ref.read(pinStoreProvider).hasPin()) {
      return;
    }
    if (mounted) setState(() => _locked = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = ref.read(clockProvider)();
    switch (state) {
      // Inactive alone is a prompt or a call banner, not leaving.
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        _awaySince ??= now;
      case AppLifecycleState.resumed:
        final prefs = ref.read(preferencesProvider).value;
        if (prefs != null &&
            !_locked &&
            shouldLock(
              awaySince: _awaySince,
              now: now,
              lockAfterMinutes: prefs.lockAfterMinutes,
            )) {
          unawaited(_lockIfOn(prefs));
        }
        _awaySince = null;
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  @override
  Future<bool> didPopRoute() async {
    if (!_locked) return false;
    // Back steps out of S67, never past the lock.
    await _navigator.currentState?.maybePop();
    return true;
  }

  void _unlock() => setState(() => _locked = false);

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // Out of reach of screen readers and focus while locked.
      ExcludeSemantics(
        excluding: _locked,
        child: ExcludeFocus(excluding: _locked, child: widget.child),
      ),
      if (_locked)
        Positioned.fill(
          child: Navigator(
            key: _navigator,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => LockScreen(
                onUnlocked: _unlock,
                onForgot: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ForgotPinScreen(onReset: _unlock),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
