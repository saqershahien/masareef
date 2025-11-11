import 'package:flutter/material.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatsPage extends StatefulWidget {
  final List<MasareefTransaction> transactions;

  const StatsPage({super.key, required this.transactions});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedPeriod = 'This Week';

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
        title: Text(l10n.statistics, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(totalIncome, totalExpenses),
                  const SizedBox(height: 24),
                  if (spendingData.isNotEmpty) ...[
                    Text(l10n.spendingBreakdown, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildPieChartCard(spendingData, totalExpenses),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          _buildCategoryList(spendingData, totalExpenses),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Center(
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(value: 'Today', label: Text('Today')),
          ButtonSegment<String>(value: 'This Week', label: Text('This Week')),
          ButtonSegment<String>(value: 'This Month', label: Text('This Month')),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedPeriod = newSelection.first;
          });
        },
      ),
    );
  }

  List<MasareefTransaction> _getFilteredTransactions() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        return widget.transactions
            .where((tx) =>
        tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day)
            .toList();
      case 'This Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.transactions.where((tx) => tx.date.isAfter(weekAgo)).toList();
      case 'This Month':
        return widget.transactions
            .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
            .toList();
      default:
        return widget.transactions;
    }
  }

  Map<String, double> _getSpendingByCategory(List<MasareefTransaction> transactions) {
    final Map<String, double> spendingData = {};
    final expenseTransactions = transactions.where((tx) => tx.type == 'expense');

    for (var tx in expenseTransactions) {
      spendingData.update(
        tx.category,
            (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    return spendingData;
  }

  Widget _buildSummaryCards(double totalIncome, double totalExpenses) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              l10n.income, totalIncome, Colors.green, Icons.arrow_upward),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
              l10n.expenses, totalExpenses, Colors.red, Icons.arrow_downward),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                NumberFormat.currency(symbol: 'CFA', decimalDigits: 2).format(amount),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(Map<String, double> spendingData, double totalExpenses) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                children: [
                  SpendingPieChart(spendingData: spendingData, isResponsive: true),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          NumberFormat.currency(symbol: 'CFA', decimalDigits: 0).format(totalExpenses),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: spendingData.entries.map((entry) {
                  final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;
                  final categoryColor = (categoryIcons[entry.key] ?? defaultCategoryInfo).color;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> spendingData, double totalExpenses) {
    final l10n = AppLocalizations.of(context)!;
    if (spendingData.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(l10n.noSpendingDataForThisPeriod, style: Theme.of(context).textTheme.titleLarge),
              Text(l10n.trySelectingADifferentTimeRange, style: Theme.of(context).textTheme.bodyMedium)
            ],
          ),
        ),
      );
    }

    final sortedCategories = spendingData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 0, bottom: 8),
              child: Text(
                l10n.topCategories,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            );
          }
          final entry = sortedCategories[index - 1];
          return _buildCategoryListItem(entry, totalExpenses);
        },
        childCount: sortedCategories.length + 1,
      ),
    );
  }

  Widget _buildCategoryListItem(MapEntry<String, double> entry, double totalExpenses) {
    final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) : 0.0;
    final categoryInfo = categoryIcons[entry.key] ?? defaultCategoryInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: categoryInfo.color.withAlpha(51),
                child: Icon(
                  categoryInfo.icon,
                  color: categoryInfo.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(categoryInfo.color),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NumberFormat.currency(symbol: 'CFA').format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(percentage * 100).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
