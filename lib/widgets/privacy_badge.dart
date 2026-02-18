import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            "PRIVACY-FIRST AI",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
