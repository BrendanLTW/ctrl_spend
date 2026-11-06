import 'package:ctrl_spend/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:ctrl_spend/l10n/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
