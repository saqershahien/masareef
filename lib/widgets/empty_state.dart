import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(l10n.noTransactionsYet,
              style: Theme.of(context).textTheme.headlineSmall),
          Text(l10n.addNewTransactionToGetStarted,
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
