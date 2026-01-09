import 'package:flutter/material.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';

class BuildStatusIcons extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;

  const BuildStatusIcons({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (!isMe) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.status == 'sending')
            const Icon(Icons.access_time, size: 12, color: Colors.grey)
          else if (msg.seenBy.isNotEmpty)
            const Icon(Icons.done_all, size: 14, color: Colors.blue)
          else
            const Icon(Icons.done_all, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
