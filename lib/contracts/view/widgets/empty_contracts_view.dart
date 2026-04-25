import 'package:flutter/material.dart';

class EmptyContractsView extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;

  const EmptyContractsView({
    super.key,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}