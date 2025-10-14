import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/screens/contact_us/contact_us.dart';
import 'package:screw_calculator/screens/history/history.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/screens/home/widgets/drawer_item_widget.dart';
import 'package:screw_calculator/screens/notifications/notifications_screen.dart';
import 'package:screw_calculator/screens/prayer/screen/prayer_screen.dart';
import 'package:screw_calculator/screens/rules/rules_screen.dart';
import 'package:screw_calculator/screens/show_video/show_video_youtube.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/user_sc_sharing_screen.dart';
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

                DrawerItemWidget(
                  title: 'مواقيت الصلاة',
                  onTap: () =>
                      homeData.routeFromDrawer(context, const PrayerScreen()),
                ),
                DrawerItemWidget(
                  title: 'الاشعارات',
                  onTap: () => homeData.routeFromDrawer(
                    context,
                    const NotificationsScreen(),
                  ),
                ),
                DrawerItemWidget(
                  title: 'قوانين اللعبة',
                  onTap: () =>
                      homeData.routeFromDrawer(context, const RulesScreen()),
                ),
                DrawerItemWidget(
                  title: 'الجولات السابقة',
                  onTap: () =>
                      homeData.routeFromDrawer(context, const HistoryScreen()),
                ),
                DrawerItemWidget(
                  title: 'فيديو شرح اللعبة',
                  onTap: () => homeData.routeFromDrawer(
                    context,
                    const YoutubeLikePlayer(),
                  ),
                ),
                DrawerItemWidget(
                  title: 'مشاركات نتائج الاخرين',
                  onTap: () =>
                      homeData.routeFromDrawer(context, const UserScSharingScreen()),
                ),
                DrawerItemWidget(
                  title: 'للاقتراحات والتواصل معنا',
                  onTap: () =>
                      homeData.routeFromDrawer(context, const ContactUS()),
                ),
                DrawerItemWidget(
                  title: '⭐ قيمنا',
                  onTap: () => homeData.rateMyApp(),
                ),

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
                          CustomText(text: 'v2.2', fontSize: 13),
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
