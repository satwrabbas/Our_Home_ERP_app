import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  /// محرك حساب تكلفة المتر الأساسي مطابق تماماً لمعادلات الإكسل
  /// 🌟 تمت إضافة مُعامل `coefficients` لاستقبال نسب التميز (طابق، اتجاه، إلخ)
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPricesHistoryData currentPrices,
    int months = 48,
    Map<String, double> coefficients = const {}, // 🌟 المعاملات الهندسية (مثال: {'floor': 0.05} أي زيادة 5%)
  }) {
    // -----------------------------------------------------
    // 1. حساب تكلفة المتر المربع الواحد (التكلفة الخام)
    // المعادلة: (السعر الافرادي × الكمية المطلوبة لـ 1 متر مربع)
    // -----------------------------------------------------
    double baseCostPerSqm = 
        (currentPrices.ironPrice * 30.0) +                // حديد: 30 كغ
        (currentPrices.cementPrice * 4.0) +               // اسمنت: 4 أكياس
        (currentPrices.block15Price * 50.0) +             // بلوك: 50 بلوكة
        (currentPrices.formworkAndPouringWages * 1.0) +   // كوفراج وصب وبيتون: 1 م³
        (currentPrices.aggregateMaterialsPrice * 2.0) +   // مواد حصوية: 2 م³
        (currentPrices.ordinaryWorkerWage * 1.0);         // أجرة عامل: 1 يوم

    // -----------------------------------------------------
    // 2. 🌟 تطبيق معاملات التمييز (Coefficients)
    // -----------------------------------------------------
    double extraPercentage = 0.0;
    
    // نجمع كل النسب الإضافية (مثلاً: 0.05 للطابق + 0.02 للاتجاه = 0.07 أي 7% زيادة)
    coefficients.forEach((key, value) {
      extraPercentage += value;
    });

    // السعر النهائي للمتر = التكلفة الخام + (التكلفة الخام × نسبة الزيادة)
    double finalPricePerSqm = baseCostPerSqm + (baseCostPerSqm * extraPercentage);

    // -----------------------------------------------------
    // 3. الحسابات النهائية للعقد (الإجمالي والقسط)
    // -----------------------------------------------------
    double totalValue = finalPricePerSqm * area;
    double monthlyInstallment = totalValue / months;

    return {
      'baseCostPerSqm': baseCostPerSqm,     // التكلفة الخام (قبل المعاملات) للعلم فقط
      'pricePerSqm': finalPricePerSqm,      // السعر النهائي (يُسجل في العقد)
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}