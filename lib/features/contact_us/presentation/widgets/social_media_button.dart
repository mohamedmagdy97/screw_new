import 'package:flutter/material.dart';

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
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image(image: AssetImage(assetPath), height: 56, width: 56),
      ),
    );
  }
}
