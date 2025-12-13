import 'package:flutter/material.dart';
import 'package:masareef/all_transactions_page.dart';
import 'package:masareef/database_helper.dart';
import 'package:masareef/finance_utils.dart';
import 'package:masareef/settings_page.dart';
import 'package:masareef/stats_page.dart';
import 'package:masareef/masareef_transaction.dart';
import 'package:masareef/transaction_detail_page.dart';
import 'package:masareef/widgets/app_bottom_navigation_bar.dart';
import 'package:masareef/widgets/home_app_bar.dart';
import 'package:masareef/widgets/month_balance_card.dart';
import 'package:masareef/widgets/empty_state.dart';
import 'package:masareef/widgets/transaction_list.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';

/// The main screen of the application, displaying a summary of financial
/// transactions and providing navigation to other sections.
class HomePage extends StatefulWidget {
  /// Creates the home page widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state for the [HomePage] widget.
///
/// This class manages the state of the home page, including the list of
/// transactions, the monthly financial summary, and the loading state.
class _HomePageState extends State<HomePage> {
  // A list to hold all the transactions from the database.
  List<MasareefTransaction> _transactions = [];
  // A map to hold the monthly financial summary (income, expenses, and balance).
  Map<String, double> _monthlySummary = {
    'income': 0,
    'expenses': 0,
    'balance': 0,
  };
  // A boolean to indicate if the data is currently being loaded from the database.
  bool _isLoading = true;
  // The index of the currently selected item in the bottom navigation bar.
  final int _selectedIndex = 0; // Always 0 for HomePage

  @override
  void initState() {
    super.initState();
    // Fetches the transactions from the database when the widget is first created.
    _refreshTransactions();
  }

  /// Formats a [DateTime] object into a user-friendly string.
  ///
  /// This method returns "Today", "Yesterday", or the formatted date string
  /// depending on the provided date.
  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return AppLocalizations.of(context)!.today;
    } else if (dateToCompare == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  /// Fetches all transactions from the database and updates the state.
  ///
  /// This method sets the loading state to true, fetches the transactions from
  /// the [DatabaseHelper], calculates the monthly financial summary, and then
  /// updates the state with the new data.
  Future<void> _refreshTransactions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final data = await DatabaseHelper().getTransactions();
    final summary = getMonthlyFinancialSummary(data);
    if (mounted) {
      setState(() {
        _transactions = data;
        _monthlySummary = summary;
        _isLoading = false;
      });
    }
  }

  /// Handles tap events on the bottom navigation bar.
  ///
  /// This method navigates to the corresponding screen. The "Home" item (index 0)
  /// does nothing as it's the current screen. Other items push a new page
  /// on top of the home page.
  void _onItemTapped(int index) async {
    // Index 0 is the home page, which is already visible.
    // Index 2 is the FAB, handled by onFabPressed.
    if (index == 0 || index == 2) return;

    switch (index) {
      case 1: // Stats
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatsPage(transactions: _transactions),
          ),
        );
        break;
      case 3: // Settings
        final result = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        if (result == true) {
          _refreshTransactions();
        }
        break;
    }
  }

  /// Navigates to the transaction detail page to add a new transaction.
  ///
  /// This method pushes the [TransactionDetailPage] onto the navigation stack.
  /// If a new transaction is added, the list of transactions is refreshed.
  void _navigateToAddTransaction() async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(builder: (context) => const TransactionDetailPage()),
    );
    if (result == true) {
      _refreshTransactions();
    }
  }

  /// Navigates to the transaction detail page to edit an existing transaction.
  ///
  /// This method pushes the [TransactionDetailPage] onto the navigation stack
  /// with the selected transaction. If the transaction is updated, the list of
  /// transactions is refreshed.
  void _navigateToEditTransaction(MasareefTransaction transaction) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
    if (result == true) {
      _refreshTransactions();
    }
  }

  /// Shows a confirmation dialog before deleting a transaction.
  ///
  /// This method displays an [AlertDialog] to confirm the deletion of a
  /// transaction. If the user confirms, the transaction is deleted from the
  /// database and the list of transactions is refreshed.
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
              onPressed: () async {
                await DatabaseHelper().deleteTransaction(id);
                // The dialog is popped, so we don't need a mounted check for bcontext.
                Navigator.of(bcontext).pop();
                // _refreshTransactions will check for mounted state of the HomePage.
                _refreshTransactions();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: const HomeAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Shows a loader while data is being fetched.
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // A card to display the financial summary (income, expenses, balance).
                  MonthBalanceCard(summary: _monthlySummary),
                  const SizedBox(height: 20),
                  // The header for the recent transactions list.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentTransactions,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // A button to navigate to the page with all transactions.
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push<bool?>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllTransactionsPage(),
                            ),
                          );
                          if (result == true) {
                            _refreshTransactions();
                          }
                        },
                        child: Text(l10n.viewAll),
                      ),
                    ],
                  ),
                  // The list of recent transactions.
                  Expanded(
                    child: _transactions.isEmpty
                        ? const EmptyState() // Shows a message if there are no transactions.
                        : TransactionList(
                            transactions: _transactions,
                            onTransactionTap: _navigateToEditTransaction,
                            formatDate: _formatDate,
                            onTransactionLongPress: (id) =>
                                _showDeleteConfirmationDialog(id),
                          ),
                  ),
                ],
              ),
            ),
      // The bottom navigation bar for the application.
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onFabPressed: _navigateToAddTransaction,
      ),
    );
  }
}
