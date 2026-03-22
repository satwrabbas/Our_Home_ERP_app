import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  /// محرك حساب تكلفة الشقة والقسط الشهري بناءً على أسعار الإعدادات
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPrice currentPrices,
    int months = 48, // افتراض أن التقسيط على 4 سنوات (48 شهراً)
  }) {
    // -----------------------------------------------------
    // 1. معاملات الاستهلاك التقديرية لكل متر مربع (يمكنك تعديلها لاحقاً حسب هندستك)
    // -----------------------------------------------------
    const double ironPerSqm = 0.045;       // طن حديد لكل متر مربع
    const double cementPerSqm = 0.350;     // طن أسمنت لكل متر مربع
    const double blockPerSqm = 22.0;       // عدد البلوكات للمتر المربع
    const double workerDaysPerSqm = 1.5;   // يومية عامل لكل متر مربع

    // -----------------------------------------------------
    // 2. حساب تكلفة المتر المربع الصافية (مواد + أجور) من الأسعار الحالية
    // -----------------------------------------------------
    double baseCostPerSqm = (currentPrices.ironPrice * ironPerSqm) +
                            (currentPrices.cementPrice * cementPerSqm) +
                            (currentPrices.blockPrice * blockPerSqm) +
                            (currentPrices.workerDailyRate * workerDaysPerSqm);

    // -----------------------------------------------------
    // 3. إضافة نسبة الربح والمصاريف الإدارية (مثلاً 25% زيادة)
    // -----------------------------------------------------
    double finalPricePerSqm = baseCostPerSqm * 1.25;

    // -----------------------------------------------------
    // 4. الحسابات النهائية
    // -----------------------------------------------------
    double totalValue = finalPricePerSqm * area;
    double monthlyInstallment = totalValue / months;

    return {
      'pricePerSqm': finalPricePerSqm,
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}