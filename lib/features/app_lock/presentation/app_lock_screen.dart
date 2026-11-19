import 'dart:async';

import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_spacing.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_radio.dart';
import 'package:ctrlspend/core/widgets/app_sheet.dart';
import 'package:ctrlspend/core/widgets/category_tile.dart';
import 'package:ctrlspend/core/widgets/list_group.dart';
import 'package:ctrlspend/core/widgets/primary_button.dart';
import 'package:ctrlspend/core/widgets/section_label.dart';
import 'package:ctrlspend/core/widgets/sheet_list_group.dart';
import 'package:ctrlspend/features/app_lock/domain/device_auth.dart';
import 'package:ctrlspend/features/app_lock/domain/pin_store.dart';
import 'package:ctrlspend/features/app_lock/presentation/pin_flow_screen.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/notifications/presentation/reminder_toggles.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Whether biometrics are set up on this phone (S37's toggle).
final FutureProvider<bool> _biometricsAvailableProvider =
    FutureProvider.autoDispose<bool>(
      (ref) => ref.watch(deviceAuthProvider).canUseBiometrics(),
    );

/// S37 App lock: the lock itself (creating a PIN to turn it on, the
/// current PIN to turn it off), biometrics, and while it's on: Lock after
/// (S68), Change PIN, hiding amounts in the app switcher, and a preview
/// of the lock screen.
class AppLockScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final biometricsAvailable =
        ref.watch(_biometricsAvailableProvider).value ?? false;
    final repository = ref.read(preferencesRepositoryProvider);
    Future<bool> pin(PinFlow flow) async =>
        await context.push<bool>(Routes.pin, extra: flow) ?? false;

    Future<void> setLock({required bool on}) async {
      if (on) {
        if (!await pin(PinFlow.create)) return;
        await repository.update((p) => p.copyWith(appLockOn: true));
      } else {
        if (!await pin(PinFlow.verify)) return;
        await ref.read(pinStoreProvider).clear();
        await repository.update(
          (p) => p.copyWith(appLockOn: false, biometricsOn: false),
        );
      }
    }

    Future<void> setBiometrics({required bool on}) async {
      // Turning it on shows the prompt once, so it's known to work.
      if (on &&
          !await ref.read(deviceAuthProvider).confirm(l10n.biometricsReason)) {
        return;
      }
      await repository.update((p) => p.copyWith(biometricsOn: on));
    }

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const AppIconView(
            AppIcon.chevronLeft,
            stroke: AppIconStroke.chevron,
            size: 30,
          ),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.appLock,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          4,
          AppSpacing.screenX,
          32,
        ),
        children: [
          ListGroup(
            children: [
              ToggleRow(
                leading: const CategoryTile(
                  icon: AppIcon.lock,
                  color: CategoryColorKey.green,
                ),
                title: l10n.appLock,
                detail: l10n.appLockDetail,
                value: prefs.appLockOn,
                onChanged: (on) => setLock(on: on),
              ),
              ToggleRow(
                leading: const CategoryTile(
                  icon: AppIcon.scanFace,
                  color: CategoryColorKey.blue,
                ),
                title: l10n.unlockWithBiometrics,
                detail: l10n.unlockWithBiometricsDetail,
                value: prefs.appLockOn && prefs.biometricsOn,
                onChanged: prefs.appLockOn && biometricsAvailable
                    ? (on) => setBiometrics(on: on)
                    : null,
              ),
            ],
          ),
          if (prefs.appLockOn) ...[
            const SizedBox(height: AppSpacing.sectionTop),
            SectionLabel(l10n.optionsSection),
            ListGroup(
              children: [
                ListGroupRow(
                  title: l10n.lockAfter,
                  value: l10n.lockAfterChoice('${prefs.lockAfterMinutes}'),
                  onTap: () => _pickLockAfter(context, ref, prefs),
                ),
                ListGroupRow(
                  title: l10n.changePin,
                  onTap: () => unawaited(pin(PinFlow.change)),
                ),
                ToggleRow(
                  title: l10n.hideInSwitcher,
                  value: prefs.hideInSwitcher,
                  onChanged: (on) =>
                      repository.update((p) => p.copyWith(hideInSwitcher: on)),
                ),
                ListGroupRow(
                  title: l10n.previewLockScreen,
                  onTap: () => unawaited(context.push(Routes.lockPreview)),
                ),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textX - AppSpacing.screenX,
              12,
              AppSpacing.textX - AppSpacing.screenX,
              0,
            ),
            child: Text(
              l10n.appLockNote,
              style: text.caption.copyWith(color: colors.muted),
            ),
          ),
        ],
      ),
    );
  }

  /// S68: five choices, saved on Done.
  Future<void> _pickLockAfter(
    BuildContext context,
    WidgetRef ref,
    Preferences prefs,
  ) async {
    final minutes = await showAppSheet<int>(
      context,
      title: context.l10n.lockAfter,
      trailing: const SizedBox.shrink(),
      builder: (_) => _LockAfterBody(initial: prefs.lockAfterMinutes),
    );
    if (minutes == null) return;
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(lockAfterMinutes: minutes));
  }
}

class _LockAfterBody extends StatefulWidget {
  const new({required this.initial});

  final int initial;

  @override
  State<_LockAfterBody> createState() => _LockAfterBodyState();
}

class _LockAfterBodyState extends State<_LockAfterBody> {
  late int _minutes = widget.initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Text(
            l10n.lockAfterBody,
            style: text.caption.copyWith(color: colors.muted),
          ),
        ),
        SheetListGroup(
          children: [
            for (final m in lockAfterChoices)
              Semantics(
                container: true,
                button: true,
                selected: m == _minutes,
                inMutuallyExclusiveGroup: true,
                label: l10n.lockAfterChoice('$m'),
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => setState(() => _minutes = m),
                  highlightColor: colors.raised,
                  splashFactory: NoSplash.splashFactory,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.lockAfterChoice('$m'),
                              style: text.rowTitle.copyWith(color: colors.ink),
                            ),
                          ),
                          AppRadio(selected: m == _minutes),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.done,
          size: PrimaryButtonSize.sheet,
          onPressed: () => Navigator.of(context).pop(_minutes),
        ),
      ],
    );
  }
}
