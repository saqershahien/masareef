import 'package:flutter/material.dart';
import 'package:grade_project/categories.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/category_translations.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:intl/intl.dart';

void showTransactionDialog(
    BuildContext context, {
    MasareefTransaction? transaction,
    required Function() onTransactionAdded,
    Function(int)? onTransactionDeleted,
  }) {
    final isEditing = transaction != null;
    final amountController = TextEditingController(
        text: isEditing ? transaction.amount.toString() : '');
    final notesController =
        TextEditingController(text: isEditing ? transaction.notes : '');
    String transactionType = isEditing ? transaction.type : 'expense';
    List<String> currentCategories =
        transactionType == 'income' ? incomeCategories : spendingCategories;
    String selectedCategory =
        (isEditing && currentCategories.contains(transaction.category))
            ? transaction.category
            : currentCategories.first;
    DateTime selectedDate = isEditing ? transaction.date : DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? amountError;
        return StatefulBuilder(
          builder: (context, setState) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Center(
                  child: Text(
                isEditing ? l10n.editTransaction : l10n.addNewTransaction,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment<String>(
                            value: 'expense',
                            label: Text(l10n.expense),
                            icon: const Icon(Icons.arrow_downward)),
                        ButtonSegment<String>(
                            value: 'income',
                            label: Text(l10n.income),
                            icon: const Icon(Icons.arrow_upward)),
                      ],
                      selected: {transactionType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          transactionType = newSelection.first;
                          currentCategories = transactionType == 'income'
                              ? incomeCategories
                              : spendingCategories;
                          selectedCategory = currentCategories.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                          labelText: l10n.amount,
                          prefixIcon: const Icon(Icons.attach_money)),
                      keyboardType: TextInputType.number,
                    ),
                    if (amountError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amountError!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      menuMaxHeight: 300,
                      isExpanded: true,
                      decoration: InputDecoration(
                          labelText: l10n.category,
                          prefixIcon: const Icon(Icons.category_outlined)),
                      items: currentCategories.map((category) {
                        final categoryInfo = categoryIcons[category] ??
                            defaultCategoryInfo;
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(categoryInfo.icon,
                                  color: categoryInfo.color),
                              const SizedBox(width: 10),
                              Text(getCategoryDisplayName(category, context)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                          labelText: l10n.notes,
                          prefixIcon: const Icon(Icons.edit_note)),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2015, 8),
                            lastDate: DateTime.now());
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .fillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: Theme.of(context).hintColor),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat.yMMMd().format(selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: Theme.of(context).hintColor),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                if (isEditing)
                  TextButton(
                    child: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      if (onTransactionDeleted != null) {
                        onTransactionDeleted(transaction.id!);
                      }
                    },
                  ),
                const Spacer(),
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(l10n.save),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount <= 0) {
                      setState(() {
                        amountError = l10n.amountMustBeGreaterThanZero;
                      });
                      return;
                    }
                    final newTransaction = MasareefTransaction(
                      id: isEditing ? transaction.id : null,
                      amount: amount,
                      date: selectedDate,
                      category: selectedCategory,
                      type: transactionType,
                      notes: notesController.text,
                    );
                    if (isEditing) {
                      await DatabaseHelper().updateTransaction(newTransaction, newTransaction.id!);
                    } else {
                      await DatabaseHelper().insertTransaction(newTransaction);
                    }
                    onTransactionAdded();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
