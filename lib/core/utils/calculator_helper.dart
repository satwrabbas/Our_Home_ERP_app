import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPricesHistoryData currentPrices,
    int months = 48,
  }) {
    // 1. حساب تكلفة المتر المربع الواحد بناءً على كميات الإكسل (6 بنود)
    double finalPricePerSqm = 
        (currentPrices.ironPrice * 30.0) +                // حديد: 30 كغ
        (currentPrices.cementPrice * 4.0) +               // اسمنت: 4 أكياس
        (currentPrices.block15Price * 50.0) +             // بلوك: 50 بلوكة
        (currentPrices.formworkAndPouringWages * 1.0) +   // 🌟 كوفراج وصب وبيتون مسلح: 1 م³
        (currentPrices.aggregateMaterialsPrice * 2.0) +   // مواد حصوية: 2 م³
        (currentPrices.ordinaryWorkerWage * 1.0);         // أجرة عامل: 1 يوم

    // 2. الحسابات النهائية
    double totalValue = finalPricePerSqm * area;
    double monthlyInstallment = totalValue / months;

    return {
      'pricePerSqm': finalPricePerSqm,
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}