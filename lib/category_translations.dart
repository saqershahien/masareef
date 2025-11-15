import 'package:flutter/material.dart';
import 'package:grade_project/l10n/app_localizations.dart';

String getCategoryDisplayName(String category, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (category) {
    case 'Groceries':
      return l10n.categoryGroceries;
    case 'Restaurants':
      return l10n.categoryRestaurants;
    case 'Transportation':
      return l10n.categoryTransportation;
    case 'Utilities':
      return l10n.categoryUtilities;
    case 'Rent':
      return l10n.categoryRent;
    case 'Healthcare':
      return l10n.categoryHealthcare;
    case 'Entertainment':
      return l10n.categoryEntertainment;
    case 'Shopping':
      return l10n.categoryShopping;
    case 'Education':
      return l10n.categoryEducation;
    case 'Personal Care':
      return l10n.categoryPersonalCare;
    case 'Travel':
      return l10n.categoryTravel;
    case 'Gifts & Donations':
      return l10n.categoryGiftsDonations;
    case 'Kids':
      return l10n.categoryKids;
    case 'Pets':
      return l10n.categoryPets;
    case 'Home':
      return l10n.categoryHome;
    case 'Salary':
      return l10n.categorySalary;
    case 'Freelance':
      return l10n.categoryFreelance;
    case 'Investment':
      return l10n.categoryInvestment;
    case 'Rental Income':
      return l10n.categoryRentalIncome;
    case 'Other':
      return l10n.categoryOther;
    default:
      return category;
  }
}
