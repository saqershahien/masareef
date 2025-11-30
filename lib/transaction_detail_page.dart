import 'package:flutter/material.dart';
import 'package:grade_project/categories.dart';
import 'package:grade_project/category_icons.dart';
import 'package:grade_project/category_translations.dart';
import 'package:grade_project/database_helper.dart';
import 'package:grade_project/l10n/app_localizations.dart';
import 'package:grade_project/masareef_transaction.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatefulWidget {
  final MasareefTransaction? transaction;

  const TransactionDetailPage({super.key, this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _transactionType = 'expense';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  String? _amountError;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _amountController.text = widget.transaction!.amount.toString();
      _notesController.text = widget.transaction!.notes ?? '';
      _transactionType = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
    }

    _updateCategoriesAndSelection(initialLoad: true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCategoriesAndSelection({bool initialLoad = false}) {
    List<String> currentCategories =
        _transactionType == 'income' ? incomeCategories : spendingCategories;

    if (initialLoad && _isEditing && currentCategories.contains(widget.transaction!.category)) {
      _selectedCategory = widget.transaction!.category;
    } else {
      _selectedCategory = currentCategories.first;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      setState(() {
        _amountError = l10n.amountMustBeGreaterThanZero;
      });
      return;
    }

    final newTransaction = MasareefTransaction(
      id: _isEditing ? widget.transaction!.id : null,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      type: _transactionType,
      notes: _notesController.text,
    );

    if (_isEditing) {
      await DatabaseHelper().updateTransaction(newTransaction, newTransaction.id!);
    } else {
      await DatabaseHelper().insertTransaction(newTransaction);
    }
    if (mounted) {
      Navigator.of(context).pop(true); // Indicate success
    }
  }

  void _deleteTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext bcontext) {
        return AlertDialog(
          title: Text(l10n.delete),
          content: Text(l10n.areYouSureYouWantToDeleteThisTransaction),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(bcontext).pop();
              },
            ),
            TextButton(
              child: Text(
                l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () async {
                if (_isEditing && widget.transaction!.id != null) {
                  await DatabaseHelper().deleteTransaction(widget.transaction!.id!);
                  if (mounted) {
                    Navigator.of(bcontext).pop(); // Close confirmation dialog
                    Navigator.of(context).pop(true); // Indicate success and pop detail page
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    List<String> currentCategories =
        _transactionType == 'income' ? incomeCategories : spendingCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTransaction : l10n.addNewTransaction),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              selected: {_transactionType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _transactionType = newSelection.first;
                  _updateCategoriesAndSelection();
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixIcon: const Icon(Icons.attach_money),
                errorText: _amountError,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_amountError != null) {
                  setState(() {
                    _amountError = null; // Clear error on change
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              menuMaxHeight: 300,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.category,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: currentCategories.map((category) {
                final categoryInfo = categoryIcons[category] ?? defaultCategoryInfo;
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(categoryInfo.icon, color: categoryInfo.color),
                      const SizedBox(width: 10),
                      Text(getCategoryDisplayName(category, context)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
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
                          DateFormat.yMMMd().format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down,
                        color: Theme.of(context).hintColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (_isEditing)
                  TextButton(
                    onPressed: _deleteTransaction,
                    child: Text(l10n.delete,
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Indicate cancellation
                  },
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(l10n.save),
                  onPressed: _saveTransaction,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}