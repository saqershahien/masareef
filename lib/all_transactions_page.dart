import 'package:flutter/material.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/category_translations.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/widgets/transaction_dialog.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  List<MasareefTransaction> _allTransactions = [];
  List<MasareefTransaction> _filteredTransactions = [];
  final _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });
    final transactions = await DatabaseHelper().getTransactions();
    setState(() {
      _allTransactions = transactions;
      _filteredTransactions = transactions;
      _isLoading = false;
    });
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        final categoryMatch =
            getCategoryDisplayName(tx.category, context).toLowerCase().contains(query);
        final notesMatch = tx.notes?.toLowerCase().contains(query) ?? false;
        return categoryMatch || notesMatch;
      }).toList();
    });
  }

  void _deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _refreshTransactions();
  }

  void _showDeleteConfirmationDialog(int id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext bcontext) {
        return AlertDialog(
          title: Text(l10n.delete),
          content: Text(l10n.areYouSureYouWantToDeleteThisTransaction),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(bcontext).pop();
              },
            ),
            TextButton(
              child: Text(
                l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                _deleteTransaction(id);
                Navigator.of(bcontext).pop();
              },
            ),
          ],
        );
      },
    );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allTransactions.isEmpty
                    ? Center(child: Text(l10n.noTransactionsYet))
                    : _filteredTransactions.isEmpty
                        ? Center(child: Text(l10n.noResultsFound))
                        : _buildGroupedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList() {
    final groupedTransactions = _groupTransactionsByDate(_filteredTransactions);
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      slivers: sortedDates.expand((date) {
        final formattedDate = _formatDate(context, date);
        final transactionsForDate = groupedTransactions[date]!;
        double dailyTotal = transactionsForDate.fold(0.0, (sum, item) {
          return sum + (item.type == 'income' ? item.amount : -item.amount);
        });
        final currencyFormat = NumberFormat.currency(
            locale: Localizations.localeOf(context).toString(), symbol: '');

        return [
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              color: const Color(0xFFE6E0FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                      currencyFormat.format(dailyTotal),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dailyTotal >= 0 ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildTransactionTile(transactionsForDate[index]);
              },
              childCount: transactionsForDate.length,
            ),
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildTransactionTile(MasareefTransaction tx) {
    final categoryInfo = categoryIcons[tx.category] ?? defaultCategoryInfo;
    final isIncome = tx.type == 'income';
    final currencyFormat = NumberFormat.currency(
        locale: Localizations.localeOf(context).toString(), symbol: '');
    final amountText =
        '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}';
    final amountColor = isIncome ? Colors.green : Colors.red;

    return ListTile(
      onTap: () => showTransactionDialog(context,
          transaction: tx,
          onTransactionAdded: _refreshTransactions,
          onTransactionDeleted: _deleteTransaction),
      onLongPress: () => _showDeleteConfirmationDialog(tx.id!),
      leading: CircleAvatar(
        backgroundColor: categoryInfo.color.withOpacity(0.1),
        child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 20),
      ),
      title: Text(getCategoryDisplayName(tx.category, context),
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle:
          tx.notes != null && tx.notes!.isNotEmpty ? Text(tx.notes!) : null,
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
