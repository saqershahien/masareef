import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onFabPressed;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(context, icon: Icons.home, index: 0, tooltip: l10n.home),
          _buildNavItem(context, icon: Icons.bar_chart, index: 1, tooltip: l10n.stats),
          FloatingActionButton.small(
            backgroundColor: Colors.grey[300],
            onPressed: onFabPressed,
            tooltip: l10n.addNewTransaction,
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(
              Icons.add,
              color: Colors.black87,
            ),
          ),
          _buildNavItem(context, icon: Icons.smart_toy_outlined, index: 2, tooltip: 'Assistant'),
          _buildNavItem(context, icon: Icons.settings, index: 3, tooltip: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required int index, required String tooltip}) {
    return IconButton(
      icon: Icon(icon),
      color: selectedIndex == index
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface,
      onPressed: () => onItemTapped(index),
      tooltip: tooltip,
    );
  }
}
