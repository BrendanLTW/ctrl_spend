// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabBudgets => 'Budgets';

  @override
  String get tabInsights => 'Insights';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get close => 'Close';

  @override
  String get settings => 'Settings';

  @override
  String get finishOnboarding => 'Finish onboarding';

  @override
  String get keypadBackspace => 'Backspace';

  @override
  String get keypadDoubleZero => 'Double zero';

  @override
  String get cancel => 'Cancel';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String stepIndicator(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get continueAction => 'Continue';

  @override
  String get appName => 'ctrlSpend';

  @override
  String get splashTagline => 'Know what\'s left to spend.';

  @override
  String get splashBy => 'by';

  @override
  String get welcomeTitle => 'Know what\'s left to spend, every day.';

  @override
  String get welcomeBody =>
      'Set one monthly budget, log what you spend, and ctrlSpend keeps count.';

  @override
  String get getStarted => 'Get started';

  @override
  String get skipTheTour => 'Skip the tour';

  @override
  String welcomePreviewLabel(String amount) {
    return 'Dashboard preview: $amount left to spend';
  }

  @override
  String get leftToSpend => 'Left to spend';

  @override
  String get spent => 'spent';

  @override
  String categoryPercent(String category, int percent) {
    return '$category · $percent%';
  }

  @override
  String get categoryFood => 'Food';

  @override
  String get howTitle => 'How it works';

  @override
  String get howSubtitle => 'Three steps, then you\'re in control.';

  @override
  String get howBasics => 'The basics';

  @override
  String get howBudgetTitle => 'Set one monthly budget';

  @override
  String get howBudgetBody =>
      'Pick what you want to spend. Home shows what\'s left.';

  @override
  String get howLogTitle => 'Log spending in seconds';

  @override
  String get howLogBody => 'Tap +, type the amount, pick a category. Done.';

  @override
  String get howSeeTitle => 'See where it goes';

  @override
  String get howSeeBody => 'Spot the categories that eat your budget.';

  @override
  String get howPrivacy => 'Your privacy';

  @override
  String get howPrivacyTitle => 'Stays on this phone';

  @override
  String get howPrivacyBody =>
      'No account, no bank login. Export a CSV whenever you like.';
}
