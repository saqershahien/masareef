import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/category_translations.dart';

class TransactionList extends StatelessWidget {
  final List<MasareefTransaction> transactions;
  final Function(MasareefTransaction) onTransactionTap;
  final Function(int) onTransactionLongPress;
  final Function(BuildContext, DateTime) formatDate;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
    required this.onTransactionLongPress,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, List<MasareefTransaction>> groupedTransactions = {};
    for (var tx in transactions) {
      DateTime dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        DateTime date = sortedDates[index];
        List<MasareefTransaction> dailyTransactions =
            groupedTransactions[date]!;

        double dailyTotal = dailyTransactions.fold(0.0, (sum, item) {
          return sum + (item.type == 'income' ? item.amount : -item.amount);
        });

        final currencyFormat = NumberFormat.currency(
            locale: Localizations.localeOf(context).toString(), symbol: '');

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: const Color(0xFFE6E0FF),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 16.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDate(context, date),
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        currencyFormat.format(dailyTotal),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dailyTotal >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                    ],
                  ),
                ),
                ...dailyTransactions.map((tx) =>
                    _buildTransactionTile(context, tx, currencyFormat)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(BuildContext context, MasareefTransaction tx,
      NumberFormat currencyFormat) {
    final categoryInfo = categoryIcons[tx.category] ?? defaultCategoryInfo;
    final isIncome = tx.type == 'income';
    final amountText = isIncome
        ? '+ ${currencyFormat.format(tx.amount)}'
        : '- ${currencyFormat.format(tx.amount)}';
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
        title: Text(getCategoryDisplayName(tx.category, context),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: tx.notes != null ? Text(tx.notes!) : null,
        trailing: Text(amountText,
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        onTap: () => onTransactionTap(tx),
        onLongPress: () => onTransactionLongPress(tx.id!),
      ),
    );
  }
}
