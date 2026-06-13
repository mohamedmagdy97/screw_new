import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/dox_decoration.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/screenshot_preview_dialog.dart';
import 'package:share_plus/share_plus.dart';

/// زر مشاركة لوحة النتائج: يلتقط صورة، يعرض معاينة، يرفعها، ثم يشاركها.
class ShareScreenBtn extends StatelessWidget {
  const ShareScreenBtn({
    super.key,
    required this.cubit,
    required this.screenshotController,
  });

  final DashboardCubit cubit;
  final ScreenshotController screenshotController;

  Future<void> _captureAndShare(BuildContext context) async {
    if (!cubit.canShare) {
      Utilities().showCustomSnack(
        context,
        txt: 'لمشاركة النتائج يجب ادخال 4 جولات على الاقل',
      );
      return;
    }

    try {
      final Uint8List? bytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );
      if (bytes == null || !context.mounted) return;

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/screenshot${DateTime.now().toIso8601String().replaceAll(' ', '_')}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => ScreenshotPreviewDialog(
          imageBytes: bytes,
          onShare: () => cubit.uploadScreenshot(file, title: filePath),
        ),
      );

      await Share.shareXFiles([
        XFile(filePath),
      ], text: '📸 شوف نتيجتي! من تطبيق سكرو حاسبة');
    } catch (e) {
      debugPrint('خطأ أثناء مشاركة الصورة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: InkWell(
        onTap: () => _captureAndShare(context),
        child: Container(
          width: 1.sw,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: customBoxDecoration(
            borderRadius: AppRadii.sm,
            color: AppColors.mainColor,
          ),
          child: const CustomText(text: '📲 مشاركة النتيجة', fontSize: 18),
        ),
      ),
    );
  }
}
