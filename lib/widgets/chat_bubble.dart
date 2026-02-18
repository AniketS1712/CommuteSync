import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String name;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.darkCard,
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),

          if (!isMe) const SizedBox(width: 8),

          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    message,
                    style: TextStyle(color: isMe ? Colors.black : Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
