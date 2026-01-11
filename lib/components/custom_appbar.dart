import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const CustomAppBar({super.key, required this.title, this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.grayy,
      title: CustomText(text: title, fontSize: 22.sp),
      leadingWidth: leading != null ? 105.w : null,
      leading: leading ?? const SizedBox(),

      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Transform.flip(
            flipX: true,
            child: const Icon(
              Icons.arrow_back_ios_sharp,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
