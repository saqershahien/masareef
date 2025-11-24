import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/category_translations.dart';

class CategoryList extends StatelessWidget {
  final Map<String, double> spendingData;
  final double totalExpenses;

  const CategoryList({
    super.key,
    required this.spendingData,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (spendingData.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pie_chart_outline,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(l10n.noSpendingDataForThisPeriod,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(l10n.trySelectingADifferentTimeRange,
                  style: Theme.of(context).textTheme.bodyMedium)
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
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16, top: 0, bottom: 8),
              child: Text(
                l10n.topCategories,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            );
          }
          final entry = sortedCategories[index - 1];
          return _buildCategoryListItem(context, entry, totalExpenses);
        },
        childCount: sortedCategories.length + 1,
      ),
    );
  }

  Widget _buildCategoryListItem(
      BuildContext context, MapEntry<String, double> entry, double totalExpenses) {
    final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) : 0.0;
    final categoryInfo = categoryIcons[entry.key] ?? defaultCategoryInfo;
    final currencyFormat = NumberFormat.currency(
        locale: Localizations.localeOf(context).toString(), symbol: '');

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
                    Text(getCategoryDisplayName(entry.key, context),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(categoryInfo.color),
                        minHeight: 6,
                      ),
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
                      currencyFormat.format(entry.value),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(percentage * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
