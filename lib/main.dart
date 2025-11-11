import 'package:flutter/material.dart';
import 'package:grade_project/all_transactions_page.dart';
import 'package:grade_project/categories.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/export_page.dart';
import 'package:grade_project/settings_page.dart';
import 'package:grade_project/stats_page.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/theme.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      title: 'Masareef',
      theme: appTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MasareefTransaction> _transactions = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return 'Today';
    } else if (dateToCompare == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });
    final data = await DatabaseHelper().getTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatsPage(
            transactions: _transactions,
          ),
        ),
      ).then((_) => _refreshTransactions());
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ExportPage(),
        ),
      ).then((_) => _refreshTransactions());
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      ).then((_) => _refreshTransactions());
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Map<String, double> _getFinancialSummary(
      List<MasareefTransaction> transactions) {
    double income = 0.0;
    double expenses = 0.0;
    for (var tx in transactions) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else {
        expenses += tx.amount;
      }
    }
    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  Future<void> _deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _refreshTransactions();
  }

  void _showTransactionDialog({MasareefTransaction? transaction}) {
    final isEditing = transaction != null;
    final amountController = TextEditingController(
        text: isEditing ? transaction.amount.toString() : '');
    final notesController =
        TextEditingController(text: isEditing ? transaction.notes : '');
    String transactionType = isEditing ? transaction.type : 'expense';
    List<String> currentCategories =
        transactionType == 'income' ? incomeCategories : spendingCategories;
    String selectedCategory =
        (isEditing && currentCategories.contains(transaction.category))
            ? transaction.category
            : currentCategories.first;
    DateTime selectedDate = isEditing ? transaction.date : DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? amountError;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text(
                isEditing ? 'Edit Transaction' : 'Add New Transaction',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                            value: 'expense',
                            label: Text('Expense'),
                            icon: Icon(Icons.arrow_downward)),
                        ButtonSegment<String>(
                            value: 'income',
                            label: Text('Income'),
                            icon: Icon(Icons.arrow_upward)),
                      ],
                      selected: {transactionType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          transactionType = newSelection.first;
                          currentCategories = transactionType == 'income'
                              ? incomeCategories
                              : spendingCategories;
                          selectedCategory = currentCategories.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: TextInputType.number,
                    ),
                    if (amountError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amountError!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      menuMaxHeight: 300,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined)),
                      items: currentCategories.map((category) {
                        final categoryInfo = categoryIcons[category] ??
                            defaultCategoryInfo;
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(categoryInfo.icon,
                                  color: categoryInfo.color),
                              const SizedBox(width: 10),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.edit_note)),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2015, 8),
                            lastDate: DateTime.now());
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .fillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: Theme.of(context).hintColor),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat.yMMMd().format(selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: Theme.of(context).hintColor),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Save'),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount <= 0) {
                      setState(() {
                        amountError = 'Amount must be greater than zero.';
                      });
                      return;
                    }
                    final categoryInfo = categoryIcons[selectedCategory] ??
                        defaultCategoryInfo;
                    final newTransaction = MasareefTransaction(
                      id: isEditing ? transaction.id : null,
                      amount: amount,
                      date: selectedDate,
                      category: selectedCategory,
                      type: transactionType,
                      notes: notesController.text,
                      color: isEditing
                          ? transaction.color
                          : categoryInfo.color,
                    );
                    if (isEditing) {
                      _updateTransaction(newTransaction);
                    } else {
                      _addTransaction(newTransaction);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTransaction(MasareefTransaction transaction) async {
    if (transaction.id != null) {
      await DatabaseHelper().updateTransaction(transaction, transaction.id!);
      _refreshTransactions();
    }
  }

  Future<void> _addTransaction(MasareefTransaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    _refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello Adam',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(204))),
            Text('Welcome Back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildBalanceCard(_getFinancialSummary(_transactions)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AllTransactionsPage()),
                          ).then((value) => _refreshTransactions());
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _transactions.isEmpty
                        ? _buildEmptyState()
                        : _buildTransactionList(_transactions),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_export),
            label: 'Export',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, double> summary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Balance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(NumberFormat.currency(symbol: 'CFA').format(summary['balance'] ?? 0),
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIncomeExpenseRow(Icons.arrow_upward, 'Income',
                    summary['income'] ?? 0, Colors.green),
                _buildIncomeExpenseRow(Icons.arrow_downward, 'Expenses',
                    summary['expenses'] ?? 0, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow(
      IconData icon, String label, double amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(NumberFormat.currency(symbol: 'CFA').format(amount),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<MasareefTransaction> transactions) {
    Map<String, List<MasareefTransaction>> groupedTransactions = {};
    for (var tx in transactions) {
      String formattedDate = _formatDate(tx.date);
      if (groupedTransactions[formattedDate] == null) {
        groupedTransactions[formattedDate] = [];
      }
      groupedTransactions[formattedDate]!.add(tx);
    }

    return ListView.builder(
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String date = groupedTransactions.keys.elementAt(index);
        List<MasareefTransaction> dailyTransactions =
            groupedTransactions[date]!;
        
        // Calculate daily total
        double dailyTotal = dailyTransactions.fold(0.0, (sum, item) {
          return sum + (item.type == 'income' ? item.amount : -item.amount);
        });

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(date, style: Theme.of(context).textTheme.titleSmall),
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
                ...dailyTransactions.map((tx) => _buildTransactionTile(tx)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(MasareefTransaction tx) {
    final categoryInfo = categoryIcons[tx.category] ?? defaultCategoryInfo;
    final isIncome = tx.type == 'income';
    final amountText = isIncome ? '+ ${NumberFormat.currency(symbol: 'CFA').format(tx.amount)}' : '- ${NumberFormat.currency(symbol: 'CFA').format(tx.amount)}';
    final amountColor = isIncome ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryInfo.color.withAlpha(51),
          child: Icon(
            categoryInfo.icon,
            color: categoryInfo.color,
          ),
        ),
        title: Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: tx.notes != null ? Text(tx.notes!) : null,
        trailing: Text(amountText, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        onTap: () => _showTransactionDialog(transaction: tx),
        onLongPress: () => _showDeleteConfirmation(tx.id!),
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text('Are you sure you want to delete this transaction?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteTransaction(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text('No transactions yet.', style: Theme.of(context).textTheme.headlineSmall),
          Text('Add a new transaction to get started.',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
