import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/widgets/category_list.dart';
import 'package:grade_project/widgets/period_selector.dart';
import 'package:grade_project/widgets/pie_chart_card.dart';
import 'package:grade_project/widgets/summary_card.dart';

class StatsPage extends StatefulWidget {
  final List<MasareefTransaction> transactions;

  const StatsPage({super.key, required this.transactions});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedPeriod = 'This Week';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedPeriod = AppLocalizations.of(context)!.thisWeek;
  }

  List<MasareefTransaction> _getFilteredTransactions() {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;
    if (_selectedPeriod == l10n.today) {
      return widget.transactions
          .where((tx) =>
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day)
          .toList();
    } else if (_selectedPeriod == l10n.thisWeek) {
      final weekAgo = now.subtract(const Duration(days: 7));
      return widget.transactions
          .where((tx) => tx.date.isAfter(weekAgo))
          .toList();
    } else if (_selectedPeriod == l10n.thisMonth) {
      return widget.transactions
          .where(
              (tx) => tx.date.year == now.year && tx.date.month == now.month)
          .toList();
    }
    return widget.transactions;
  }

  Map<String, double> _getSpendingByCategory(
      List<MasareefTransaction> transactions) {
    final Map<String, double> spendingData = {};
    final expenseTransactions =
        transactions.where((tx) => tx.type == 'expense');

    for (var tx in expenseTransactions) {
      spendingData.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    return spendingData;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredTransactions = _getFilteredTransactions();
    final spendingData = _getSpendingByCategory(filteredTransactions);
    final totalIncome = filteredTransactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
    final totalExpenses = spendingData.values.fold(0.0, (sum, item) => sum + item);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    onSelectionChanged: (newPeriod) {
                      setState(() {
                        _selectedPeriod = newPeriod;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                            title: l10n.income,
                            amount: totalIncome,
                            color: Colors.green,
                            icon: Icons.arrow_upward),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SummaryCard(
                            title: l10n.expenses,
                            amount: totalExpenses,
                            color: Colors.red,
                            icon: Icons.arrow_downward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (spendingData.isNotEmpty) ...[
                    Text(l10n.spendingBreakdown,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    PieChartCard(
                        spendingData: spendingData,
                        totalExpenses: totalExpenses),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          CategoryList(
              spendingData: spendingData, totalExpenses: totalExpenses),
        ],
      ),
    );
  }
}
