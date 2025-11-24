import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/pie_chart.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/category_translations.dart';

class PieChartCard extends StatelessWidget {
  final Map<String, double> spendingData;
  final double totalExpenses;

  const PieChartCard({
    super.key,
    required this.spendingData,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
        locale: Localizations.localeOf(context).toString(),
        symbol: '',
        decimalDigits: 0);
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
                        Text(l10n.total,
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          currencyFormat.format(totalExpenses),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                  final percentage =
                      totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;
                  final categoryColor =
                      (categoryIcons[entry.key] ?? defaultCategoryInfo).color;
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
                            '${getCategoryDisplayName(entry.key, context)} (${percentage.toStringAsFixed(1)}%)',
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
}
