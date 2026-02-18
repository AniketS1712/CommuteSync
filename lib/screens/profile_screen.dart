import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/section_title.dart';
import 'trust_safety_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientEnd,
        elevation: 0,
        title: const Text(
          "Profile & Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              _buildProfileHeader(),

              const SizedBox(height: 30),

              _buildAIStatus(),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: SectionTitle(text: "SETTINGS"),
              ),

              const SizedBox(height: 15),

              SettingsTile(
                icon: Icons.security,
                title: "Trust & Safety",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrustSafetyScreen(),
                    ),
                  );
                },
              ),

              SettingsTile(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {},
              ),

              SettingsTile(
                icon: Icons.edit,
                title: "Edit Commute Details",
                onTap: () {},
              ),

              const SizedBox(height: 40),

              _buildLogoutButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.darkCard,
          child: Icon(Icons.person, size: 46, color: AppColors.primary),
        ),

        SizedBox(height: 14),

        Text(
          "Aniket Singhal",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 6),

        Text(
          "Street Coders • Verified",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAIStatus() {
    return const GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("AI Status", style: TextStyle(color: AppColors.textSecondary)),
          Text(
            "Active",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(500, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {},
      child: const Text(
        "Log Out",
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
