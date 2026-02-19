import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031F17),
        elevation: 0,
        title: const Text(
          "YOUR IMPACT",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildEcoStatusCard(),

              const SizedBox(height: 20),

              _buildCO2Card(),

              const SizedBox(height: 20),

              _buildMeetingPointCard(),

              const SizedBox(height: 30),

              _buildStatsGrid(),

              const SizedBox(height: 30),

              _buildExplanationCard(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingPointCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3325), Color(0xFF062019)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.greenAccent.withAlpha(60), blurRadius: 25),
        ],
      ),
      child: Stack(
        children: [
          /// Fake Map Background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(painter: FakeMapPainter()),
            ),
          ),

          /// Meeting Pin
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.greenAccent, size: 40),
                SizedBox(height: 6),
                Text(
                  "North Junction",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// AI Badge
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withAlpha(45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "3 MIN DETOUR PREDICTED",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoStatusCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const RadialGradient(
          colors: [Color(0xFF0D5C3B), Color(0xFF053224)],
          center: Alignment.center,
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withAlpha(77),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 40, color: Colors.greenAccent),
            SizedBox(height: 10),
            Text(
              "ECO-WARRIOR STATUS",
              style: TextStyle(
                color: Colors.greenAccent,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCO2Card() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3E2C), Color(0xFF072A1E)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withAlpha(60),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TOTAL CO2 SAVED",
            style: TextStyle(
              color: Colors.greenAccent,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                "1.2",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Tons",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_down, color: Colors.greenAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  "5% IMPROVEMENT",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _miniCard(
                icon: Icons.directions_car,
                label: "CARS REDUCED",
                value: "24",
                change: "↓ 12%",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _miniCard(
                icon: Icons.traffic,
                label: "CONGESTION SCORE",
                value: "88",
                change: "↓ 10pts",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _miniCard(
                icon: Icons.warning_amber_rounded,
                label: "DELAY RISK",
                value: "22%",
                change: "Low",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _miniCard(
                icon: Icons.timer,
                label: "TIME SAVED",
                value: "48m",
                change: "+5 mins",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String label,
    required String value,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3325), Color(0xFF07271C)],
        ),
        boxShadow: [BoxShadow(color: Colors.greenAccent.withAlpha(40))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.greenAccent),
              Text(change, style: const TextStyle(color: Colors.greenAccent)),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            label,
            style: const TextStyle(color: Colors.white54, letterSpacing: 1.5),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2A20), Color(0xFF062019)],
        ),
      ),
      child: const Text(
        "Your urban sustainability contribution is calculated based on your unique commuting patterns over the last 30 days. By choosing smarter routes, you’ve directly impacted city air quality.",
        style: TextStyle(color: Colors.white70, height: 1.6),
      ),
    );
  }
}

class FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint roadPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1.5;

    final Paint gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;

    const double gap = 40.0;

    // Draw subtle grid
    for (double i = 0; i < size.width; i += gap) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }

    for (double i = 0; i < size.height; i += gap) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw fake curved road
    final Path path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width,
      size.height * 0.7,
    );

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(FakeMapPainter oldDelegate) {
    return false;
  }
}
