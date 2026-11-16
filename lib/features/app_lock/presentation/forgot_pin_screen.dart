import 'dart:async';

import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/message_box.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/state_view.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/app_lock/domain/device_auth.dart';
import 'package:ctrl_spend/features/app_lock/presentation/pin_attempts.dart';
import 'package:ctrl_spend/features/app_lock/presentation/pin_flow_screen.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/delete_all_data.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S67 Reset PIN: confirm with biometrics or the phone's passcode, then
/// choose a new PIN (S64) and get back in; the data stays. On a phone
/// with neither, both lead to Erase all data (S49), without its Export
/// link, which would get past the lock.
class ForgotPinScreen extends ConsumerWidget {
  const new({required this.onReset, super.key});

  /// Called once a new PIN is saved.
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;

    Future<void> confirm({required bool biometricOnly}) async {
      final auth = ref.read(deviceAuthProvider);
      if (!await auth.isDeviceSecure()) {
        if (context.mounted) {
          await confirmAndDeleteAllData(context, ref, offerExport: false);
        }
        return;
      }
      final ok = await auth.confirm(
        l10n.resetPinReason,
        biometricOnly: biometricOnly,
      );
      if (!ok || !context.mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const PinFlowScreen(flow: PinFlow.create),
        ),
      );
      if (saved ?? false) {
        await clearWrongPins(ref);
        onReset();
      }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.resetPin,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 110, bottom: 24),
                children: [
                  StateView(
                    icon: AppIcon.lock,
                    title: l10n.forgotPinTitle,
                    body: l10n.forgotPinBody,
                  ),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenX,
                    ),
                    child: MessageBox(l10n.forgotPinNote),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: l10n.continueWithBiometrics,
                    onPressed: () => unawaited(confirm(biometricOnly: true)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextLink(
                      label: l10n.usePhonePasscode,
                      onPressed: () => unawaited(confirm(biometricOnly: false)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
