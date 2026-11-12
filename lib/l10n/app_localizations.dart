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

  /// No description provided for @transactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionTitle;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @categoryRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryRowLabel;

  /// No description provided for @dateRowLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateRowLabelTitle;

  /// No description provided for @noteRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteRowLabel;

  /// No description provided for @budgetImpact.
  ///
  /// In en, this message translates to:
  /// **'Budget impact'**
  String get budgetImpact;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTransaction;

  /// No description provided for @amountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(String amount);

  /// No description provided for @overBy.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String overBy(String amount);

  /// No description provided for @spentOfThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} this period'**
  String spentOfThisPeriod(String spent, String limit);

  /// No description provided for @spentOfInPeriod.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} in {period}'**
  String spentOfInPeriod(String spent, String limit, String period);

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time}'**
  String dateAndTime(String date, String time);

  /// No description provided for @percentOfSpent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {name} spent'**
  String percentOfSpent(int percent, String name);

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @leftWord.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get leftWord;

  /// No description provided for @overWord.
  ///
  /// In en, this message translates to:
  /// **'over'**
  String get overWord;

  /// No description provided for @spentOfBudget.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {budget} spent'**
  String spentOfBudget(String spent, String budget);

  /// No description provided for @spentAndLeft.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} · Left {left}'**
  String spentAndLeft(String spent, String left);

  /// No description provided for @spentAndOver.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} · Over by {over}'**
  String spentAndOver(String spent, String over);

  /// No description provided for @addLimitSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a limit'**
  String get addLimitSheetTitle;

  /// No description provided for @budgetCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget, {amount} {state}, {detail}'**
  String budgetCardLabel(String amount, String state, String detail);

  /// No description provided for @categoryBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {percent}%, {detail}'**
  String categoryBudgetLabel(String name, int percent, String detail);

  /// No description provided for @dataStoredOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Data stored on this phone'**
  String get dataStoredOnPhone;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @manageSection.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageSection;

  /// No description provided for @themeRow.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeRow;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get importCsv;

  /// No description provided for @nameSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameSheetTitle;

  /// No description provided for @monthStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the day your budget resets. Most people choose payday.'**
  String get monthStartSubtitle;

  /// No description provided for @lastDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Last day of the month'**
  String get lastDayOfMonth;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {detail}'**
  String profileLabel(String name, String detail);

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @iconSection.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconSection;

  /// No description provided for @colourSection.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colourSection;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get monthlyLimit;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategory;

  /// No description provided for @duplicateCategory.
  ///
  /// In en, this message translates to:
  /// **'{type, select, expense{You already have an expense category called {name}.} other{You already have an income category called {name}.}}'**
  String duplicateCategory(String type, String name);

  /// No description provided for @archivedSection.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedSection;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @categoriesNote.
  ///
  /// In en, this message translates to:
  /// **'Categories with transactions are archived instead of deleted, so your history stays intact.'**
  String get categoriesNote;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categoryArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived — it has transactions'**
  String categoryArchived(String name);

  /// No description provided for @colourName.
  ///
  /// In en, this message translates to:
  /// **'{colour, select, orange{Orange} blue{Blue} pink{Pink} yellow{Yellow} purple{Purple} green{Green} red{Red} other{Grey}}'**
  String colourName(String colour);

  /// No description provided for @iconName.
  ///
  /// In en, this message translates to:
  /// **'{icon, select, food{Food} coffee{Coffee} car{Car} bag{Bag} bolt{Bolt} film{Film} heart{Heart} gift{Gift} book{Book} travel{Travel} home{Home} phone{Phone} other{Wallet}}'**
  String iconName(String icon);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes and categories'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @allChip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allChip;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noResultsTitle(String query);

  /// No description provided for @noResultsInChip.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches in {chip}. Try another word, or search all transactions.'**
  String noResultsInChip(String chip);

  /// No description provided for @noResultsAll.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches. Try another word.'**
  String get noResultsAll;

  /// No description provided for @searchAll.
  ///
  /// In en, this message translates to:
  /// **'Search all'**
  String get searchAll;

  /// No description provided for @nothingHereTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereTitle;

  /// No description provided for @nothingInChip.
  ///
  /// In en, this message translates to:
  /// **'No transactions in {chip} so far.'**
  String nothingInChip(String chip);

  /// No description provided for @insightsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insightsWeek;

  /// No description provided for @insightsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insightsMonth;

  /// No description provided for @insightsSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get insightsSixMonths;

  /// No description provided for @spentInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Spent {period}'**
  String spentInPeriod(String period);

  /// No description provided for @spendingCategories.
  ///
  /// In en, this message translates to:
  /// **'Spending categories'**
  String get spendingCategories;

  /// No description provided for @spendingSummary.
  ///
  /// In en, this message translates to:
  /// **'Spending by category: {shares}'**
  String spendingSummary(String shares);

  /// No description provided for @categoryShare.
  ///
  /// In en, this message translates to:
  /// **'{category} {percent}%, {amount}'**
  String categoryShare(String category, int percent, String amount);

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Charts appear once you\'ve logged a few days of spending.'**
  String get insightsEmptyBody;

  /// No description provided for @addAnExpense.
  ///
  /// In en, this message translates to:
  /// **'Add an expense'**
  String get addAnExpense;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @weekRangeAverage.
  ///
  /// In en, this message translates to:
  /// **'{range} · avg {amount} a day'**
  String weekRangeAverage(String range, String amount);

  /// No description provided for @paceChip.
  ///
  /// In en, this message translates to:
  /// **'Pace {amount}/day'**
  String paceChip(String amount);

  /// No description provided for @dailyPace.
  ///
  /// In en, this message translates to:
  /// **'Daily pace'**
  String get dailyPace;

  /// No description provided for @todayBubble.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get todayBubble;

  /// No description provided for @underPace.
  ///
  /// In en, this message translates to:
  /// **'Under pace'**
  String get underPace;

  /// No description provided for @overPace.
  ///
  /// In en, this message translates to:
  /// **'Over pace'**
  String get overPace;

  /// No description provided for @countOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String countOfTotal(int count, int total);

  /// No description provided for @daysThisWeek.
  ///
  /// In en, this message translates to:
  /// **'days this week'**
  String get daysThisWeek;

  /// No description provided for @biggestDay.
  ///
  /// In en, this message translates to:
  /// **'Biggest day'**
  String get biggestDay;

  /// No description provided for @biggestDayCaption.
  ///
  /// In en, this message translates to:
  /// **'{day} · {title}'**
  String biggestDayCaption(String day, String title);

  /// No description provided for @weekChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily spending, pace {pace} a day: {days}'**
  String weekChartLabel(String pace, String days);

  /// No description provided for @weekChartLabelNoPace.
  ///
  /// In en, this message translates to:
  /// **'Daily spending: {days}'**
  String weekChartLabelNoPace(String days);

  /// No description provided for @dayUnderPace.
  ///
  /// In en, this message translates to:
  /// **'{day} {amount}, under pace'**
  String dayUnderPace(String day, String amount);

  /// No description provided for @dayOverPace.
  ///
  /// In en, this message translates to:
  /// **'{day} {amount}, over pace'**
  String dayOverPace(String day, String amount);

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'{day} {amount}, today'**
  String dayToday(String day, String amount);

  /// No description provided for @labelAmount.
  ///
  /// In en, this message translates to:
  /// **'{label} {amount}'**
  String labelAmount(String label, String amount);

  /// No description provided for @statCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, {value} {caption}'**
  String statCaptionLabel(String label, String value, String caption);

  /// No description provided for @avgPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Avg per month'**
  String get avgPerMonth;

  /// No description provided for @fullMonthsRange.
  ///
  /// In en, this message translates to:
  /// **'{range}, {count, plural, =1{full month} other{full months}}'**
  String fullMonthsRange(String range, int count);

  /// No description provided for @noFullMonths.
  ///
  /// In en, this message translates to:
  /// **'No full months yet'**
  String get noFullMonths;

  /// No description provided for @budgetChip.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount}'**
  String budgetChip(String amount);

  /// No description provided for @budgetLine.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetLine;

  /// No description provided for @underBudget.
  ///
  /// In en, this message translates to:
  /// **'Under budget'**
  String get underBudget;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @thisPeriod.
  ///
  /// In en, this message translates to:
  /// **'This period'**
  String get thisPeriod;

  /// No description provided for @soFar.
  ///
  /// In en, this message translates to:
  /// **'so far'**
  String get soFar;

  /// No description provided for @fullMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{full month} other{full months}}'**
  String fullMonths(int count);

  /// No description provided for @highestMonth.
  ///
  /// In en, this message translates to:
  /// **'Highest month'**
  String get highestMonth;

  /// No description provided for @trendChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending, budget {budget}: {periods}'**
  String trendChartLabel(String budget, String periods);

  /// No description provided for @trendChartLabelNoBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending: {periods}'**
  String trendChartLabelNoBudget(String periods);

  /// No description provided for @periodUnderBudget.
  ///
  /// In en, this message translates to:
  /// **'{month} {amount}, under budget'**
  String periodUnderBudget(String month, String amount);

  /// No description provided for @periodOverBudget.
  ///
  /// In en, this message translates to:
  /// **'{month} {amount}, over budget'**
  String periodOverBudget(String month, String amount);

  /// No description provided for @periodSoFar.
  ///
  /// In en, this message translates to:
  /// **'{month} {amount}, so far'**
  String periodSoFar(String month, String amount);

  /// No description provided for @pastPeriods.
  ///
  /// In en, this message translates to:
  /// **'Past periods'**
  String get pastPeriods;

  /// No description provided for @viewPastPeriods.
  ///
  /// In en, this message translates to:
  /// **'View past periods'**
  String get viewPastPeriods;

  /// No description provided for @previousPeriods.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPeriods;

  /// No description provided for @amountUnder.
  ///
  /// In en, this message translates to:
  /// **'{amount} under'**
  String amountUnder(String amount);

  /// No description provided for @spentOfAmount.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {budget}'**
  String spentOfAmount(String spent, String budget);

  /// No description provided for @noBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget'**
  String get noBudget;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @amountOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String amountOver(String amount);

  /// No description provided for @limitAmount.
  ///
  /// In en, this message translates to:
  /// **'limit {limit}'**
  String limitAmount(String limit);

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryTitle;

  /// No description provided for @categoryTypeCount.
  ///
  /// In en, this message translates to:
  /// **'{type} · {count, plural, =1{1 transaction} other{{count} transactions}}'**
  String categoryTypeCount(String type, int count);

  /// No description provided for @daysToGo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Last day} =1{1 day to go} other{{count} days to go}}'**
  String daysToGo(int count);

  /// No description provided for @noLimitWithDays.
  ///
  /// In en, this message translates to:
  /// **'No limit · {days}'**
  String noLimitWithDays(String days);

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @iconAndColour.
  ///
  /// In en, this message translates to:
  /// **'Icon & colour'**
  String get iconAndColour;

  /// No description provided for @recentSection.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSection;

  /// No description provided for @archiveCategory.
  ///
  /// In en, this message translates to:
  /// **'Archive category'**
  String get archiveCategory;

  /// No description provided for @restoreCategory.
  ///
  /// In en, this message translates to:
  /// **'Restore category'**
  String get restoreCategory;

  /// No description provided for @categoryPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'This period, {spent}, {detail}'**
  String categoryPeriodLabel(String spent, String detail);

  /// No description provided for @themeNote.
  ///
  /// In en, this message translates to:
  /// **'System matches your phone\'s light or dark setting automatically.'**
  String get themeNote;

  /// No description provided for @searchCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Search currencies'**
  String get searchCurrencies;

  /// No description provided for @suggestedSection.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggestedSection;

  /// No description provided for @allCurrencies.
  ///
  /// In en, this message translates to:
  /// **'All currencies'**
  String get allCurrencies;

  /// No description provided for @currencyCurrent.
  ///
  /// In en, this message translates to:
  /// **'{code} · current'**
  String currencyCurrent(String code);

  /// No description provided for @currencyNote.
  ///
  /// In en, this message translates to:
  /// **'Switching currency changes the symbol only. Existing amounts aren\'t converted.'**
  String get currencyNote;

  /// No description provided for @noCurrencyMatch.
  ///
  /// In en, this message translates to:
  /// **'No currencies match “{query}”'**
  String noCurrencyMatch(String query);

  /// No description provided for @notifyCategoryWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} is at {percent}% of its limit'**
  String notifyCategoryWarningTitle(String category, int percent);

  /// No description provided for @notifyBudgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Your budget is at {percent}%'**
  String notifyBudgetWarningTitle(int percent);

  /// No description provided for @notifyWarningBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{amount} left for the rest of today.} =1{{amount} left with 1 day to go.} other{{amount} left with {count} days to go.}}'**
  String notifyWarningBody(String amount, int count);

  /// No description provided for @notifyCategoryOverTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} is over budget'**
  String notifyCategoryOverTitle(String category);

  /// No description provided for @notifyCategoryOverBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {spent} of your {limit} limit.'**
  String notifyCategoryOverBody(String spent, String limit);

  /// No description provided for @notifyBudgetOverTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re over budget'**
  String get notifyBudgetOverTitle;

  /// No description provided for @notifyBudgetOverBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {spent} of your {budget} budget.'**
  String notifyBudgetOverBody(String spent, String budget);

  /// No description provided for @notifyIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} added'**
  String notifyIncomeTitle(String category);

  /// No description provided for @notifyIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} recorded as Income.'**
  String notifyIncomeBody(String amount);

  /// No description provided for @notifyDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get notifyDailyTitle;

  /// No description provided for @notifyDailyBody.
  ///
  /// In en, this message translates to:
  /// **'Anything to log from today? It takes ten seconds.'**
  String get notifyDailyBody;

  /// No description provided for @notifyWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weekly summary'**
  String get notifyWeeklyTitle;

  /// No description provided for @notifyWeeklyLess.
  ///
  /// In en, this message translates to:
  /// **'You spent {spent} last week, {difference} less than the week before.'**
  String notifyWeeklyLess(String spent, String difference);

  /// No description provided for @notifyWeeklyMore.
  ///
  /// In en, this message translates to:
  /// **'You spent {spent} last week, {difference} more than the week before.'**
  String notifyWeeklyMore(String spent, String difference);

  /// No description provided for @notifyWeeklySame.
  ///
  /// In en, this message translates to:
  /// **'You spent {spent} last week, the same as the week before.'**
  String notifyWeeklySame(String spent);

  /// No description provided for @notifyWeeklyReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weekly summary is ready'**
  String get notifyWeeklyReadyTitle;

  /// No description provided for @notifyWeeklyReadyBody.
  ///
  /// In en, this message translates to:
  /// **'See how last week went.'**
  String get notifyWeeklyReadyBody;

  /// No description provided for @notifyPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'New period started'**
  String get notifyPeriodTitle;

  /// No description provided for @notifyPeriodBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'{range}. Your {budget} budget has reset.'**
  String notifyPeriodBudgetBody(String range, String budget);

  /// No description provided for @notifyPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Your new period runs {range}.'**
  String notifyPeriodBody(String range);

  /// No description provided for @earlierSection.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlierSection;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String hoursAgo(int count);

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know when a budget gets close to its limit, and remind you to log your spending.'**
  String get noNotificationsBody;

  /// No description provided for @youllHearAbout.
  ///
  /// In en, this message translates to:
  /// **'You\'ll hear about'**
  String get youllHearAbout;

  /// No description provided for @at80And100.
  ///
  /// In en, this message translates to:
  /// **'At 80% and 100%'**
  String get at80And100;

  /// No description provided for @onLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onLabel;

  /// No description provided for @offLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offLabel;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Notifications} =1{Notifications, 1 unread} other{Notifications, {count} unread}}'**
  String notificationsUnread(int count);

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportTitle;

  /// No description provided for @exportIntro.
  ///
  /// In en, this message translates to:
  /// **'Save your transactions as a CSV file you can open in Sheets or Excel, or import on a new phone.'**
  String get exportIntro;

  /// No description provided for @rangeSection.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get rangeSection;

  /// No description provided for @includeSection.
  ///
  /// In en, this message translates to:
  /// **'Include'**
  String get includeSection;

  /// No description provided for @rangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get rangeAllTime;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get rangeCustom;

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @exportCsvButton.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvButton;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 transaction to Files} other{Saved {count} transactions to Files}}'**
  String exportSaved(int count);

  /// No description provided for @nothingToExport.
  ///
  /// In en, this message translates to:
  /// **'No transactions to export'**
  String get nothingToExport;
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
