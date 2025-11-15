import 'package:flutter/material.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/main.dart';
import 'package:grade_project/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmClearData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.confirmClearData),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(l10n.areYouSureYouWantToDeleteAllTransactionData),
                Text(l10n.thisActionCannotBeUndone),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.clearData),
              onPressed: () async {
                await DatabaseHelper().deleteAllTransactions();
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.allDataHasBeenCleared)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  MyApp.of(context)?.changeLanguage(const Locale('en', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('العربية'),
                onTap: () {
                  MyApp.of(context)?.changeLanguage(const Locale('ar', ''));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blueAccent),
            title: Text(l10n.language),
            subtitle: Text(l10n.changeTheAppLanguage),
            onTap: () => _showLanguagePicker(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: Text(l10n.clearAllData),
            subtitle: Text(l10n.permanentlyDeleteAllTransactions),
            onTap: () => _confirmClearData(context),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
