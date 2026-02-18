import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AnalyticsBar extends StatelessWidget {
  final double height;
  final String label;
  final bool highlighted;

  const AnalyticsBar({
    super.key,
    required this.height,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height,
          width: 28,
          decoration: BoxDecoration(
            gradient: highlighted
                ? const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF16B873)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: highlighted ? null : AppColors.primary.withAlpha(180),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
