import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/widgets/app_text_field.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S03a What should we call you? (step 1 of 5). Continue needs a
/// non-blank name; it's trimmed, kept to 30 characters and saved.
class NameScreen extends ConsumerStatefulWidget {
  const new({super.key});

  static const maxLength = 30;

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final _name = TextEditingController(
    text: ref.read(preferencesProvider).value?.userName ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _continue() async {
    if (!_valid) return;
    final name = _name.text.trim();
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(userName: name));
    if (mounted) await context.push(Routes.onboardingMonth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingScaffold(
      step: 1,
      title: l10n.nameTitle,
      subtitle: l10n.nameSubtitle,
      primaryLabel: l10n.continueAction,
      onPrimary: _valid ? _continue : null,
      body: AppTextField(
        controller: _name,
        hint: l10n.firstName,
        icon: Icons.person_outline_rounded,
        maxLength: NameScreen.maxLength,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        // Rebuild so Continue follows the field.
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _continue(),
      ),
    );
  }
}
