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

  @override
  String get nameTitle => 'What should we call you?';

  @override
  String get nameSubtitle =>
      'It\'s how ctrlSpend says hi. Your name stays on this phone.';

  @override
  String get firstName => 'First name';

  @override
  String get monthTitle => 'Set up your month';

  @override
  String get monthSubtitle =>
      'Line your budget period up with payday, so each month starts fresh when the money comes in.';

  @override
  String get currency => 'Currency';

  @override
  String get monthStartsOn => 'Month starts on';

  @override
  String get startDay1st => '1st';

  @override
  String get startDay15th => '15th';

  @override
  String get startDay25th => '25th';

  @override
  String get startDayOther => 'Other';

  @override
  String get currentPeriod => 'Current period';

  @override
  String periodDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String periodWithDaysLeft(String range, String daysLeft) {
    return '$range · $daysLeft';
  }

  @override
  String get currencyMyr => 'Malaysian Ringgit';

  @override
  String get currencySgd => 'Singapore Dollar';

  @override
  String get currencyUsd => 'US Dollar';

  @override
  String get currencyAud => 'Australian Dollar';

  @override
  String get currencyBnd => 'Brunei Dollar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyIdr => 'Indonesian Rupiah';

  @override
  String get budgetTitle => 'Set your monthly budget';

  @override
  String get budgetSubtitle =>
      'How much do you want to spend each month? You can change this any time in Budgets.';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get perMonth => 'per month';

  @override
  String budgetPerMonthLabel(String amount) {
    return 'Budget $amount per month';
  }

  @override
  String budgetBelowLimits(String amount) {
    return 'Your category limits add up to $amount. Set at least that.';
  }

  @override
  String get splitTitle => 'Split by category';

  @override
  String get splitSubtitle =>
      'Optional. Give limits to the categories you tend to overspend on.';

  @override
  String get allocated => 'Allocated';

  @override
  String allocatedOf(String allocated, String budget) {
    return '$allocated of $budget';
  }

  @override
  String flexibleRemainder(String amount) {
    return '$amount stays flexible for everything else.';
  }

  @override
  String allocatedLabel(int percent) {
    return '$percent% of monthly budget allocated';
  }

  @override
  String get categories => 'Categories';

  @override
  String get addLimit => 'Add limit';

  @override
  String categoryLimitLabel(String category, String amount) {
    return '$category, limit $amount';
  }

  @override
  String categoryNoLimitLabel(String category) {
    return '$category, add limit';
  }

  @override
  String categoryBudget(String category) {
    return '$category budget';
  }

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String leftToAllocate(String amount) {
    return '$amount left to allocate';
  }

  @override
  String get remindersTitle => 'Stay on track';

  @override
  String get remindersSubtitle =>
      'A nudge at the end of the day helps you log spending before you forget it.';

  @override
  String get sampleNotification =>
      'You have RM 72 left for Food this period. Log today\'s spending?';

  @override
  String get notificationNow => 'now';

  @override
  String get notifyMeAbout => 'Notify me about';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String dailyReminderAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get budgetAlertsDetail => 'When a budget reaches 80% and 100%';

  @override
  String get weeklySummary => 'Weekly summary';

  @override
  String get weeklySummaryDetail => 'Sunday evenings';

  @override
  String get turnOnNotifications => 'Turn on notifications';

  @override
  String get notNow => 'Not now';

  @override
  String get allSetTitle => 'You\'re all set';

  @override
  String allSetBody(String date) {
    return 'Add what you\'ve spent since $date to see what\'s really left this period.';
  }

  @override
  String get yourSetup => 'Your setup';

  @override
  String get categoryLimits => 'Category limits';

  @override
  String limitsCount(int limited, int total) {
    return '$limited of $total';
  }

  @override
  String get reminders => 'Reminders';

  @override
  String remindersDaily(String time) {
    return 'Daily, $time';
  }

  @override
  String get remindersWeekly => 'Weekly, Sunday';

  @override
  String get remindersAlertsOnly => 'Budget alerts only';

  @override
  String get remindersOff => 'Off';

  @override
  String get notSet => 'Not set';

  @override
  String get lastDay => 'Last day';

  @override
  String ordinalDay(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': '1st',
      '2': '2nd',
      '3': '3rd',
      '21': '21st',
      '22': '22nd',
      '23': '23rd',
      'other': '${day}th',
    });
    return '$_temp0';
  }

  @override
  String get addFirstExpense => 'Add your first expense';

  @override
  String get goToDashboard => 'Go to dashboard';

  @override
  String greeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get greetingNoName => 'Hi there';

  @override
  String get notifications => 'Notifications';

  @override
  String get spentLabel => 'Spent';

  @override
  String get incomeLabel => 'Income';

  @override
  String statLabel(String label, String amount) {
    return '$label, $amount';
  }

  @override
  String get recentActivities => 'Recent activities';

  @override
  String get viewAll => 'View all';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String dayAndDetail(String day, String detail) {
    return '$day · $detail';
  }

  @override
  String get overBudgetBy => 'Over budget by';

  @override
  String get spentThisPeriod => 'Spent this period';

  @override
  String amountSpent(String amount) {
    return '$amount spent';
  }

  @override
  String ofAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get setMonthlyBudget => 'Set a monthly budget';

  @override
  String budgetSpentPercent(int percent) {
    return '$percent% of monthly budget spent';
  }

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get noTransactionsBody =>
      'Add what you spend and your budget updates as you go.';

  @override
  String get newExpense => 'New expense';

  @override
  String get newIncome => 'New income';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get delete => 'Delete';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get totalAmount => 'Total amount';

  @override
  String totalAmountLabel(String amount) {
    return 'Total amount $amount';
  }

  @override
  String get selectCategory => 'Select category';

  @override
  String get more => 'More';

  @override
  String get addNote => 'Add a note…';

  @override
  String get categorySheetTitle => 'Category';

  @override
  String get dateSheetTitle => 'Date';

  @override
  String get amountSheetTitle => 'Amount';

  @override
  String get done => 'Done';

  @override
  String setDate(String date) {
    return 'Set $date';
  }

  @override
  String dateToday(String date) {
    return 'Today, $date';
  }

  @override
  String dateYesterday(String date) {
    return 'Yesterday, $date';
  }

  @override
  String get deleteTransactionTitle => 'Delete this transaction?';

  @override
  String deleteExpenseBody(String title, String amount, String category) {
    return '$title ($amount) will be removed and $amount goes back to your $category budget.';
  }

  @override
  String deleteIncomeBody(String title, String amount) {
    return '$title ($amount) will be removed.';
  }

  @override
  String get transactionTitle => 'Transaction';

  @override
  String get details => 'Details';

  @override
  String get categoryRowLabel => 'Category';

  @override
  String get dateRowLabelTitle => 'Date';

  @override
  String get noteRowLabel => 'Note';

  @override
  String get budgetImpact => 'Budget impact';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String amountLeft(String amount) {
    return '$amount left';
  }

  @override
  String overBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String spentOfThisPeriod(String spent, String limit) {
    return '$spent of $limit this period';
  }

  @override
  String spentOfInPeriod(String spent, String limit, String period) {
    return '$spent of $limit in $period';
  }

  @override
  String dateAndTime(String date, String time) {
    return '$date · $time';
  }

  @override
  String percentOfSpent(int percent, String name) {
    return '$percent% of $name spent';
  }

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get undo => 'Undo';
}
