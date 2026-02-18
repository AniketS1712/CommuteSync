import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/primary_button.dart';

class RideRoomScreen extends StatefulWidget {
  const RideRoomScreen({super.key});

  @override
  State<RideRoomScreen> createState() => _RideRoomScreenState();
}

class _RideRoomScreenState extends State<RideRoomScreen> {
  final TextEditingController messageController = TextEditingController();

  final List<Map<String, String>> messages = [
    {"name": "Aniket", "text": "Good morning!"},
    {"name": "Sanyam", "text": "Let’s meet at Gate 3."},
    {"name": "Khemendra", "text": "Sounds good 👍"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientEnd,
        elevation: 0,
        title: const Text(
          "Ride Room",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildAISummary(),

          const Divider(color: Colors.white12, height: 1),

          Expanded(child: _buildChat()),

          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildAISummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "AI Suggested Plan",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 14),

            Text(
              "Meeting Point: Gate 3",
              style: TextStyle(color: Colors.white),
            ),

            SizedBox(height: 6),

            Text("Departure: 07:20 AM", style: TextStyle(color: Colors.white)),

            SizedBox(height: 6),

            Text(
              "Driver: Aniket (Host)",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg["name"] == "Aniket";

        return ChatBubble(
          message: msg["text"]!,
          isMe: isMe,
          name: msg["name"]!,
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFF0B231B)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      setState(() {
                        messages.add({
                          "name": "Aniket",
                          "text": messageController.text,
                        });
                      });
                      messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          PrimaryButton(
            text: "Confirm Ride",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ride Confirmed 🚗")),
              );
            },
          ),
        ],
      ),
    );
  }
}
