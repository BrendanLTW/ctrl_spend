import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// No description provided for @tabBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get tabBudgets;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @finishOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Finish onboarding'**
  String get finishOnboarding;

  /// No description provided for @keypadBackspace.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get keypadBackspace;

  /// No description provided for @keypadDoubleZero.
  ///
  /// In en, this message translates to:
  /// **'Double zero'**
  String get keypadDoubleZero;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @stepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepIndicator(int current, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ctrlSpend'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Know what\'s left to spend.'**
  String get splashTagline;

  /// No description provided for @splashBy.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get splashBy;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Know what\'s left to spend, every day.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Set one monthly budget, log what you spend, and ctrlSpend keeps count.'**
  String get welcomeBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @skipTheTour.
  ///
  /// In en, this message translates to:
  /// **'Skip the tour'**
  String get skipTheTour;

  /// No description provided for @welcomePreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard preview: {amount} left to spend'**
  String welcomePreviewLabel(String amount);

  /// No description provided for @leftToSpend.
  ///
  /// In en, this message translates to:
  /// **'Left to spend'**
  String get leftToSpend;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'spent'**
  String get spent;

  /// No description provided for @categoryPercent.
  ///
  /// In en, this message translates to:
  /// **'{category} · {percent}%'**
  String categoryPercent(String category, int percent);

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howTitle;

  /// No description provided for @howSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three steps, then you\'re in control.'**
  String get howSubtitle;

  /// No description provided for @howBasics.
  ///
  /// In en, this message translates to:
  /// **'The basics'**
  String get howBasics;

  /// No description provided for @howBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set one monthly budget'**
  String get howBudgetTitle;

  /// No description provided for @howBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Pick what you want to spend. Home shows what\'s left.'**
  String get howBudgetBody;

  /// No description provided for @howLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log spending in seconds'**
  String get howLogTitle;

  /// No description provided for @howLogBody.
  ///
  /// In en, this message translates to:
  /// **'Tap +, type the amount, pick a category. Done.'**
  String get howLogBody;

  /// No description provided for @howSeeTitle.
  ///
  /// In en, this message translates to:
  /// **'See where it goes'**
  String get howSeeTitle;

  /// No description provided for @howSeeBody.
  ///
  /// In en, this message translates to:
  /// **'Spot the categories that eat your budget.'**
  String get howSeeBody;

  /// No description provided for @howPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get howPrivacy;

  /// No description provided for @howPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Stays on this phone'**
  String get howPrivacyTitle;

  /// No description provided for @howPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'No account, no bank login. Export a CSV whenever you like.'**
  String get howPrivacyBody;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameTitle;

  /// No description provided for @nameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s how ctrlSpend says hi. Your name stays on this phone.'**
  String get nameSubtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @monthTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your month'**
  String get monthTitle;

  /// No description provided for @monthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Line your budget period up with payday, so each month starts fresh when the money comes in.'**
  String get monthSubtitle;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @monthStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Month starts on'**
  String get monthStartsOn;

  /// No description provided for @startDay1st.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get startDay1st;

  /// No description provided for @startDay15th.
  ///
  /// In en, this message translates to:
  /// **'15th'**
  String get startDay15th;

  /// No description provided for @startDay25th.
  ///
  /// In en, this message translates to:
  /// **'25th'**
  String get startDay25th;

  /// No description provided for @startDayOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get startDayOther;

  /// No description provided for @currentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current period'**
  String get currentPeriod;

  /// No description provided for @periodDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Last day} =1{1 day left} other{{count} days left}}'**
  String periodDaysLeft(int count);

  /// No description provided for @periodWithDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{range} · {daysLeft}'**
  String periodWithDaysLeft(String range, String daysLeft);

  /// No description provided for @currencyMyr.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get currencyMyr;

  /// No description provided for @currencySgd.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get currencySgd;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUsd;

  /// No description provided for @currencyAud.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currencyAud;

  /// No description provided for @currencyBnd.
  ///
  /// In en, this message translates to:
  /// **'Brunei Dollar'**
  String get currencyBnd;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @currencyIdr.
  ///
  /// In en, this message translates to:
  /// **'Indonesian Rupiah'**
  String get currencyIdr;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your monthly budget'**
  String get budgetTitle;

  /// No description provided for @budgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to spend each month? You can change this any time in Budgets.'**
  String get budgetSubtitle;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @budgetPerMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount} per month'**
  String budgetPerMonthLabel(String amount);

  /// No description provided for @budgetBelowLimits.
  ///
  /// In en, this message translates to:
  /// **'Your category limits add up to {amount}. Set at least that.'**
  String budgetBelowLimits(String amount);

  /// No description provided for @splitTitle.
  ///
  /// In en, this message translates to:
  /// **'Split by category'**
  String get splitTitle;

  /// No description provided for @splitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Give limits to the categories you tend to overspend on.'**
  String get splitSubtitle;

  /// No description provided for @allocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocated;

  /// No description provided for @allocatedOf.
  ///
  /// In en, this message translates to:
  /// **'{allocated} of {budget}'**
  String allocatedOf(String allocated, String budget);

  /// No description provided for @flexibleRemainder.
  ///
  /// In en, this message translates to:
  /// **'{amount} stays flexible for everything else.'**
  String flexibleRemainder(String amount);

  /// No description provided for @allocatedLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of monthly budget allocated'**
  String allocatedLabel(int percent);

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addLimit.
  ///
  /// In en, this message translates to:
  /// **'Add limit'**
  String get addLimit;

  /// No description provided for @categoryLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'{category}, limit {amount}'**
  String categoryLimitLabel(String category, String amount);

  /// No description provided for @categoryNoLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'{category}, add limit'**
  String categoryNoLimitLabel(String category);

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'{category} budget'**
  String categoryBudget(String category);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @leftToAllocate.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to allocate'**
  String leftToAllocate(String amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
