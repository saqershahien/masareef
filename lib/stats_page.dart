import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/widgets/category_list.dart';
import 'package:grade_project/widgets/period_selector.dart';
import 'package:grade_project/widgets/pie_chart_card.dart';
import 'package:grade_project/widgets/summary_card.dart';

/// A page that displays financial statistics, including income, expenses, and spending breakdown by category.
///
/// It allows users to filter transactions by different time periods (e.g., Today, This Week, This Month).
class StatsPage extends StatefulWidget {
  /// The list of all transactions to be analyzed.
  final List<MasareefTransaction> transactions;

  const StatsPage({super.key, required this.transactions});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

/// The state for the [StatsPage] widget.
class _StatsPageState extends State<StatsPage> {
  /// The currently selected time period for filtering transactions.
  String _selectedPeriod = 'This Week';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the selected period with the localized "This Week" string.
    _selectedPeriod = AppLocalizations.of(context)!.thisWeek;
  }

  /// Filters the list of transactions based on the [_selectedPeriod].
  ///
  /// Returns a new list containing only the transactions that fall within the selected time frame.
  List<MasareefTransaction> _getFilteredTransactions() {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    // Define a map of period names to their respective filtering logic.
    final periodFilters = {
      l10n.today: (MasareefTransaction tx) =>
          tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.date.day == now.day,
      l10n.thisWeek: (MasareefTransaction tx) =>
          tx.date.isAfter(now.subtract(const Duration(days: 7))),
      l10n.thisMonth: (MasareefTransaction tx) =>
          tx.date.year == now.year && tx.date.month == now.month,
    };

    // Get the filter function corresponding to the currently selected period.
    final filter = periodFilters[_selectedPeriod];
    // Apply the filter if it exists, otherwise return all transactions.
    return filter != null
        ? widget.transactions.where(filter).toList()
        : widget.transactions;
  }

  /// Calculates the total spending for each category from a list of transactions.
  ///
  /// Only considers 'expense' type transactions.
  /// Returns a map where keys are category names and values are the total amounts spent.
  Map<String, double> _getSpendingByCategory(
      List<MasareefTransaction> transactions) {
    return transactions
        .where((tx) => tx.type == 'expense')
        .fold<Map<String, double>>({}, (map, tx) {
      map.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Filter transactions based on the selected period.
    final filteredTransactions = _getFilteredTransactions();
    // Calculate spending data by category for the filtered transactions.
    final spendingData = _getSpendingByCategory(filteredTransactions);
    // Calculate the total income from filtered transactions.
    final totalIncome = filteredTransactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
    // Calculate the total expenses from the spending data.
    final totalExpenses =
        spendingData.values.fold(0.0, (sum, item) => sum + item);

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
                  /// Widget for selecting the time period for statistics.
                  PeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    onSelectionChanged: (newPeriod) {
                      setState(() {
                        _selectedPeriod = newPeriod;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  /// Displays summary cards for total income and total expenses.
                  _SummaryCards(
                      totalIncome: totalIncome, totalExpenses: totalExpenses),
                  const SizedBox(height: 24),
                  /// Displays the spending breakdown pie chart and title, only if there is spending data.
                  if (spendingData.isNotEmpty)
                    _SpendingBreakdown(
                        spendingData: spendingData,
                        totalExpenses: totalExpenses),
                ],
              ),
            ),
          ),
          /// Displays a list of categories with their spending amounts, only if there is spending data.
          if (spendingData.isNotEmpty)
            CategoryList(
                spendingData: spendingData, totalExpenses: totalExpenses),
        ],
      ),
    );
  }
}

/// A StatelessWidget that displays summary cards for total income and expenses.
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalIncome,
    required this.totalExpenses,
  });

  /// The total income to display.
  final double totalIncome;

  /// The total expenses to display.
  final double totalExpenses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
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
    );
  }
}

/// A StatelessWidget that displays the spending breakdown title and a pie chart.
class _SpendingBreakdown extends StatelessWidget {
  const _SpendingBreakdown({
    required this.spendingData,
    required this.totalExpenses,
  });

  /// A map containing spending amounts categorized by category.
  final Map<String, double> spendingData;

  /// The total expenses, used for percentage calculations in the pie chart.
  final double totalExpenses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.spendingBreakdown,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        /// The pie chart widget displaying the spending distribution.
        PieChartCard(spendingData: spendingData, totalExpenses: totalExpenses),
        const SizedBox(height: 24),
      ],
    );
  }
}
