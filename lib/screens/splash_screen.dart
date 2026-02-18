import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/privacy_badge.dart';
import '../widgets/primary_button.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          const GridOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  const Align(
                    alignment: Alignment.topRight,
                    child: PrivacyBadge(),
                  ),

                  const Spacer(),

                  const _LogoSection(),

                  const SizedBox(height: 30),

                  const _TitleSection(),

                  const Spacer(),

                  PrimaryButton(
                    text: "Get Started",
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildOutlinedButton(),

                  const SizedBox(height: 20),

                  const Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundGradientStart,
            AppColors.backgroundGradientEnd,
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: Colors.white.withAlpha(100)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "Sign In",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary),
        boxShadow: const [
          BoxShadow(color: Color(0x3322E48B), blurRadius: 25, spreadRadius: 10),
        ],
      ),
      child: const Icon(Icons.auto_awesome, size: 60, color: AppColors.primary),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: "Commute",
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: "Sync",
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "No posting. No booking.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 6),
        const Text(
          "Just intent.",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class GridOverlay extends StatelessWidget {
  const GridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha(40)
      ..strokeWidth = 1;

    const gap = 40.0;

    for (double i = 0; i < size.width; i += gap) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gap) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
