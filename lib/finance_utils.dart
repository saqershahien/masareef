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
