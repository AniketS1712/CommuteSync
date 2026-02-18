import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/impact_card.dart';
import '../widgets/match_info_block.dart';
import '../widgets/primary_button.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'ride_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildHeader(),

              const SizedBox(height: 30),

              _buildMatchCard(),

              const SizedBox(height: 30),

              const Text(
                "WEEKLY IMPACT",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  ImpactCard(value: "12", label: "Cars \nAvoided"),
                  ImpactCard(value: "4.2", label: "KG CO₂ Saved"),
                  ImpactCard(value: "82", label: "Congestion Score"),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Street Coders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  "AI ACTIVE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.darkCard,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildMatchCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Privacy Match Detected",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "2 others have a 70% commute overlap tomorrow.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Text(
                "70% CONFIDENCE",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 25),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MatchInfoBlock(
                icon: Icons.access_time,
                label: "WINDOW",
                value: "07:15 - 07:45",
              ),
              MatchInfoBlock(
                icon: Icons.warning_amber_rounded,
                label: "DELAY RISK",
                value: "Moderate",
              ),
            ],
          ),

          const SizedBox(height: 25),

          PrimaryButton(
            text: "I'm Interested",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RideRoomScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0B231B),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.white54,
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() => selectedIndex = index);

        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InsightsScreen()),
          );
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Network"),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: "Insights",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
