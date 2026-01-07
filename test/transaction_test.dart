import 'package:flutter_test/flutter_test.dart';
import 'package:masareef/masareef_transaction.dart';

void main() {
  group('Transaction operations', () {
    test('should add a new transaction to a list', () {
      // Arrange
      final transactions = <MasareefTransaction>[
        MasareefTransaction(
          id: 1,
          amount: 50.0,
          date: DateTime.now(),
          category: 'Groceries',
          type: 'expense',
        ),
      ];

      final newTransaction = MasareefTransaction(
        id: 2,
        amount: 75.0,
        date: DateTime.now(),
        category: 'Salary',
        type: 'income',
      );

      // Act
      transactions.add(newTransaction);

      // Assert
      expect(transactions.length, 2);
      expect(transactions.last, newTransaction);
    });

    test('should edit an existing transaction in a list', () {
      // Arrange
      final initialTransaction = MasareefTransaction(
        id: 1,
        amount: 50.0,
        date: DateTime.now(),
        category: 'Groceries',
        type: 'expense',
      );
      final transactions = <MasareefTransaction>[initialTransaction];

      final editedTransaction = MasareefTransaction(
        id: 1, // Same ID
        amount: 60.0, // New amount
        date: initialTransaction.date,
        category: 'Supermarket', // New category
        type: 'expense',
      );

      // Act
      final index = transactions.indexWhere((t) => t.id == editedTransaction.id);
      if (index != -1) {
        transactions[index] = editedTransaction;
      }

      // Assert
      expect(transactions.length, 1);
      expect(transactions.first.amount, 60.0);
      expect(transactions.first.category, 'Supermarket');
    });
  });
}
