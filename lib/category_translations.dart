import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';

String getCategoryDisplayName(String category, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (category) {
    case 'Groceries':
      return l10n.categoryGroceries;
    case 'Food':
      return l10n.categoryFood;
    case 'Restaurants':
      return l10n.categoryRestaurants;
    case 'Transport':
      return l10n.categoryTransport;
    case 'Entertainment':
      return l10n.categoryEntertainment;
    case 'Shopping':
      return l10n.categoryShopping;
    case 'Bills':
      return l10n.categoryBills;
    case 'Health':
      return l10n.categoryHealth;
    case 'Travel':
      return l10n.categoryTravel;
    case 'Family':
      return l10n.categoryFamily;
    case 'Education':
      return l10n.categoryEducation;
    case 'Other':
      return l10n.categoryOther;
    case 'Salary':
      return l10n.categorySalary;
    case 'Gift':
      return l10n.categoryGift;
    case 'Bonus':
      return l10n.categoryBonus;
    case 'Investment':
      return l10n.categoryInvestment;
    case 'Rental':
      return l10n.categoryRental;
    case 'Coffee':
      return l10n.categoryCoffee;
    default:
      return category;
  }
}
