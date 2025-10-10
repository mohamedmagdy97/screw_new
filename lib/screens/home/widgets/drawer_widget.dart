import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/build_fancy_route.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/screens/contact_us/contact_us.dart';
import 'package:screw_calculator/screens/history/history.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/screens/notifications/notifications_screen.dart';
import 'package:screw_calculator/screens/rules/rules_screen.dart';
import 'package:screw_calculator/screens/show_video/show_video_youtube.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.7.sw,
      padding: EdgeInsets.only(top: 55.h, bottom: 54.h),
      child: SafeArea(
        child: Drawer(
          backgroundColor: AppColors.drawerBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Image.asset(Assets.iconsIcon, height: 0.15.sh),

                  // Icon(Icons.gavel_sharp,
                  //     size: 50, color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: CustomText(text: 'آهلا بيك يا صديقي', fontSize: 16),
                ),
                Divider(
                  endIndent: 10,
                  indent: 10,
                  height: 8,
                  color: AppColors.mainColor.withValues(alpha: 0.5),
                ),
                ListTile(
                  minTileHeight: 0,
                  onTap: () =>
                      routeFromDrawer(context, const NotificationsScreen()),
                  title: const CustomText(
                    text: 'الاشعارات ',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Divider(height: 2, color: AppColors.opacity_1),

                ListTile(
                  minTileHeight: 0,

                  onTap: () => routeFromDrawer(context, const RulesScreen()),
                  title: const CustomText(
                    text: 'قوانين اللعبة',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Divider(height: 2, color: AppColors.opacity_1),

                ListTile(
                  minTileHeight: 0,

                  onTap: () => routeFromDrawer(context, const HistoryScreen()),
                  title: const CustomText(
                    text: 'الجولات السابقة',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Divider(height: 2, color: AppColors.opacity_1),

                ListTile(
                  minTileHeight: 0,
                  onTap: () =>
                      routeFromDrawer(context, const YoutubeLikePlayer()),
                  title: const CustomText(
                    text: 'فيديو شرح اللعبة',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Divider(height: 2, color: AppColors.opacity_1),

                ListTile(
                  minTileHeight: 0,
                  onTap: () => routeFromDrawer(context, const ContactUS()),
                  title: const CustomText(
                    text: 'للاقتراحات والتواصل معنا ',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Divider(height: 2, color: AppColors.opacity_1),
                ListTile(
                  minTileHeight: 0,
                  onTap: () => homeData.rateMyApp(),
                  title: const CustomText(
                    text: '⭐ قيمنا',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Divider(height: 2, color: AppColors.opacity_1),

                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomText(text: '© ', fontSize: 16),
                          CustomText(text: 'MegTech', fontSize: 14),
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(text: 'version - ', fontSize: 16),
                          CustomText(text: 'v2.1', fontSize: 13),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void routeFromDrawer(BuildContext context, Widget widget) async {
  Navigator.of(context).pop();
  await Future.delayed(const Duration(milliseconds: 250));

  Navigator.of(context).push(buildFancyRoute(widget));
}
