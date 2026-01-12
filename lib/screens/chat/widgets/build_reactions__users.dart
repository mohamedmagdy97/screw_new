import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class BuildReactionsUsers extends StatelessWidget {
  const BuildReactionsUsers({
    super.key,
    required this.reactingDetails,
    required this.userName,
    required this.emoji,
  });

  final List<String> reactingDetails;
  final String? userName;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomText(
            text: 'المتفاعلون بـ $emojiـ',
            fontSize: 14.sp,
            fontFamily: AppFonts.bold,
            color: AppColors.black,
          ),
        ),
        const Divider(),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reactingDetails.length,
            itemBuilder: (context, index) {
              final nName = reactingDetails[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: CustomText(
                  text: nName == userName
                      ? 'أنا (أنت)'
                      : reactingDetails[index],
                  fontSize: 16.sp,
                  color: AppColors.black,
                  textAlign: TextAlign.start,
                ),
                trailing: Text(
                  emoji.toString(),
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
