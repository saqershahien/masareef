import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masareef/l10n/app_localizations.dart';
import 'package:masareef/masareef_transaction.dart';
import 'package:masareef/stats_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masareef/widgets/pie_chart_card.dart';

void main() {
  group('StatsPage', () {
    final mockTransactions = [
      MasareefTransaction(
        amount: 100.0,
        date: DateTime.now(),
        category: 'Salary',
        type: 'income',
      ),
      MasareefTransaction(
        amount: 25.0,
        date: DateTime.now(),
        category: 'Groceries',
        type: 'expense',
      ),
      MasareefTransaction(
        amount: 10.0,
        date: DateTime.now().subtract(const Duration(days: 8)),
        category: 'Transport',
        type: 'expense',
      ),
    ];

    testWidgets('displays summary cards and spending breakdown correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
            Locale('ar', ''), // Arabic, no country code
          ],
          home: StatsPage(transactions: mockTransactions),
        ),
      );

      // Wait for the localization to load
      await tester.pumpAndSettle();

      // Check for the title
      expect(find.text('Statistics'), findsOneWidget);

      // Check for summary cards (defaulting to 'This Week')
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);

      // Verify the amounts based on 'This Week' filter
      expect(find.textContaining('100.00'), findsOneWidget);
      expect(find.textContaining('25.00'), findsNWidgets(2));

      // Check for spending breakdown
      expect(find.text('Spending Breakdown'), findsOneWidget);
      expect(find.byType(PieChartCard), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });
  });
}
