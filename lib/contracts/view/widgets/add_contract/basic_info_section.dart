import 'package:flutter/material.dart';

class BasicInfoSection extends StatelessWidget {
  final List<dynamic> clients;
  final String? selectedClientId;
  final ValueChanged<String?> onClientChanged;
  final TextEditingController guarantorController;
  final String selectedContractType;
  final ValueChanged<String?> onTypeChanged;

  const BasicInfoSection({
    super.key,
    required this.clients,
    required this.selectedClientId,
    required this.onClientChanged,
    required this.guarantorController,
    required this.selectedContractType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
            DropdownButtonFormField<String>(
              value: selectedClientId,
              decoration: const InputDecoration(labelText: 'اختر العميل (الفريق الثاني)', border: OutlineInputBorder()),
              items: clients.map((client) => DropdownMenuItem<String>(value: client.id, child: Text(client.name))).toList(),
              onChanged: onClientChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: guarantorController,
              decoration: const InputDecoration(labelText: 'اسم الكفيل الثلاثي', border: OutlineInputBorder())
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedContractType,
              decoration: const InputDecoration(labelText: 'نوع العقد', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items:['متخصص', 'لاحق التخصص']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
              onChanged: onTypeChanged,
            ),
          ],
        ),
      ),
    );
  }
}