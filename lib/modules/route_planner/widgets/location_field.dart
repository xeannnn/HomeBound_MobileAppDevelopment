import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

/// Origin/destination text field styled to match the wireframe — an icon,
/// a borderless TextField, all inside a rounded surface container.
class LocationField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;

  const LocationField({
    super.key,
    required this.icon,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}