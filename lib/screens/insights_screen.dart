import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_title.dart';
import '../widgets/analytics_bar.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientEnd,
        elevation: 0,
        title: const Text(
          "AI Insights",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildStatusCard(),

              const SizedBox(height: 30),

              const SectionTitle(text: "OVERLAP ANALYTICS"),

              const SizedBox(height: 15),

              _buildBarChart(),

              const SizedBox(height: 40),

              const SectionTitle(text: "DELAY RISK MONITOR"),

              const SizedBox(height: 20),

              _buildDelayIndicator(),

              const SizedBox(height: 40),

              _buildTimeSavedCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return const GlassCard(
      child: Row(
        children: [
          Icon(Icons.auto_graph, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Routine recalibration detected.\nAI confidence improved by 8% this week.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return const GlassCard(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnalyticsBar(height: 40, label: "Mon"),
          AnalyticsBar(height: 70, label: "Tue"),
          AnalyticsBar(height: 55, label: "Wed"),
          AnalyticsBar(height: 85, label: "Thu", highlighted: true),
          AnalyticsBar(height: 65, label: "Fri"),
        ],
      ),
    );
  }

  Widget _buildDelayIndicator() {
    return const Center(
      child: SizedBox(
        height: 140,
        width: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 0.6,
              strokeWidth: 12,
              backgroundColor: Colors.white12,
              color: AppColors.primary,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Moderate",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "60% Risk",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSavedCard() {
    return const GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Time Saved This Week",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            "1h 42m",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
