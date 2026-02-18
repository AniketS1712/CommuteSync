import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class DaySelector extends StatelessWidget {
  final List<String> days;
  final List<String> selectedDays;
  final Function(String) onTap;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final selected = selectedDays.contains(day);

        return GestureDetector(
          onTap: () => onTap(day),
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              day,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
