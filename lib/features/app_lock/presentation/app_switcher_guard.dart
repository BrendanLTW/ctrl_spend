import 'dart:async';

import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/features/app_lock/domain/secure_window.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Hide amounts in app switcher" (S37), while app lock is on. iOS takes
/// its snapshot of whatever is drawn as the app leaves, so the app is
/// covered whenever it isn't active; Android is told through
/// [SecureWindow] (FLAG_SECURE), which also blocks screenshots.
class AppSwitcherGuard extends ConsumerStatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppSwitcherGuard> createState() => _AppSwitcherGuardState();
}

class _AppSwitcherGuardState extends ConsumerState<AppSwitcherGuard>
    with WidgetsBindingObserver {
  bool _away = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(
      preferencesProvider.select(
        (p) =>
            (p.value?.appLockOn ?? false) && (p.value?.hideInSwitcher ?? false),
      ),
      (_, hidden) =>
          unawaited(ref.read(secureWindowProvider).setHidden(hidden: hidden)),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      setState(() => _away = state != AppLifecycleState.resumed);

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final hide = prefs.appLockOn && prefs.hideInSwitcher;
    return Stack(
      children: [
        widget.child,
        if (hide && _away)
          Positioned.fill(child: ColoredBox(color: context.colors.ground)),
      ],
    );
  }
}
