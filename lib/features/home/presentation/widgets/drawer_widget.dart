import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/helpers/remote_config.dart';
import 'package:screw_calculator/core/l10n/locale_cubit.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/utils/validation_form.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/custom_text_field.dart';
import 'package:screw_calculator/features/chat/presentation/screens/chat_screen.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/blocked_users_dialog.dart';
import 'package:screw_calculator/features/contact_us/presentation/screens/contact_us_screen.dart';
import 'package:screw_calculator/features/history/presentation/screens/history_screen.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/widgets/drawer_item_widget.dart';
import 'package:screw_calculator/features/home/presentation/widgets/weekly_reminder_tile.dart';
import 'package:screw_calculator/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:screw_calculator/features/prayer/presentation/screens/prayer_screen.dart';
import 'package:screw_calculator/features/rules/presentation/screens/rules_screen.dart';
import 'package:screw_calculator/features/show_video/presentation/screens/show_video_screen.dart';
import 'package:screw_calculator/features/stats/presentation/screens/stats_screen.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/screens/user_sc_sharing_screen.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final HomeController homeData = sl<HomeController>();

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
          backgroundColor: context.palette.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Image.asset(Assets.iconsIcon, height: 0.15.sh),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 10),
                          child: CustomText(
                            text: AppLocalizations.of(context).drawerGreeting,
                            fontSize: 16,
                          ),
                        ),
                        Divider(
                          endIndent: 10,
                          indent: 10,
                          height: 8,
                          color: AppColors.mainColor.withValues(alpha: 0.5),
                        ),

                        DrawerItemWidget(
                          title: AppLocalizations.of(context).prayerTimes,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const PrayerScreen(),
                          ),
                        ),
                        // DrawerItemWidget(
                        //   title: ' test مواقيت الصلاة',
                        //   onTap: () =>
                        //       homeData.routeFromDrawer(context, const RealDeviceTestPage()),
                        // ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).notifications,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const NotificationsScreen(),
                          ),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).rules,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const RulesScreen(),
                          ),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).history,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const HistoryScreen(),
                          ),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).statsMenu,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const StatsScreen(),
                          ),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).video,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const YoutubeLikePlayer(),
                          ),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).sharedResults,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const UserScSharingScreen(),
                          ),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).contactUs,
                          onTap: () => homeData.routeFromDrawer(
                            context,
                            const ContactUsScreen(),
                          ),
                        ),
                        if (RemoteConfig().canAccessChat(
                          phone: homeData.userPhone ?? '',
                          name: homeData.userName ?? '',
                        ))
                          DrawerItemWidget(
                            title: AppLocalizations.of(context).publicChat,
                            onTap: () async {
                              if (homeData.userName == null ||
                                  homeData.userPhone == null ||
                                  homeData.userCountry == null) {
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: 'Dismiss',
                                  barrierColor: Colors.black54,
                                  transitionDuration: const Duration(
                                    milliseconds: 450,
                                  ),
                                  pageBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
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
                                            text: AppLocalizations.of(
                                              context,
                                            ).enterYourData,
                                            fontSize: 16.sp,
                                          ),
                                          content: Form(
                                            key: homeData.formKeyUserData,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomTextField(
                                                  controller:
                                                      homeData.nameController,
                                                  hintText: AppLocalizations.of(
                                                    context,
                                                  ).firstNameHint,
                                                  labelText:
                                                      AppLocalizations.of(
                                                        context,
                                                      ).nameLabel,
                                                  containtPaddingRight: 0,
                                                  inputType: TextInputType.text,
                                                  textFieldVaidType:
                                                      TextFieldValidatorType
                                                          .name,
                                                ),
                                                CustomTextField(
                                                  controller:
                                                      homeData.phoneController,
                                                  hintText: '01*********',
                                                  labelText:
                                                      AppLocalizations.of(
                                                        context,
                                                      ).phoneLabel,
                                                  containtPaddingRight: 0,
                                                  inputType:
                                                      TextInputType.phone,
                                                  textFieldVaidType:
                                                      TextFieldValidatorType
                                                          .phoneNumber,
                                                ),
                                                CustomTextField(
                                                  controller: homeData
                                                      .countryController,
                                                  hintText: AppLocalizations.of(
                                                    context,
                                                  ).cityHint,
                                                  labelText:
                                                      AppLocalizations.of(
                                                        context,
                                                      ).cityLabel,
                                                  containtPaddingRight: 0,
                                                  inputType: TextInputType.text,
                                                  textFieldVaidType:
                                                      TextFieldValidatorType
                                                          .displayText,
                                                ),

                                                CustomTextField(
                                                  controller:
                                                      homeData.ageController,
                                                  hintText: AppLocalizations.of(
                                                    context,
                                                  ).ageHint,
                                                  labelText:
                                                      AppLocalizations.of(
                                                        context,
                                                      ).ageLabel,
                                                  containtPaddingRight: 0,
                                                  inputType:
                                                      TextInputType.number,
                                                  textFieldVaidType:
                                                      TextFieldValidatorType
                                                          .number,
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            CustomButton(
                                              text: AppLocalizations.of(
                                                context,
                                              ).next,
                                              onPressed: () async {
                                                if (!homeData
                                                    .formKeyUserData
                                                    .currentState!
                                                    .validate()) {
                                                  return;
                                                }

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
                                                final age = homeData
                                                    .ageController
                                                    .text
                                                    .trim();

                                                final result = await homeData
                                                    .validateUser(
                                                      name: name,
                                                      phone: phone,
                                                      country: country,
                                                      age: age,
                                                    );

                                                if (!context.mounted) return;
                                                switch (result) {
                                                  case UserValidationResult
                                                      .notExists:
                                                    await homeData
                                                        .addUserDataToDB();
                                                    if (!context.mounted ||
                                                        !ctx.mounted) {
                                                      return;
                                                    }
                                                    Navigator.pop(ctx);
                                                    homeData.routeFromDrawer(
                                                      context,
                                                      const ChatScreen(),
                                                      // const ChatScreen2(),
                                                    );
                                                    break;

                                                  case UserValidationResult
                                                      .existsAndValidOwner:
                                                    await homeData
                                                        .addUserDataToDB();
                                                    if (!context.mounted ||
                                                        !ctx.mounted) {
                                                      return;
                                                    }

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
                                                      backgroundColor:
                                                          AppColors.red,
                                                      topPosition: true,
                                                      txt: AppLocalizations.of(
                                                        context,
                                                      ).userExistsInvalidCity,
                                                    );
                                                  case UserValidationResult
                                                      .existsNumber:
                                                    Utilities().showCustomSnack(
                                                      context,
                                                      backgroundColor:
                                                          AppColors.red,
                                                      topPosition: true,
                                                      txt: AppLocalizations.of(
                                                        context,
                                                      ).userExistsPhone,
                                                    );

                                                    break;
                                                  case UserValidationResult
                                                      .existsName:
                                                    Utilities().showCustomSnack(
                                                      context,
                                                      backgroundColor:
                                                          AppColors.red,
                                                      topPosition: true,
                                                      txt: AppLocalizations.of(
                                                        context,
                                                      ).userExistsName,
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
                                final canEnter = await homeData
                                    .canUserEnterChat(
                                      phone: homeData.userPhone!,
                                      name: homeData.userName!,
                                    );

                                if (!context.mounted) return;
                                if (!canEnter /*&& RemoteConfig().canAccessChat(
                          phone: homeData.userPhone!,
                          name: homeData.userName!,
                        )*/ ) {
                                  return showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: CustomText(
                                        text: AppLocalizations.of(
                                          context,
                                        ).chatUnavailableTitle,
                                        fontSize: 16,
                                        fontFamily: AppFonts.bold,
                                      ),
                                      content: CustomText(
                                        text: AppLocalizations.of(
                                          context,
                                        ).chatUnavailableBody,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }
                                homeData.routeFromDrawer(
                                  context,
                                  const ChatScreen(),
                                );
                                // homeData.routeFromDrawer(context, const ChatScreen2());
                              }
                            },
                          ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).blockedUsers,
                          onTap: () => showBlockedUsersDialog(context),
                        ),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).rateUs,
                          onTap: homeData.rateMyApp,
                        ),
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, mode) => DrawerItemWidget(
                            title: mode == ThemeMode.dark
                                ? AppLocalizations.of(context).lightMode
                                : AppLocalizations.of(context).darkMode,
                            onTap: () => context.read<ThemeCubit>().toggle(),
                          ),
                        ),
                        const WeeklyReminderTile(),
                        DrawerItemWidget(
                          title: AppLocalizations.of(context).language,
                          onTap: () => context.read<LocaleCubit>().toggle(),
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
                                  _AppVersionText(),
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
            ),
          ),
        ),
      ),
    );
  }
}

/// يعرض رقم إصدار التطبيق الفعلي من `pubspec` بدل قيمة ثابتة.
class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final label = info == null ? '' : 'v${info.version}';
        return CustomText(text: label, fontSize: 13);
      },
    );
  }
}
