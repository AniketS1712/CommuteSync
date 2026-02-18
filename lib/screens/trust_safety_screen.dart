import 'package:flutter/material.dart';

class TrustSafetyScreen extends StatefulWidget {
  const TrustSafetyScreen({super.key});

  @override
  State<TrustSafetyScreen> createState() => _TrustSafetyScreenState();
}

class _TrustSafetyScreenState extends State<TrustSafetyScreen> {
  bool womenOnly = true;
  bool shareEmergency = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061C15),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061C15),
        elevation: 0,
        title: const Text(
          "Trust & Safety",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            /// ORGANIZATION VERIFIED
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3A2C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF22E48B)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Organization Verified\nstreetcoders.edu",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// RELIABILITY SCORE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3A2C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ride Reliability Score",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Color(0xFF22E48B), size: 18),
                      SizedBox(width: 6),
                      Text(
                        "92%",
                        style: TextStyle(
                          color: Color(0xFF22E48B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// WOMEN ONLY TOGGLE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3A2C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Enable Women-Only Matching",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Switch(
                    value: womenOnly,
                    activeThumbColor: const Color(0xFF22E48B),
                    onChanged: (val) {
                      setState(() {
                        womenOnly = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// EMERGENCY CONTACT
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3A2C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Share Emergency Contact During Ride",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Switch(
                    value: shareEmergency,
                    activeThumbColor: const Color(0xFF22E48B),
                    onChanged: (val) {
                      setState(() {
                        shareEmergency = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// PRIVACY NOTE
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3A2C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Color(0xFF22E48B)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Exact addresses are never stored. Matching is based on area-level intelligence.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
