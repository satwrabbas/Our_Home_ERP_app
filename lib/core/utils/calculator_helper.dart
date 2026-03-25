import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPrice currentPrices,
    int months = 48,
  }) {
    // 1. حساب تكلفة المتر المربع التقديرية (الكميات تقريبية ويمكنك تعديلها)
    double baseCostPerSqm = 
        (currentPrices.ironPrice * 0.045) +                // كمية الحديد للمتر
        (currentPrices.cementPrice * 0.350) +              // كمية الأسمنت
        (currentPrices.block15Price * 22.0) +              // عدد البلوك للمتر
        (currentPrices.formworkAndPouringWages * 1.0) +    // أجور الصب
        (currentPrices.reinforcedConcretePrice * 0.25) +   // البيتون المسلح للمتر مكعب / مساحة
        (currentPrices.aggregateMaterialsPrice * 0.5) +    // البحص والنحاتة
        (currentPrices.ordinaryWorkerWage * 1.5);          // يوميات العمال

    // 2. نسبة الربح 25% مثلاً
    double finalPricePerSqm = baseCostPerSqm * 1.25;

    // 3. الإجمالي
    double totalValue = finalPricePerSqm * area;
    double monthlyInstallment = totalValue / months;

    return {
      'pricePerSqm': finalPricePerSqm,
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}