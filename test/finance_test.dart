import 'package:grade_project/finance_utils.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('getFinancialSummary', () {
    test('returns correct summary for a list of transactions', () {
      // Arrange
      final transactions = [
        MasareefTransaction(
            amount: 100.0,
            date: DateTime.now(),
            category: 'Salary',
            type: 'income'),
        MasareefTransaction(
            amount: 25.0,
            date: DateTime.now(),
            category: 'Groceries',
            type: 'expense'),
        MasareefTransaction(
            amount: 50.0,
            date: DateTime.now(),
            category: 'Freelance',
            type: 'income'),
        MasareefTransaction(
            amount: 10.0,
            date: DateTime.now(),
            category: 'Transport',
            type: 'expense'),
      ];

      // Act
      final summary = getFinancialSummary(transactions);

      // Assert
      expect(summary['income'], 150.0);
      expect(summary['expenses'], 35.0);
      expect(summary['balance'], 115.0);
    });

    test('returns zero for all fields when the transaction list is empty', () {
      // Arrange
      final transactions = <MasareefTransaction>[];

      // Act
      final summary = getFinancialSummary(transactions);

      // Assert
      expect(summary['income'], 0.0);
      expect(summary['expenses'], 0.0);
      expect(summary['balance'], 0.0);
    });
  });
}
