import 'package:flutter/material.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  late Future<List<MasareefTransaction>> _transactionsFuture;
  List<MasareefTransaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
    _transactionsFuture.then((transactions) {
      setState(() {
        _allTransactions = transactions;
      });
    });
  }

  Future<List<MasareefTransaction>> _fetchTransactions() async {
    return DatabaseHelper().getTransactions();
  }

  DateTime _truncateToDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = _truncateToDay(now);
    final yesterday = _truncateToDay(now.subtract(const Duration(days: 1)));

    if (_truncateToDay(date) == today) {
      return AppLocalizations.of(context)!.today;
    } else if (_truncateToDay(date) == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  Map<DateTime, List<MasareefTransaction>> _groupTransactionsByDate(
      List<MasareefTransaction> transactions) {
    final Map<DateTime, List<MasareefTransaction>> groupedTransactions = {};
    for (var tx in transactions) {
      final dateKey = _truncateToDay(tx.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(tx);
    }
    return groupedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allTransactions),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: FutureBuilder<List<MasareefTransaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (_allTransactions.isEmpty) {
            return Center(child: Text(l10n.noTransactionsYet));
          }

          final groupedTransactions =
              _groupTransactionsByDate(_allTransactions);
          final sortedDates = groupedTransactions.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return CustomScrollView(
            slivers: sortedDates.expand((date) {
              final formattedDate = _formatDate(context, date);
              final transactionsForDate = groupedTransactions[date]!;
              double dailyTotal = transactionsForDate.fold(0.0, (sum, item) {
                return sum + (item.type == 'income' ? item.amount : -item.amount);
              });

              return [
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate.toUpperCase(),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                          Text(
                            NumberFormat.currency(symbol: 'CFA').format(dailyTotal),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dailyTotal >= 0 ? Colors.green : Colors.red,
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildTransactionTile(
                          transactionsForDate[index]);
                    },
                    childCount: transactionsForDate.length,
                  ),
                ),
              ];
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(MasareefTransaction tx) {
    final categoryInfo = categoryIcons[tx.category] ?? defaultCategoryInfo;
    final isIncome = tx.type == 'income';
    final amountText = '${isIncome ? '+' : '-'}${NumberFormat.currency(symbol: 'CFA').format(tx.amount)}';
    final amountColor =
        isIncome ? Colors.green : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoryInfo.color.withOpacity(0.1),
        child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 20),
      ),
      title: Text(tx.category, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: tx.notes != null && tx.notes!.isNotEmpty ? Text(tx.notes!) : null,
      trailing: Text(
        amountText,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: amountColor,
        ),
      ),
    );
  }
}
