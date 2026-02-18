import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }
}
