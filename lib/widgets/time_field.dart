import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class TimeField extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const TimeField({super.key, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              time,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
