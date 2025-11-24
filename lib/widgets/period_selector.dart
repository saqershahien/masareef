import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onSelectionChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment<String>(value: l10n.today, label: Text(l10n.today)),
          ButtonSegment<String>(
              value: l10n.thisWeek, label: Text(l10n.thisWeek)),
          ButtonSegment<String>(
              value: l10n.thisMonth, label: Text(l10n.thisMonth)),
        ],
        selected: {selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          onSelectionChanged(newSelection.first);
        },
      ),
    );
  }
}
