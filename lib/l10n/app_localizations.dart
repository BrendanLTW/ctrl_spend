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

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A nudge at the end of the day helps you log spending before you forget it.'**
  String get remindersSubtitle;

  /// No description provided for @sampleNotification.
  ///
  /// In en, this message translates to:
  /// **'You have RM 72 left for Food this period. Log today\'s spending?'**
  String get sampleNotification;

  /// No description provided for @notificationNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get notificationNow;

  /// No description provided for @notifyMeAbout.
  ///
  /// In en, this message translates to:
  /// **'Notify me about'**
  String get notifyMeAbout;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderAt.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String dailyReminderAt(String time);

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// No description provided for @budgetAlertsDetail.
  ///
  /// In en, this message translates to:
  /// **'When a budget reaches 80% and 100%'**
  String get budgetAlertsDetail;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get weeklySummary;

  /// No description provided for @weeklySummaryDetail.
  ///
  /// In en, this message translates to:
  /// **'Sunday evenings'**
  String get weeklySummaryDetail;

  /// No description provided for @turnOnNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get turnOnNotifications;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allSetTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get allSetTitle;

  /// No description provided for @allSetBody.
  ///
  /// In en, this message translates to:
  /// **'Add what you\'ve spent since {date} to see what\'s really left this period.'**
  String allSetBody(String date);

  /// No description provided for @yourSetup.
  ///
  /// In en, this message translates to:
  /// **'Your setup'**
  String get yourSetup;

  /// No description provided for @categoryLimits.
  ///
  /// In en, this message translates to:
  /// **'Category limits'**
  String get categoryLimits;

  /// No description provided for @limitsCount.
  ///
  /// In en, this message translates to:
  /// **'{limited} of {total}'**
  String limitsCount(int limited, int total);

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily, {time}'**
  String remindersDaily(String time);

  /// No description provided for @remindersWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly, Sunday'**
  String get remindersWeekly;

  /// No description provided for @remindersAlertsOnly.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts only'**
  String get remindersAlertsOnly;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @lastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get lastDay;

  /// No description provided for @ordinalDay.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{1st} 2{2nd} 3{3rd} 21{21st} 22{22nd} 23{23rd} other{{day}th}}'**
  String ordinalDay(String day);

  /// No description provided for @addFirstExpense.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense'**
  String get addFirstExpense;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to dashboard'**
  String get goToDashboard;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// No description provided for @greetingNoName.
  ///
  /// In en, this message translates to:
  /// **'Hi there'**
  String get greetingNoName;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @statLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, {amount}'**
  String statLabel(String label, String amount);

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent activities'**
  String get recentActivities;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @dayAndDetail.
  ///
  /// In en, this message translates to:
  /// **'{day} · {detail}'**
  String dayAndDetail(String day, String detail);

  /// No description provided for @overBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'Over budget by'**
  String get overBudgetBy;

  /// No description provided for @spentThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Spent this period'**
  String get spentThisPeriod;

  /// No description provided for @amountSpent.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String amountSpent(String amount);

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofAmount(String amount);

  /// No description provided for @setMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get setMonthlyBudget;

  /// No description provided for @budgetSpentPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of monthly budget spent'**
  String budgetSpentPercent(int percent);

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Add what you spend and your budget updates as you go.'**
  String get noTransactionsBody;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpense;

  /// No description provided for @newIncome.
  ///
  /// In en, this message translates to:
  /// **'New income'**
  String get newIncome;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total amount {amount}'**
  String totalAmountLabel(String amount);

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get addNote;

  /// No description provided for @categorySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categorySheetTitle;

  /// No description provided for @dateSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateSheetTitle;

  /// No description provided for @amountSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountSheetTitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @setDate.
  ///
  /// In en, this message translates to:
  /// **'Set {date}'**
  String setDate(String date);

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String dateToday(String date);

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {date}'**
  String dateYesterday(String date);

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'{title} ({amount}) will be removed and {amount} goes back to your {category} budget.'**
  String deleteExpenseBody(String title, String amount, String category);

  /// No description provided for @deleteIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'{title} ({amount}) will be removed.'**
  String deleteIncomeBody(String title, String amount);
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
