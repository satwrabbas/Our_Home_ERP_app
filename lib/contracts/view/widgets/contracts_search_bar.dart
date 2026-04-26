//lib\contracts\view\widgets\contracts_search_bar.dart
import 'package:flutter/material.dart';

class ContractsSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final int resultCount;

  const ContractsSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border(bottom: BorderSide(color: Colors.teal.shade100, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.search, color: Colors.teal.shade600, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: '🔍 ابحث عن اسم العميل، الوصف، أو رقم العقد...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => onChanged(''))
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Text('النتيجة: $resultCount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
          )
        ],
      ),
    );
  }
}