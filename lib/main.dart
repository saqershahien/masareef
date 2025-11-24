import 'package:flutter/material.dart';
import 'package:grade_project/all_transactions_page.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/settings_page.dart';
import 'package:grade_project/stats_page.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/theme.dart';
import 'package:grade_project/widgets/balance_card.dart';
import 'package:grade_project/widgets/empty_state.dart';
import 'package:grade_project/widgets/transaction_dialog.dart';
import 'package:grade_project/widgets/transaction_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _locale = Locale(languageCode, '');
    });
  }

  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      title: 'Masareef',
      theme: appTheme,
      locale: _locale,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.welcomeBack,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              ).then((_) => _refreshTransactions());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showTransactionDialog(context, onTransactionAdded: _refreshTransactions),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BalanceCard(summary: _getFinancialSummary(_transactions)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.recentTransactions,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AllTransactionsPage()),
                          ).then((value) => _refreshTransactions());
                        },
                        child: Text(l10n.viewAll),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _transactions.isEmpty
                        ? const EmptyState()
                        : TransactionList(
                            transactions: _transactions,
                            onTransactionTap: (tx) => showTransactionDialog(
                                context,
                                transaction: tx,
                                onTransactionAdded: _refreshTransactions,
                                onTransactionDeleted: _deleteTransaction),
                            formatDate: _formatDate,
                            onTransactionLongPress: (id) =>
                                _showDeleteConfirmationDialog(id),
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.stats,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
