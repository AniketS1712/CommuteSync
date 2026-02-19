import 'package:commutesync/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/fake_auth_service.dart';
import '../core/page_transition.dart';
import '../widgets/primary_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? gender;

  bool womenDriversOnly = false;
  bool womenOnlyMatching = false;
  bool shareEmergency = true;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientEnd,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Set Up Your Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              _buildField(nameController, "Full Name"),
              const SizedBox(height: 16),

              _buildField(emailController, "Email"),
              const SizedBox(height: 16),

              _buildField(passwordController, "Password", obscure: true),

              const SizedBox(height: 20),

              const Text("Gender", style: TextStyle(color: Colors.white70)),

              const SizedBox(height: 8),

              _buildGenderSelector(),

              const SizedBox(height: 30),

              const Text(
                "Safety Preferences",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 12),

              _buildToggle(
                "Women Drivers Only",
                womenDriversOnly,
                (v) => setState(() => womenDriversOnly = v),
              ),

              _buildToggle(
                "Women-Only Ride Matching",
                womenOnlyMatching,
                (v) => setState(() => womenOnlyMatching = v),
              ),

              _buildToggle(
                "Share Emergency Contact",
                shareEmergency,
                (v) => setState(() => shareEmergency = v),
              ),

              const SizedBox(height: 40),

              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : PrimaryButton(text: "Continue", onPressed: _handleSignIn),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ["Male", "Female", "Other"].map((g) {
        final selected = gender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => gender = g),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                g,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggle(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.primary,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
    );
  }

  void _handleSignIn() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
      return;
    }

    setState(() => isLoading = true);

    await FakeAuthService.signIn({
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "gender": gender,
      "womenDriversOnly": womenDriversOnly,
      "womenOnlyMatching": womenOnlyMatching,
      "shareEmergency": shareEmergency,
    });

    setState(() => isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      SmoothPageRoute(page: const OnboardingScreen()),
      (_) => false,
    );
  }
}
