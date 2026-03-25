import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  /// محرك حساب تكلفة المتر الأساسي بناءً على أسعار السوق الحالية
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPricesHistoryData currentPrices, // ✅ تم تحديث النوع هنا
    int months = 48,
  }) {
    // حساب تكلفة المتر المربع التقديرية بناءً على الكميات
    double baseCostPerSqm = 
        (currentPrices.ironPrice * 0.045) +                
        (currentPrices.cementPrice * 0.350) +              
        (currentPrices.block15Price * 22.0) +              
        (currentPrices.formworkAndPouringWages * 1.0) +    
        (currentPrices.reinforcedConcretePrice * 0.25) +   
        (currentPrices.aggregateMaterialsPrice * 0.5) +    
        (currentPrices.ordinaryWorkerWage * 1.5);          

    // إضافة نسبة الربح والمصاريف 25%
    double finalPricePerSqm = baseCostPerSqm * 1.25;

    // الإجمالي والقسط (أرقام استرشادية لا تُحفظ في جدول العقود بل في جدول الاستحقاقات لاحقاً)
    double totalValue = finalPricePerSqm * area;
    double monthlyInstallment = totalValue / months;

    return {
      'pricePerSqm': finalPricePerSqm,
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}