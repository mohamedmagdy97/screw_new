import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/text_filed_custom.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/helpers/device_info.dart';
import 'package:screw_calculator/screens/chat/chat_sc_with_local_old_chats.dart' as oldChat;
import 'package:screw_calculator/screens/chat/chat_screen.dart';
import 'package:screw_calculator/screens/chat/chat_screen_lazy_load.dart' as lazy;
import 'package:screw_calculator/screens/chat/chat_screen_lazy_load_high.dart' as lazyHigh;
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
import 'package:screw_calculator/utility/validation_form.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
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
                  padding: const EdgeInsets.only(top: 20),
                  child: Image.asset(Assets.iconsIcon, height: 0.15.sh),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20, top: 10),
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
                  onTap: () => homeData.routeFromDrawer(
                    context,
                    const UserScSharingScreen(),
                  ),
                ),
                DrawerItemWidget(
                  title: 'للاقتراحات والتواصل معنا',
                  onTap: () =>
                      homeData.routeFromDrawer(context, const ContactUS()),
                ),
                DrawerItemWidget(
                  title: 'محادثة عامة',
                  onTap: () async {
                    if (homeData.userName == null ||
                        homeData.userPhone == null ||
                        homeData.userCountry == null) {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: 'Dismiss',
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 450),
                        pageBuilder: (_, _, _) => const SizedBox.shrink(),
                        transitionBuilder: (ctx, anim, _, child) {
                          return SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: Opacity(
                              opacity: anim.value,
                              child: AlertDialog(
                                title: CustomText(
                                  text: 'ادخل بياناتك',
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                                content: Form(
                                  key: homeData.formKeyUserData,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomTextField(
                                        controller: homeData.nameController,
                                        hintText: 'الاسم الاول',
                                        labelText: 'الاسم',
                                        hintColor: AppColors.black,
                                        fillColor: AppColors.white,
                                        textColor: AppColors.black,
                                        containtPaddingRight: 0,
                                        inputType: TextInputType.text,
                                        textFieldVaidType:
                                            TextFieldValidatorType.name,
                                      ),
                                      CustomTextField(
                                        controller: homeData.phoneController,
                                        hintText: '01*********',
                                        labelText: 'رقم الموبايل',
                                        hintColor: AppColors.black,
                                        fillColor: AppColors.white,
                                        textColor: AppColors.black,
                                        containtPaddingRight: 0,
                                        inputType: TextInputType.phone,
                                        textFieldVaidType:
                                            TextFieldValidatorType.phoneNumber,
                                      ),
                                      CustomTextField(
                                        controller: homeData.countryController,
                                        hintText: 'اسم المدينة أو المحافظة',
                                        labelText: 'المدينة',
                                        hintColor: AppColors.black,
                                        fillColor: AppColors.white,
                                        textColor: AppColors.black,
                                        containtPaddingRight: 0,
                                        inputType: TextInputType.text,
                                        textFieldVaidType:
                                            TextFieldValidatorType.displayText,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  CustomButton(
                                    text: ' التالي',
                                    onPressed: () {
                                      if (!homeData
                                          .formKeyUserData
                                          .currentState!
                                          .validate()) {
                                        return;
                                      }
                                      if (homeData
                                              .nameController
                                              .text
                                              .isNotEmpty &&
                                          homeData
                                              .phoneController
                                              .text
                                              .isNotEmpty &&
                                          homeData
                                              .countryController
                                              .text
                                              .isNotEmpty) {
                                        homeData.addUserDataToDB();
                                        Navigator.pop(ctx);
                                        homeData.routeFromDrawer(
                                          context,
                                          lazyHigh. ChatPage(),
                                          // ChatScreen(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      // showDialog(
                      //   context: context,
                      //   barrierDismissible: false,
                      //   builder: (_) => AlertDialog(
                      //     title: Text('Enter Your Info'),
                      //     content: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         TextField(
                      //           controller: homeData.nameController,
                      //           decoration: InputDecoration(hintText: 'Name'),
                      //         ),
                      //         TextField(
                      //           controller: homeData.phoneController,
                      //           decoration: InputDecoration(hintText: 'Phone'),
                      //         ),
                      //         TextField(
                      //           controller: homeData.countryController,
                      //           decoration: InputDecoration(
                      //             hintText: 'Country',
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     actions: [
                      //       TextButton(
                      //         onPressed: () async {
                      //            if (homeData.nameController.text.isNotEmpty &&
                      //               homeData.phoneController.text.isNotEmpty &&
                      //               homeData
                      //                   .countryController
                      //                   .text
                      //                   .isNotEmpty) {
                      //             homeData.addUserDataToDB();
                      //             Navigator.pop(context);
                      //              homeData.routeFromDrawer(
                      //               context,
                      //               ChatScreen(),
                      //             );
                      //           }
                      //         },
                      //         child: Text('Save'),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    } else {
                      homeData.routeFromDrawer(context, oldChat.ChatPage());
                    }
                    // =>
                    //     homeData.routeFromDrawer(context, ChatScreen())
                  },
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
                          CustomText(text: 'v3.0', fontSize: 13),
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
