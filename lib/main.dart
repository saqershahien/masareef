import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grade_project/all_transactions_page.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/finance_utils.dart';
import 'package:grade_project/settings_page.dart';
import 'package:grade_project/stats_page.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/theme.dart';
import 'package:grade_project/transaction_detail_page.dart'; // Import the new page
import 'package:grade_project/widgets/balance_card.dart';
import 'package:grade_project/widgets/empty_state.dart';
import 'package:grade_project/widgets/transaction_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

/// The main entry point of the application.
void main() {
  // Ensures that the Flutter binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Runs the root widget of the application.
  runApp(const MyApp());
}

/// The root widget of the application. It is a StatefulWidget to manage theme and locale changes.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  /// A static method to allow descendant widgets to access MyAppState.
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

/// The state for the MyApp widget, handling locale changes.
class MyAppState extends State<MyApp> {
  // The current locale of the application. Defaults to English.
  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    // Loads the saved locale when the app starts.
    _loadLocale();
  }

  /// Loads the locale from shared preferences.
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _locale = Locale(languageCode, '');
    });
  }

  /// Changes the application's language and saves the preference.
  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root of the app's widget tree.
    return MaterialApp(
      // Hides the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      title: 'Masareef',
      // Sets the global theme for the application.
      theme: appTheme,
      // Sets the current locale for the application.
      locale: _locale,
      // Provides delegates for internationalization.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Defines the supported locales for the application.
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ar', ''), // Arabic, no country code
      ],
      // The default route of the application.
      home: const HomePage(),
    );
  }
}

/// The main screen of the application.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state for the HomePage widget.
class _HomePageState extends State<HomePage> {
  // A list to hold all the transactions from the database.
  List<MasareefTransaction> _transactions = [];
  // A map to hold the financial summary.
  Map<String, double> _summary = {'income': 0, 'expenses': 0, 'balance': 0};
  // A boolean to indicate if the data is currently being loaded.
  bool _isLoading = true;
  // The index of the currently selected item in the BottomNavigationBar.
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetches the transactions from the database when the widget is first created.
    _refreshTransactions();
  }

  /// Formats a DateTime object into a user-friendly string (e.g., "Today", "Yesterday", or the actual date).
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
  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });
    final data = await DatabaseHelper().getTransactions();
    final summary = getFinancialSummary(data);
    setState(() {
      _transactions = data;
      _summary = summary;
      _isLoading = false;
    });
  }

  /// Handles the tap events on the BottomNavigationBar.
  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigates to the StatsPage when the second item is tapped.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatsPage(
            transactions: _transactions,
          ),
        ),
      ).then((_) => _refreshTransactions());
    } else {
      // Updates the selected index for the home page.
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Opens the transaction detail page for adding a new transaction.
  void _navigateToAddTransaction() async {
    final result = await Navigator.push<bool?>(context, MaterialPageRoute(builder: (context) => const TransactionDetailPage()));
    if (result == true) {
      _refreshTransactions();
    }
  }

  /// Opens the transaction detail page for editing an existing transaction.
  void _navigateToEditTransaction(MasareefTransaction transaction) async {
    final result = await Navigator.push<bool?>(context, MaterialPageRoute(builder: (context) => TransactionDetailPage(transaction: transaction)));
    if (result == true) {
      _refreshTransactions();
    }
  }

  /// Shows a confirmation dialog before deleting a transaction.
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
                if (mounted) {
                  Navigator.of(bcontext).pop();
                  _refreshTransactions();
                }
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
      // The top app bar of the screen.
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
          // An icon button to navigate to the SettingsPage.
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
      // The main content of the screen.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Shows a loader while data is being fetched.
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // A card to display the financial summary (income, expenses, balance).
                  BalanceCard(summary: _summary),
                  const SizedBox(height: 20),
                  // The header for the recent transactions list.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.recentTransactions,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      // A button to navigate to the page with all transactions.
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
      // The bottom navigation bar.
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              color: _selectedIndex == 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              onPressed: () => _onItemTapped(0),
              tooltip: l10n.home,
            ),
            FloatingActionButton.small(
              backgroundColor: Colors.green,
              onPressed: _navigateToAddTransaction,
              tooltip: l10n.addNewTransaction,
              elevation: 0,
              highlightElevation: 0,
              child: const Icon(Icons.add,color: Colors.black87,),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              onPressed: () => _onItemTapped(1),
              tooltip: l10n.stats,
            ),
          ],
        ),
      ),
    );
  }
}
