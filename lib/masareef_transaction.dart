import 'package:flutter/material.dart';

class MasareefTransaction {
  int? id;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'income' or 'expense'
  final Color color;
  final String? notes;

  MasareefTransaction({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.color,
    this.notes,
  });
}
