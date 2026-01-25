import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/dox_decoration.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class ImageHelper {
  static Future<String?> pickAndCompressImage({
    int maxSizeInBytes = 1000000,
    double maxWidth = 1024.0,
    int quality = 50,
  }) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: quality,
      maxWidth: maxWidth,
    );

    if (pickedFile == null) return null;

    final imageBytes = await pickedFile.readAsBytes();

    if (imageBytes.lengthInBytes > maxSizeInBytes) {
      return null; // Image too large
    }

    return base64Encode(imageBytes);
  }

  static bool isBase64Image(String text) {
    if (text.length < 100) return false;
    try {
      base64Decode(text.substring(0, 100));
      return true;
    } catch (e) {
      return false;
    }
  }

  static void showFullImage(
    BuildContext context,
    String base64, {
    double? padding,
    String? title,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black12,
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0, right: 16),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
            title: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: CustomText(text: title ?? '', fontSize: 20),
            ),
            toolbarHeight: 100,
          ),
          body: Center(
            child: Container(
              decoration: customBoxDecoration(
                borderRadius: 8.r,
                shadowColor: Colors.black.withOpacity(0.1),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.opacity_1.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: InteractiveViewer(
                  child: Image.memory(base64Decode(base64)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
