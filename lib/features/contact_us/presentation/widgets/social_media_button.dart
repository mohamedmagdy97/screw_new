import 'package:flutter/material.dart';

/// Widget for displaying a social media button
class SocialMediaButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const SocialMediaButton({
    super.key,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Image(
        image: AssetImage(assetPath),
        height: 50,
        width: 50,
      ),
    );
  }
}

