import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  String selectedPlan = "Quarterly";

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
              const SizedBox(height: 10),

              _buildTopBar(),

              const SizedBox(height: 30),

              _buildHeader(),

              const SizedBox(height: 30),

              _buildComparisonCard(),

              const SizedBox(height: 30),

              const Text(
                "EXCLUSIVE PREMIUM PERKS",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              _perkCard(
                icon: Icons.payments,
                title: "₹0 Platform Fee",
                subtitle: "On your first 5 rides every month",
              ),

              const SizedBox(height: 16),

              _perkCard(
                icon: Icons.percent,
                title: "10% Extra Discount",
                subtitle: "Flat off on all eco-friendly rides",
              ),

              const SizedBox(height: 30),

              _planCard(
                title: "Monthly",
                price: "₹199",
                subtitle: "Standard flexibility",
              ),

              const SizedBox(height: 16),

              _planCard(
                title: "Quarterly",
                price: "₹479",
                subtitle: "Save 20% over monthly",
              ),

              const SizedBox(height: 16),

              _planCard(
                title: "Yearly",
                price: "₹1,429",
                subtitle: "Save 40% + Special Badge",
              ),

              const SizedBox(height: 30),

              _buildSustainabilityNote(),

              const SizedBox(height: 30),

              _buildUpgradeButton(),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Cancel anytime. Terms apply.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP BAR =================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withAlpha(45),
          ),
          child: const Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
              SizedBox(width: 6),
              Text(
                "PRO ACCESS",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CommuteSync Premium 🌱",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Support sustainable mobility & save more on every ride.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  // ================= COMPARISON CARD =================

  Widget _buildComparisonCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3A2A), Color(0xFF062019)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          _ComparisonRow(
            "AI Learning",
            "Standard models",
            "Advanced Analytics",
          ),
          Divider(color: Colors.white12),
          _ComparisonRow(
            "Suggestions",
            "Basic routing",
            "Priority Suggestions",
          ),
          Divider(color: Colors.white12),
          _ComparisonRow("Impact Tracking", "Weekly reports", "Maximum Impact"),
          Divider(color: Colors.white12),
          _ComparisonRow("Safety", "Basic support", "High Confidence"),
        ],
      ),
    );
  }

  // ================= PERK CARD =================

  Widget _perkCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3A2A), Color(0xFF07271C)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= PLAN CARD =================

  Widget _planCard({
    required String title,
    required String price,
    required String subtitle,
  }) {
    final bool selected = selectedPlan == title;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white12,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUSTAINABILITY NOTE =================

  Widget _buildSustainabilityNote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3A2A), Color(0xFF07271C)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sustainability Note",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Your subscription directly funds carbon-offset initiatives and local low-carbon commuting infrastructure.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= UPGRADE BUTTON =================

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "Upgrade to Premium →",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ================= COMPARISON ROW =================

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;

  const _ComparisonRow(this.feature, this.free, this.premium);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(feature, style: const TextStyle(color: Colors.white70)),
        ),
        Expanded(
          child: Text(free, style: const TextStyle(color: Colors.white38)),
        ),
        Expanded(
          child: Text(
            premium,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
