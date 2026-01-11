import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:masareef/categories.dart';
import 'package:masareef/category_icons.dart';
import 'package:masareef/database_helper.dart';
import 'package:masareef/masareef_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String predictionUrl = "http://173.212.200.207/api/Generator/PredictPrices";
const String _cacheKey = 'prediction_data_cache';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  List<MasareefTransaction> _transactions = [];
  Map<String, double> _fetchedBudgets = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUsingCachedData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await DatabaseHelper().getTransactions();
      
      try {
        final response = await http.get(Uri.parse(predictionUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final String body = response.body;
          _parseAndSetBudgets(body);
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, body);
          
          setState(() {
            _transactions = data;
            _isLoading = false;
            _isUsingCachedData = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Network error, attempting to load from cache: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);
      
      if (cachedData != null) {
        _parseAndSetBudgets(cachedData);
        setState(() {
          _transactions = data;
          _isLoading = false;
          _isUsingCachedData = true;
        });
      } else {
        setState(() {
          _errorMessage = null; // Will show "No data" localized message
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _parseAndSetBudgets(String jsonStr) {
    try {
      final Map<String, dynamic> jsonBody = jsonDecode(jsonStr);
      final Map<String, double> budgets = {};
      jsonBody.forEach((key, value) {
        double parsedValue = 0.0;
        if (value is num) {
          parsedValue = value.toDouble();
        } else if (value is String) {
          final cleaned = value.replaceAll('%', '').trim();
          parsedValue = double.tryParse(cleaned) ?? 0.0;
        }
        budgets[key] = parsedValue;
      });
      _fetchedBudgets = budgets;
    } catch (e) {
      debugPrint('Error parsing budget data: $e');
    }
  }

  Map<String, double> _calculateCategorySpending() {
    final Map<String, double> categoryTotals = {};
    for (var cat in spendingCategories) {
      if (cat != 'Other') {
        categoryTotals[cat] = 0.0;
      }
    }

    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == 'expense' && tx.date.month == now.month && tx.date.year == now.year) {
        if (categoryTotals.containsKey(tx.category)) {
          categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0.0) + tx.amount;
        }
      }
    }
    return categoryTotals;
  }

  String _getLocalizedCategory(String category, bool isArabic) {
    if (!isArabic) return category;
    int index = spendingCategories.indexOf(category);
    if (index != -1 && index < spendingCategoriesArabic.length) {
      return spendingCategoriesArabic[index];
    }
    return category;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String currentMonth = DateFormat('MMMM', isArabic ? 'ar' : 'en').format(DateTime.now());
    final String lastUpdate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    
    final categorySpending = _calculateCategorySpending();
    final sortedEntries = categorySpending.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'توقعات الإنفاق ($currentMonth)' : 'Spending Prediction ($currentMonth)'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null || (_fetchedBudgets.isEmpty && !_isLoading))
              ? _buildErrorView(isArabic)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: sortedEntries.isEmpty ? 2 : sortedEntries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildHeader(lastUpdate, isArabic);

                      if (sortedEntries.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              isArabic ? 'لا توجد معاملات لهذا الشهر' : 'No transactions for this month',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      final entry = sortedEntries[index - 1];
                      final catName = entry.key;
                      
                      double? percentage = _fetchedBudgets[catName];
                      if (percentage == null && catName == 'Bills') {
                        percentage = _fetchedBudgets['Bill'];
                      }
                      percentage ??= 0.0;
                      
                      final catInfo = categoryIcons[catName] ?? defaultCategoryInfo;
                      final localizedTitle = _getLocalizedCategory(catName, isArabic);
                      
                      return _buildCategoryCard(localizedTitle, percentage, catInfo);
                    },
                  ),
                ),
    );
  }

  Widget _buildHeader(String lastUpdate, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
      child: Column(
        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (_isUsingCachedData)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withAlpha(75)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isArabic ? 'وضع غير متصل - استخدام البيانات المخزنة' : 'Offline - Using cached data',
                      style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${isArabic ? 'آخر تحديث' : 'Updated'}: $lastUpdate',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, double percentage, CategoryInfo info) {
    final progress = (percentage / 100.0).clamp(0.0, 1.0);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: info.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(info.icon, color: info.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: info.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutQuart,
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: info.color.withAlpha(25),
                    valueColor: AlwaysStoppedAnimation<Color>(info.color),
                    minHeight: 10,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? (isArabic ? 'لا توجد بيانات متاحة. يرجى التحقق من اتصالك بالإنترنت.' : 'No data available. Please check your internet connection.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isArabic ? 'حاول مرة أخرى' : 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
