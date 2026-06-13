import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const CustomAppBar({super.key, required this.title, this.leading});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: palette.brandGradient),
      ),
      title: CustomText(text: title, fontSize: 22.sp, color: Colors.white),
      leadingWidth: leading != null ? 105.w : null,
      leading: leading ?? const SizedBox(),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Transform.flip(
            flipX: true,
            child: const Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
