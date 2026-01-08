import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  static void showFullImage(BuildContext context, String base64) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black12,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(child: Image.memory(base64Decode(base64))),
          ),
        ),
      ),
    );
  }
}
