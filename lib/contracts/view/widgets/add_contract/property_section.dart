import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class PropertySection extends StatelessWidget {
  final bool isAllocated;
  final List<dynamic> buildings;
  final List<dynamic> availableApartments;
  final String? selectedBuildingId;
  final String? selectedApartmentId;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onApartmentChanged;
  final TextEditingController monthlyAmountCtrl;

  const PropertySection({
    super.key,
    required this.isAllocated,
    required this.buildings,
    required this.availableApartments,
    required this.selectedBuildingId,
    required this.selectedApartmentId,
    required this.onBuildingChanged,
    required this.onApartmentChanged,
    required this.monthlyAmountCtrl,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAllocated) {
      return Card(
        elevation: 2, color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children:[
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('العقد لاحق التخصص. النظام سيولد نقطة تفاعل شهرية واحدة.', style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: monthlyAmountCtrl,
                inputFormatters: [ThousandsFormatter()],
                decoration: const InputDecoration(
                  labelText: 'المبلغ المتفق عليه شهرياً (ل.س)', 
                  border: OutlineInputBorder(), filled: true, fillColor: Colors.white,
                  prefixIcon: Icon(Icons.payments, color: Colors.blue)
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2, color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('🏠 اختيار العقار من الكتالوج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBuildingId,
              decoration: const InputDecoration(labelText: 'اختر المحضر', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items: buildings.map((b) => DropdownMenuItem<String>(value: b.id, child: Text('${b.name} (${b.location ?? ''})'))).toList(),
              onChanged: onBuildingChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedApartmentId,
              decoration: const InputDecoration(labelText: 'اختر الشقة المتاحة', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items: availableApartments.map((apt) => DropdownMenuItem<String>(value: apt.id, child: Text('شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}'))).toList(),
              onChanged: onBuildingChanged == null ? null : onApartmentChanged,
              disabledHint: Text(selectedBuildingId == null ? 'يرجى اختيار المحضر أولاً' : 'لا يوجد شقق متاحة!'),
            ),
          ],
        ),
      ),
    );
  }
}