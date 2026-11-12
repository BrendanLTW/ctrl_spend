import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_radio.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/search_field.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/currency_names.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S34 Currency: search, Suggested and All currencies. Tapping one saves
/// it at once; only the symbol changes, amounts are never converted.
class CurrencyScreen extends ConsumerStatefulWidget {
  const new({super.key});

  static const List<Currency> suggested = [
    Currency.myr,
    Currency.sgd,
    Currency.usd,
  ];

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final current = Currency.fromCode(
      (ref.watch(preferencesProvider).value ?? const Preferences())
          .currencyCode,
    );
    final query = _search.text.trim().toLowerCase();
    bool matches(Currency c) =>
        query.isEmpty ||
        [
          l10n.currencyName(c),
          c.code,
          c.symbol,
        ].any((s) => s.toLowerCase().contains(query));

    final suggested = [
      for (final c in CurrencyScreen.suggested)
        if (matches(c)) c,
    ];
    final others = [
      for (final c in Currency.values)
        if (!CurrencyScreen.suggested.contains(c) && matches(c)) c,
    ];

    void choose(Currency c) => ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(currencyCode: c.code));

    Widget section(String label, List<Currency> list) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        ListGroup(
          children: [
            for (final c in list)
              _CurrencyRow(
                currency: c,
                current: c == current,
                onTap: () => choose(c),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionTop),
      ],
    );

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
          l10n.currency,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          SearchField(
            controller: _search,
            hint: l10n.searchCurrencies,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          if (suggested.isNotEmpty) section(l10n.suggestedSection, suggested),
          if (others.isNotEmpty) section(l10n.allCurrencies, others),
          if (suggested.isEmpty && others.isEmpty) ...[
            Text(
              l10n.noCurrencyMatch(_search.text.trim()),
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.muted),
            ),
            const SizedBox(height: AppSpacing.sectionTop),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.textX - AppSpacing.screenX,
            ),
            child: Text(
              l10n.currencyNote,
              style: text.body.copyWith(color: colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// A symbol tile, the name and code ("MYR · current"), and a radio.
class _CurrencyRow extends StatelessWidget {
  const new({
    required this.currency,
    required this.current,
    required this.onTap,
  });

  final Currency currency;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final name = l10n.currencyName(currency);
    final code = current ? l10n.currencyCurrent(currency.code) : currency.code;
    return Semantics(
      container: true,
      button: true,
      selected: current,
      inMutuallyExclusiveGroup: true,
      label: '$name, $code',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.raised,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                ),
                padding: const EdgeInsets.all(4),
                // Whole symbol even at large text ("RM", not "R").
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    currency.symbol,
                    style: text.rowTitleSm.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                    Text(code, style: text.body.copyWith(color: colors.muted)),
                  ],
                ),
              ),
              AppRadio(selected: current),
            ],
          ),
        ),
      ),
    );
  }
}
