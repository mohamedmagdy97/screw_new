import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class ScreenshotPreviewDialog extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onShare;

  const ScreenshotPreviewDialog({
    super.key,
    required this.imageBytes,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomText(
              text: '📸 معاينة الصورة',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grayy),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'إلغاء',
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'مشاركة',
                    onPressed: () {
                      onShare();
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
