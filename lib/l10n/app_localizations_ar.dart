// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get helloAdam => 'أهلاً آدم';

  @override
  String get welcomeBack => 'أهلاً بعودتك!';

  @override
  String get totalBalance => 'الرصيد الكلي';

  @override
  String get income => 'الدخل';

  @override
  String get expenses => 'المصاريف';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get home => 'الرئيسية';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get export => 'تصدير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get noTransactionsYet => 'لا توجد معاملات حتى الآن.';

  @override
  String get addNewTransactionToGetStarted => 'أضف معاملة جديدة للبدء.';

  @override
  String get editTransaction => 'تعديل المعاملة';

  @override
  String get addNewTransaction => 'إضافة معاملة جديدة';

  @override
  String get expense => 'مصروف';

  @override
  String get amount => 'المبلغ';

  @override
  String get amountMustBeGreaterThanZero => 'يجب أن يكون المبلغ أكبر من صفر.';

  @override
  String get category => 'الفئة';

  @override
  String get notes => 'ملاحظات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get areYouSureYouWantToDeleteThisTransaction =>
      'هل أنت متأكد أنك تريد حذف هذه المعاملة؟';

  @override
  String get delete => 'حذف';

  @override
  String get allTransactions => 'كل المعاملات';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'الأمس';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get spendingBreakdown => 'تفاصيل الإنفاق';

  @override
  String get topCategories => 'أهم الفئات';

  @override
  String get noSpendingDataForThisPeriod => 'لا توجد بيانات إنفاق لهذه الفترة.';

  @override
  String get trySelectingADifferentTimeRange => 'حاول تحديد نطاق زمني مختلف.';
}
