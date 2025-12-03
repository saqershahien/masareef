import 'package:grade_project/masareef_transaction.dart';
import 'package:sqflite/sqflite.dart';

Future<void> insertDemoData(Database db) async {
  final batch = db.batch();

  final demoTransactions = [
    MasareefTransaction(
      amount: 50.0,
      date: DateTime.now(),
      category: 'Food',
      type: 'expense',
      notes: 'Lunch today',
    ),
    MasareefTransaction(
      amount: 60.0,
      date: DateTime.now(),
      category: 'Bills',
      type: 'expense',
      notes: 'internet bills',
    ),
    MasareefTransaction(
      amount: 15.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Transport',
      type: 'expense',
      notes: 'Bus fare',
    ),
    MasareefTransaction(
      amount: 1500.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Salary',
      type: 'income',
      notes: 'Monthly salary',
    ),
    MasareefTransaction(
      amount: 75.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Shopping',
      type: 'expense',
      notes: 'New T-shirt',
    ),
    MasareefTransaction(
      amount: 250.0,
      date: DateTime.now().subtract(const Duration(days: 10)),
      category: 'Entertainment',
      type: 'expense',
      notes: 'Movie ticket',
    ),
    MasareefTransaction(
      amount: 75.0,
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: 'Transport',
      type: 'expense',
      notes: 'Monthly bus pass',
    ),
    MasareefTransaction(
      amount: 25.0,
      date: DateTime.now().subtract(const Duration(days: 6)),
      category: 'Restaurants',
      type: 'expense',
      notes: 'Lunch with friends',
    ),
    MasareefTransaction(
      amount: 300.0,
      date: DateTime.now().subtract(const Duration(days: 10)),
      category: 'Investment',
      type: 'income',
      notes: 'Stock dividends',
    ),
    MasareefTransaction(
      amount: 45.0,
      date: DateTime.now().subtract(const Duration(days: 8)),
      category: 'Shopping',
      type: 'expense',
      notes: 'New shirt',
    ),
    MasareefTransaction(
      amount: 100.0,
      date: DateTime.now().subtract(const Duration(days: 12)),
      category: 'Education',
      type: 'expense',
      notes: 'English Course',
    ),
    MasareefTransaction(
      amount: 500.0,
      date: DateTime.now().subtract(const Duration(days: 15)),
      category: 'Rental',
      type: 'income',
      notes: 'Apartment rent',
    ),
    MasareefTransaction(
      amount: 60.0,
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: 'Restaurants',
      type: 'expense',
      notes: 'Dinner with family',
    ),
    MasareefTransaction(
      amount: 40.0,
      date: DateTime.now().subtract(const Duration(days: 15)),
      category: 'Health',
      type: 'expense',
      notes: 'Pharmacy',
    ),
    MasareefTransaction(
      amount: 100.0,
      date: DateTime.now().subtract(const Duration(days: 12)),
      category: 'Travel',
      type: 'expense',
      notes: 'to Homs',
    ),
  ];

  for (final transaction in demoTransactions) {
    batch.insert('transactions', {
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'category': transaction.category,
      'type': transaction.type,
      'notes': transaction.notes,
    });
  }
  await batch.commit(noResult: true);
}
