import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/chat/presentation/widgets/typing_dots.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key, required Set<String> usersTyping})
    : _usersTyping = usersTyping;

  final Set<String> _usersTyping;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const TypingDots(),
          const SizedBox(width: 4),
          CustomText(
            text: ' يكتب الأن ${_usersTyping.join(', ')}',
            textAlign: TextAlign.end,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}
