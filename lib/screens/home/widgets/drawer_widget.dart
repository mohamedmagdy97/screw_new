import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/text_filed_custom.dart';
import 'package:screw_calculator/features/contact_us/contact_us.dart';
import 'package:screw_calculator/features/prayer/screen/prayer_screen.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/helpers/remote_config.dart';
import 'package:screw_calculator/screens/chat/chat_screen.dart';
import 'package:screw_calculator/screens/history/history.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/screens/home/widgets/drawer_item_widget.dart';
import 'package:screw_calculator/screens/notifications/notifications_screen.dart';
import 'package:screw_calculator/screens/rules/rules_screen.dart';
import 'package:screw_calculator/screens/show_video/show_video_youtube.dart';
import 'package:screw_calculator/screens/users_screenshoot_sharing/user_sc_sharing_screen.dart';
import 'package:screw_calculator/utility/Enums.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/utilities.dart';
import 'package:screw_calculator/utility/validation_form.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    RemoteConfig().getConfig();
    super.initState();
  }

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
                // DrawerItemWidget(
                //   title: ' test مواقيت الصلاة',
                //   onTap: () =>
                //       homeData.routeFromDrawer(context, const RealDeviceTestPage()),
                // ),
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
                      homeData.routeFromDrawer(context, const ContactUsScreen()),
                ),
                if (RemoteConfig().canAccessChat(
                  phone: homeData.userPhone ?? '',
                  name: homeData.userName ?? '',
                ))
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
                                              TextFieldValidatorType
                                                  .phoneNumber,
                                        ),
                                        CustomTextField(
                                          controller:
                                              homeData.countryController,
                                          hintText: 'اسم المدينة أو المحافظة',
                                          labelText: 'المدينة',
                                          hintColor: AppColors.black,
                                          fillColor: AppColors.white,
                                          textColor: AppColors.black,
                                          containtPaddingRight: 0,
                                          inputType: TextInputType.text,
                                          textFieldVaidType:
                                              TextFieldValidatorType
                                                  .displayText,
                                        ),

                                        CustomTextField(
                                          controller: homeData.ageController,
                                          hintText: 'عندك كام سنة',
                                          labelText: 'العمر',
                                          hintColor: AppColors.black,
                                          fillColor: AppColors.white,
                                          textColor: AppColors.black,
                                          containtPaddingRight: 0,
                                          inputType: TextInputType.number,
                                          textFieldVaidType:
                                              TextFieldValidatorType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    CustomButton(
                                      text: ' التالي',
                                      onPressed: () async {
                                        if (!homeData
                                            .formKeyUserData
                                            .currentState!
                                            .validate())
                                          return;

                                        final name = homeData
                                            .nameController
                                            .text
                                            .trim();
                                        final phone = homeData
                                            .phoneController
                                            .text
                                            .trim();
                                        final country = homeData
                                            .countryController
                                            .text
                                            .trim();
                                        final age = homeData.ageController.text
                                            .trim();

                                        final result = await homeData
                                            .validateUser(
                                              name: name,
                                              phone: phone,
                                              country: country,
                                              age: age,
                                            );

                                        switch (result) {
                                          case UserValidationResult.notExists:
                                            await homeData.addUserDataToDB();
                                            Navigator.pop(ctx);
                                            homeData.routeFromDrawer(
                                              context,
                                              const ChatScreen(),
                                              // const ChatScreen2(),
                                            );
                                            break;

                                          case UserValidationResult
                                              .existsAndValidOwner:
                                            await homeData.addUserDataToDB();

                                            Navigator.pop(ctx);
                                            homeData.routeFromDrawer(
                                              context,
                                              const ChatScreen(),
                                              // const ChatScreen2(),
                                            );
                                            break;

                                          case UserValidationResult
                                              .existsButInvalidCountry:
                                            Utilities().showCustomSnack(
                                              context,
                                              backgroundColor: AppColors.red,
                                              topPosition: true,
                                              txt:
                                                  'هذه البيانات مسجلة بالفعل، يرجى إدخال المدينة كما كانت مسجلة سابقًا',
                                            );
                                          case UserValidationResult
                                              .existsNumber:
                                            Utilities().showCustomSnack(
                                              context,
                                              backgroundColor: AppColors.red,
                                              topPosition: true,
                                              txt:
                                                  'رقم الهاتف مسجل بالفعل، يرجى إدخال الأسم والمدينة كما كانت مسجلة سابقًا',
                                            );

                                            break;
                                          case UserValidationResult.existsName:
                                            Utilities().showCustomSnack(
                                              context,
                                              backgroundColor: AppColors.red,
                                              topPosition: true,
                                              txt:
                                                  'الاسم مسجل بالفعل، يرجى إدخال رقم الهاتف والمدينة لو كانت مسجلة مسبقًا او ادخل اسم اخر',
                                            );

                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        final canEnter = await homeData.canUserEnterChat(
                          phone: homeData.userPhone!,
                          name: homeData.userName!,
                        );

                        if (!canEnter /*&& RemoteConfig().canAccessChat(
                          phone: homeData.userPhone!,
                          name: homeData.userName!,
                        )*/ ) {
                          return showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: CustomText(
                                text: 'غير متاح',
                                fontSize: 16,
                                color: AppColors.black,
                                fontFamily: AppFonts.bold,
                              ),
                              content: CustomText(
                                text: 'الدخول للشات غير متاح حاليًا',
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }
                        homeData.routeFromDrawer(context, const ChatScreen());
                        // homeData.routeFromDrawer(context, const ChatScreen2());
                      }
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
