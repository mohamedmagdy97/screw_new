import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/build_fancy_route.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/contact_us/contact_us.dart';
import 'package:screw_calculator/screens/history/history.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/screens/rules/rules_screen.dart';
import 'package:screw_calculator/screens/show_video/show_video_youtube.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.7.sw,
      padding: EdgeInsets.only(top: 60.h, bottom: 54.h),
      child: SafeArea(
        child: Drawer(
          backgroundColor: AppColors.opacity_1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Image.asset('assets/icons/icon.png', height: 0.15.sh),

                  // Icon(Icons.gavel_sharp,
                  //     size: 50, color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: CustomText(text: 'آهلا بيك يا صديقي', fontSize: 16),
                ),
                const Divider(endIndent: 10, indent: 10),
                ListTile(
                  onTap: () => routeFromDrawer(context, const HistoryScreen()),
                  title: const CustomText(
                    text: 'الجولات السابقة',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                ListTile(
                  onTap: () => routeFromDrawer(context, const RulesScreen()),
                  title: const CustomText(
                    text: 'قوانين اللعبة',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                ListTile(
                  onTap: () => routeFromDrawer(context, const YoutubeLikePlayer()),
                  title: const CustomText(
                    text: 'فيديو شرح اللعبة',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                ListTile(
                  onTap: () => routeFromDrawer(context, const ContactUS()),
                  title: const CustomText(
                    text: 'للاقتراحات والتواصل معنا ',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),
                ListTile(
                  onTap: () => homeData.rateMyApp(),
                  title: const CustomText(
                    text: '⭐ قيمنا',
                    fontSize: 16,
                    textAlign: TextAlign.end,
                  ),
                ),

                const Spacer(),
                const CustomText(text: 'version 1.0.6', fontSize: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void routeFromDrawer(BuildContext context, Widget widget) async {
  Navigator.of(context).pop(); // close drawer first
  await Future.delayed(const Duration(milliseconds: 250));

  Navigator.of(context).push(buildFancyRoute(widget));
}
