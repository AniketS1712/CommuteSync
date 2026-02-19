import 'package:commutesync/core/page_transition.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/section_label.dart';
import '../widgets/form_dropdown.dart';
import '../widgets/time_field.dart';
import '../widgets/day_selector.dart';
import '../widgets/privacy_badge.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? homeArea;
  String? destination;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 30);

  final List<String> days = ["Mon", "Tue", "Wed", "Thurs", "Fri", "Sat", "Sun"];

  List<String> selectedDays = ["Mon", "Tue", "Wed", "Thurs", "Fri"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const PrivacyBadge(),
              const SizedBox(height: 30),

              const Text(
                "Tell us about your daily commute",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "CommuteSync predicts overlap without sharing sensitive locations.",
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 30),

              const SectionLabel(text: "HOME AREA"),
              const SizedBox(height: 8),
              FormDropdown(
                hint: "Select Neighborhood",
                value: homeArea,
                items: const ["North Delhi", "South Delhi", "Gurgaon", "Noida"],
                onChanged: (val) => setState(() => homeArea = val),
              ),

              const SizedBox(height: 20),

              const SectionLabel(text: "DESTINATION AREA"),
              const SizedBox(height: 8),
              FormDropdown(
                hint: "Select Workplace Hub",
                value: destination,
                items: const ["Tech Park", "Corporate Hub", "University"],
                onChanged: (val) => setState(() => destination = val),
              ),

              const SizedBox(height: 20),

              const SectionLabel(text: "USUAL DEPARTURE TIME"),
              const SizedBox(height: 8),
              TimeField(
                time: selectedTime.format(context),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
                },
              ),

              const SizedBox(height: 20),

              const SectionLabel(text: "DAYS OF TRAVEL"),
              const SizedBox(height: 10),
              DaySelector(
                days: days,
                selectedDays: selectedDays,
                onTap: (day) {
                  setState(() {
                    if (selectedDays.contains(day)) {
                      selectedDays.remove(day);
                    } else {
                      selectedDays.add(day);
                    }
                  });
                },
              ),

              const SizedBox(height: 40),

              PrimaryButton(
                text: "Continue",
                onPressed: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const HomeScreen()),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
