import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grade_project/l10n/app_localizations.dart';

class BalanceCard extends StatelessWidget {
  final Map<String, double> summary;

  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
        locale: Localizations.localeOf(context).toString(), symbol: '');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.totalBalance,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(currencyFormat.format(summary['balance'] ?? 0),
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IncomeExpenseRow(
                    icon: Icons.arrow_upward,
                    label: l10n.income,
                    amount: currencyFormat.format(summary['income'] ?? 0),
                    color: Colors.green),
                _IncomeExpenseRow(
                    icon: Icons.arrow_downward,
                    label: l10n.expenses,
                    amount: currencyFormat.format(summary['expenses'] ?? 0),
                    color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeExpenseRow extends StatelessWidget {
  const _IncomeExpenseRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(amount,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
