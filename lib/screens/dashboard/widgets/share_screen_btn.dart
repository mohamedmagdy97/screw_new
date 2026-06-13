import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/dox_decoration.dart';
import 'package:screw_calculator/models/player_model.dart';
import 'package:screw_calculator/screens/dashboard/dashboard_data.dart';

class ShareScreenBtn extends StatelessWidget {
  const ShareScreenBtn({super.key, required this.dashboardData, required this.players});

  final DashboardData dashboardData;
  final List<PlayerModel> players;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16),
      child: Column(
        spacing: 12,
        children: [
          // CustomText(
          //   text:
          //       'عند عمل مشاركة سيتم مشاركة نتيجتك مع الاخرين في صفحة مشاركات الاخرين وأيضا مع اصدقائك على السوشيال ميديا',
          //   fontSize: 14.sp,
          // ),
          InkWell(
            onTap: () => dashboardData.captureAndShare(context,players),
            child: Container(
              width: 1.sw,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: customBoxDecoration(
                borderRadius: 8,
                color: AppColors.mainColor,
              ),

              // shape: Border.all(color: AppColors.red),
              // extendedPadding: const EdgeInsets.symmetric(horizontal: 8),
              // heroTag: null,
              child:
                  // Text("📲")
                  const CustomText(text: '📲 مشاركة النتيجة', fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
