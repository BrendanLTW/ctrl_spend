import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';

extension CurrencyNames on AppLocalizations {
  /// "Malaysian Ringgit" (S04, S34).
  String currencyName(Currency currency) => switch (currency) {
    Currency.myr => currencyMyr,
    Currency.sgd => currencySgd,
    Currency.usd => currencyUsd,
    Currency.aud => currencyAud,
    Currency.bnd => currencyBnd,
    Currency.eur => currencyEur,
    Currency.idr => currencyIdr,
  };
}
