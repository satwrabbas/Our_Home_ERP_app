// lib\core\utils\calculator_helper.dart
import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  /// محرك حساب تكلفة المتر الأساسي مطابق تماماً لمعادلات الإكسل
  /// 🌟 تمت إضافة منطق الحساب المتسلسل (الموقع أولاً، ثم البقية)
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPricesHistoryData currentPrices,
    int months = 48,
    Map<String, double> coefficients = const {}, 
  }) {
    // -----------------------------------------------------
    // 1. حساب تكلفة المتر المربع الواحد (التكلفة الخام)
    // -----------------------------------------------------
    double baseCostPerSqm = 
        (currentPrices.ironPrice * 30.0) +                
        (currentPrices.cementPrice * 4.0) +               
        (currentPrices.block15Price * 50.0) +             
        (currentPrices.formworkAndPouringWages * 1.0) +   
        (currentPrices.aggregateMaterialsPrice * 2.0) +   
        (currentPrices.ordinaryWorkerWage * 1.0);         

    // -----------------------------------------------------
    // 2. 🌟 تطبيق معامل "الموقع" أولاً (لإنشاء أساس سعري جديد)
    // -----------------------------------------------------
    // نبحث عن مفتاح 'الموقع'، إذا لم يوجد نعتبره 0
    double locationCoefficient = coefficients['الموقع'] ?? 0.0;
    
    // السعر بعد الموقع = التكلفة الخام + (التكلفة الخام × نسبة الموقع)
    double priceAfterLocation = baseCostPerSqm + (baseCostPerSqm * locationCoefficient);

    // -----------------------------------------------------
    // 3. 🌟 تجميع وتطبيق باقي المعاملات على (السعر بعد الموقع)
    // -----------------------------------------------------
    double otherExtraPercentage = 0.0;
    
    // نجمع كل النسب (باستثناء الموقع لأنه حُسب بالفعل)
    coefficients.forEach((key, value) {
      if (key != 'الموقع') {
        otherExtraPercentage += value;
      }
    });

    // السعر النهائي = السعر بعد الموقع + (السعر بعد الموقع × مجموع باقي النسب)
    double finalPricePerSqm = priceAfterLocation + (priceAfterLocation * otherExtraPercentage);

    // -----------------------------------------------------
    // 4. الحسابات النهائية للعقد (الإجمالي والقسط)
    // -----------------------------------------------------
    double totalValue = finalPricePerSqm * area;
    double monthlyInstallment = totalValue / months;

    return {
      'baseCostPerSqm': baseCostPerSqm,         // التكلفة الخام المبدئية
      'priceAfterLocation': priceAfterLocation, // السعر بعد الموقع (مرحلة وسيطة للعلم)
      'pricePerSqm': finalPricePerSqm,          // السعر النهائي المعتمد في العقد
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}