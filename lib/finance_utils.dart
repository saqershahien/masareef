import 'package:grade_project/masareef_transaction.dart';

Map<String, double> getFinancialSummary(
    List<MasareefTransaction> transactions) {
  double income = 0.0;
  double expenses = 0.0;
  for (var tx in transactions) {
    if (tx.type == 'income') {
      income += tx.amount;
    } else {
      expenses += tx.amount;
    }
  }
  return {
    'income': income,
    'expenses': expenses,
    'balance': income - expenses,
  };
}

Map<String, double> getMonthlyFinancialSummary(
    List<MasareefTransaction> transactions) {
  double currentMonthIncome = 0.0;
  double currentMonthExpenses = 0.0;
  double previousBalance = 0.0;

  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;

  for (var tx in transactions) {
    final txDate = tx.date;

    if (txDate.year == currentYear && txDate.month == currentMonth) {
      // Transaction is in the current month
      if (tx.type == 'income') {
        currentMonthIncome += tx.amount;
      } else {
        currentMonthExpenses += tx.amount;
      }
    } else if (txDate.year < currentYear || (txDate.year == currentYear && txDate.month < currentMonth)) {
      // Transaction is from a previous month, so it contributes to the opening balance
      if (tx.type == 'income') {
        previousBalance += tx.amount;
      } else {
        previousBalance -= tx.amount;
      }
    }
  }

  return {
    'income': currentMonthIncome,
    'expenses': currentMonthExpenses,
    'balance': previousBalance + currentMonthIncome - currentMonthExpenses,
  };
}
