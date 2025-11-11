// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloAdam => 'Hello Adam';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get home => 'Home';

  @override
  String get stats => 'Stats';

  @override
  String get export => 'Export';

  @override
  String get settings => 'Settings';

  @override
  String get noTransactionsYet => 'No transactions yet.';

  @override
  String get addNewTransactionToGetStarted =>
      'Add a new transaction to get started.';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get addNewTransaction => 'Add New Transaction';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than zero.';

  @override
  String get category => 'Category';

  @override
  String get notes => 'Notes';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get areYouSureYouWantToDeleteThisTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get delete => 'Delete';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get statistics => 'Statistics';

  @override
  String get spendingBreakdown => 'Spending Breakdown';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get noSpendingDataForThisPeriod => 'No spending data for this period.';

  @override
  String get trySelectingADifferentTimeRange =>
      'Try selecting a different time range.';
}
