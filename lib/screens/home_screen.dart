import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/fake_auth_service.dart';
import '../core/page_transition.dart';
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

  bool isScanning = true;
  bool highTrafficMode = false;

  double matchConfidence = 0.0;
  int matchedUsers = 0;
  String delayRisk = "Moderate";

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    user = FakeAuthService.currentUser;

    Future.delayed(const Duration(seconds: 2), () {
      _simulateAI();
    });
  }

  void _simulateAI() {
    final womenOnly = user?["womenOnlyMatching"] == true;
    final gender = user?["gender"];

    if (womenOnly && gender == "Female") {
      matchedUsers = 1;
      matchConfidence = highTrafficMode ? 0.75 : 0.62;
      delayRisk = "Low";
    } else if (womenOnly && gender != "Female") {
      matchedUsers = 0;
      matchConfidence = 0.0;
      delayRisk = "Unavailable";
    } else {
      matchedUsers = 2;
      matchConfidence = highTrafficMode ? 0.88 : 0.70;
      delayRisk = highTrafficMode ? "High" : "Moderate";
    }

    setState(() {
      isScanning = false;
    });
  }

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

              const SizedBox(height: 25),

              _buildCongestionToggle(),

              const SizedBox(height: 20),

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
    final name = user?["name"] ?? "User";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.circle, size: 10, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  "AI ACTIVE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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

  Widget _buildCongestionToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      title: const Text(
        "High Congestion Day",
        style: TextStyle(color: Colors.white),
      ),
      value: highTrafficMode,
      onChanged: (v) {
        setState(() {
          highTrafficMode = v;
          isScanning = true;
        });

        Future.delayed(const Duration(seconds: 1), () {
          _simulateAI();
        });
      },
    );
  }

  Widget _buildMatchCard() {
    if (isScanning) {
      return GlassCard(
        child: Column(
          children: const [
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              "Analyzing commute overlaps...",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }

    if (matchedUsers == 0) {
      return GlassCard(
        child: Column(
          children: const [
            SizedBox(height: 20),
            Icon(Icons.lock, color: Colors.pink),
            SizedBox(height: 10),
            Text(
              "No eligible matches under current safety preferences.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }

    final percentage = (matchConfidence * 100).toInt();

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

          Text(
            "$matchedUsers ${matchedUsers == 1 ? "commuter" : "commuters"} have a $percentage% overlap tomorrow.",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 20),

          Text(
            "$percentage% CONFIDENCE",
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: matchConfidence,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MatchInfoBlock(
                icon: Icons.access_time,
                label: "WINDOW",
                value: "07:15 - 07:45",
              ),
              MatchInfoBlock(
                icon: Icons.warning_amber_rounded,
                label: "DELAY RISK",
                value: delayRisk,
              ),
            ],
          ),

          const SizedBox(height: 25),

          PrimaryButton(
            text: "I'm Interested",
            onPressed: () {
              Navigator.push(
                context,
                SmoothPageRoute(
                  page: RideRoomScreen(
                    womenOnly: user?["womenOnlyMatching"] == true,
                  ),
                ),
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
            SmoothPageRoute(page: const InsightsScreen()),
          );
        }

        if (index == 3) {
          Navigator.push(context, SmoothPageRoute(page: const ProfileScreen()));
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
