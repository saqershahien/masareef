import 'package:flutter/material.dart';

class CategoryInfo {
  final IconData icon;
  final Color color;

  const CategoryInfo({required this.icon, required this.color});
}

const Map<String, CategoryInfo> categoryIcons = {
  'Groceries': CategoryInfo(icon: Icons.shopping_cart, color: Colors.green),
  'Food': CategoryInfo(icon: Icons.fastfood, color: Colors.orange),
  'Transport': CategoryInfo(icon: Icons.directions_car, color: Colors.blue),
  'Entertainment': CategoryInfo(icon: Icons.movie, color: Colors.purple),
  'Shopping': CategoryInfo(icon: Icons.shopping_bag, color: Colors.pink),
  'Bills': CategoryInfo(icon: Icons.receipt, color: Colors.red),
  'Health': CategoryInfo(icon: Icons.favorite, color: Colors.indigo),
  'Travel': CategoryInfo(icon: Icons.airplanemode_active, color: Colors.teal),
  'Family': CategoryInfo(icon: Icons.group, color: Colors.cyan),
  'Education': CategoryInfo(icon: Icons.school, color: Colors.lime),
  'Other': CategoryInfo(icon: Icons.category, color: Colors.grey),
  'Salary': CategoryInfo(icon: Icons.attach_money, color: Colors.lightGreen),
  'Gift': CategoryInfo(icon: Icons.card_giftcard, color: Colors.amber),
  'Bonus': CategoryInfo(icon: Icons.star, color: Colors.yellow),
  'Investment': CategoryInfo(icon: Icons.trending_up, color: Colors.lightBlue),
  'Rental': CategoryInfo(icon: Icons.home, color: Colors.brown),
};

const defaultCategoryInfo = CategoryInfo(icon: Icons.category, color: Colors.grey);
