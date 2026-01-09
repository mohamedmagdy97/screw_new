import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class InputBar extends StatelessWidget {
  final TextEditingController textCtrl;
  final Function() pickAndSendImage;
  final Function() sendMessage;
  final Function(bool) updateTyping;

  const InputBar({
    super.key,
    required this.textCtrl,
    required this.pickAndSendImage,
    required this.sendMessage,
    required this.updateTyping,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.mainColor,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
                onPressed: pickAndSendImage,
              ),
            ),

            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: textCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك ...',
                  hintStyle: TextStyle(fontFamily: AppFonts.regular),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintTextDirection: TextDirection.rtl,
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
                minLines: 1,
                onChanged: (text) => updateTyping(text.isNotEmpty),
              ),
            ),

            /* const SizedBox(width: 6),
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressUp: _stopRecording,
              child: CircleAvatar(
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                child: Icon(_isRecording ? Icons.mic : Icons.mic_none),
              ),
            ),*/
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.mainColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
