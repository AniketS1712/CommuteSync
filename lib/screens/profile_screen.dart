import 'package:commutesync/core/fake_auth_service.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/page_transition.dart';
import '../widgets/glass_card.dart';
import 'manage_subscription_screen.dart';
import 'trust_safety_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool womenOnlyMatching =
      FakeAuthService.currentUser?["womenOnlyMatching"] ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientEnd,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildProfileHeader(),

              const SizedBox(height: 30),

              _buildCommuteSection(),

              const SizedBox(height: 30),

              _buildPrivacySection(),

              const SizedBox(height: 30),

              _buildSubscriptionCard(),

              const SizedBox(height: 40),

              _buildLogoutButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _buildProfileHeader() {
    final user = FakeAuthService.currentUser;

    final String name = user?["name"] ?? "User";
    final String org = user?["organization"] ?? "Independent";
    final String gender = user?["gender"] ?? "";

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.darkCard,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.black),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "$org • ${gender.toUpperCase()}",
          style: const TextStyle(
            color: AppColors.primary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================= COMMUTE INTELLIGENCE =================

  Widget _buildCommuteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "COMMUTE INTELLIGENCE",
          style: TextStyle(color: AppColors.textSecondary, letterSpacing: 1.5),
        ),
        const SizedBox(height: 15),
        GlassCard(
          child: Column(
            children: [
              _tile(
                icon: Icons.route,
                title: "Edit Commute Routine",
                subtitle: "Update shifts and locations",
                onTap: () {},
              ),
              const Divider(color: Colors.white12),
              _tile(
                icon: Icons.business,
                title: "Organization Status",
                subtitle: "TechNexus Global HQ",
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "VERIFIED",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= PRIVACY SECTION =================

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PRIVACY & SAFETY",
          style: TextStyle(color: AppColors.textSecondary, letterSpacing: 1.5),
        ),
        const SizedBox(height: 15),
        GlassCard(
          child: Column(
            children: [
              _tile(
                icon: Icons.shield,
                title: "Trust & Safety",
                subtitle: "Verification and protection",
                onTap: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const TrustSafetyScreen()),
                  );
                },
              ),
              const Divider(color: Colors.white12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Women-only Matching",
                  style: TextStyle(color: Colors.white),
                ),
                value: womenOnlyMatching,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    womenOnlyMatching = val;
                    FakeAuthService.currentUser?["womenOnlyMatching"] = val;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= SUBSCRIPTION CARD =================

  Widget _buildSubscriptionCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PREMIUM PLAN",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Unlock advanced AI route optimization, priority matching and deeper analytics.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(page: const ManageSubscriptionScreen()),
                );
              },
              child: const Text(
                "Manage Subscription",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOGOUT =================

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton.icon(
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Logout",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          FakeAuthService.logout();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }
}
