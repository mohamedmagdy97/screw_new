import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/helpers/remote_config.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/l10n/locale_cubit.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/theme/theme_cubit.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/blocked_users_dialog.dart';
import 'package:screw_calculator/features/contact_us/presentation/screens/contact_us_screen.dart';
import 'package:screw_calculator/features/history/presentation/screens/history_screen.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/widgets/chat_entry_flow.dart';
import 'package:screw_calculator/features/home/presentation/widgets/drawer_tile.dart';
import 'package:screw_calculator/features/home/presentation/widgets/weekly_reminder_tile.dart';
import 'package:screw_calculator/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:screw_calculator/features/prayer/presentation/screens/prayer_screen.dart';
import 'package:screw_calculator/features/rules/presentation/screens/rules_screen.dart';
import 'package:screw_calculator/features/show_video/presentation/screens/show_video_screen.dart';
import 'package:screw_calculator/features/stats/presentation/screens/stats_screen.dart';
import 'package:screw_calculator/features/tournament/presentation/screens/tournament_screen.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/screens/user_sc_sharing_screen.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// القائمة الجانبية الحديثة: هيدر متدرّج بالشعار وتبديل المظهر/اللغة، أقسام
/// بعناصر مصحوبة بأيقونات، وتذييل بالإصدار.
class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final HomeController homeData = sl<HomeController>();

  @override
  void initState() {
    try {
      RemoteConfig().getConfig();
    } catch (_) {
      // لا تُفشل القائمة لو تعذّر تحميل الإعدادات البعيدة.
    }
    super.initState();
  }

  /// هل يُعرض الشات؟ يعود `false` لو تعذّرت قراءة الإعدادات البعيدة.
  bool _chatAllowed() {
    try {
      return RemoteConfig().canAccessChat(
        phone: homeData.userPhone ?? '',
        name: homeData.userName ?? '',
      );
    } catch (_) {
      return false;
    }
  }

  void _go(Widget screen) => homeData.routeFromDrawer(context, screen);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final width = math.min(0.84.sw, 360.0);

    return Drawer(
      width: width,
      backgroundColor: palette.screen,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Directionality(
        textDirection: context.contentDirection,
        child: Column(
          children: [
            const _DrawerHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  DrawerSectionLabel(l10n.drawerSectionPlay),
                  DrawerTile(
                    icon: Icons.menu_book_rounded,
                    title: l10n.rules,
                    onTap: () => _go(const RulesScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.history_rounded,
                    title: l10n.history,
                    color: palette.accent,
                    onTap: () => _go(const HistoryScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.bar_chart_rounded,
                    title: l10n.statsMenu,
                    color: palette.win,
                    onTap: () => _go(const StatsScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.emoji_events_rounded,
                    title: l10n.tournamentMenu,
                    color: const Color(0xFFF59E0B),
                    onTap: () => _go(const TournamentScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.play_circle_rounded,
                    title: l10n.video,
                    color: palette.lose,
                    onTap: () => _go(const YoutubeLikePlayer()),
                  ),

                  DrawerSectionLabel(l10n.drawerSectionCommunity),
                  if (_chatAllowed())
                    DrawerTile(
                      icon: Icons.forum_rounded,
                      title: l10n.publicChat,
                      onTap: () => openPublicChat(context, homeData),
                    ),
                  DrawerTile(
                    icon: Icons.photo_library_rounded,
                    title: l10n.sharedResults,
                    color: palette.accent,
                    onTap: () => _go(const UserScSharingScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.support_agent_rounded,
                    title: l10n.contactUs,
                    color: palette.win,
                    onTap: () => _go(const ContactUsScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.group_add_rounded,
                    title: l10n.inviteFriend,
                    color: const Color(0xFFF59E0B),
                    onTap: () => SharePlus.instance.share(
                      ShareParams(text: l10n.inviteText(AppLinks.playStore)),
                    ),
                  ),
                  DrawerTile(
                    icon: Icons.star_rounded,
                    title: l10n.rateUs,
                    color: const Color(0xFFF59E0B),
                    onTap: homeData.rateMyApp,
                  ),

                  DrawerSectionLabel(l10n.drawerSectionTools),
                  DrawerTile(
                    icon: Icons.mosque_rounded,
                    title: l10n.prayerTimes,
                    onTap: () => _go(const PrayerScreen()),
                  ),
                  DrawerTile(
                    icon: Icons.notifications_rounded,
                    title: l10n.notifications,
                    color: palette.accent,
                    onTap: () => _go(const NotificationsScreen()),
                  ),

                  DrawerSectionLabel(l10n.drawerSectionSettings),
                  const WeeklyReminderTile(),
                  DrawerTile(
                    icon: Icons.block_rounded,
                    title: l10n.blockedUsers,
                    color: palette.lose,
                    onTap: () => showBlockedUsersDialog(context),
                  ),
                ],
              ),
            ),
            const _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: palette.brandGradient,
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(28),
          bottomEnd: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(Assets.iconsMark, width: 58, height: 58),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: context.readStartCross,
              children: [
                CustomText(
                  text: l10n.appName,
                  fontSize: 20,
                  fontFamily: AppFonts.bold,
                  color: Colors.white,
                  textAlign: context.readStart,
                  height: 1.2,
                ),
                const SizedBox(height: 6),
                const _VersionChip(),
              ],
            ),
          ),
          _HeaderAction(
            tooltip: l10n.toggleThemeTooltip,
            onTap: () => context.read<ThemeCubit>().toggle(),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          _HeaderAction(
            tooltip: l10n.toggleLanguageTooltip,
            onTap: () => context.read<LocaleCubit>().toggle(),
            child: Text(
              context.isArabicLocale ? 'EN' : 'ع',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: AppFonts.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// شارة رقم الإصدار الفعلي من `pubspec`.
class _VersionChip extends StatelessWidget {
  const _VersionChip();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox(height: 22);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            'v${info.version}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: AppFonts.regular,
            ),
          ),
        );
      },
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: CustomText(
        text: '© MegTech',
        fontSize: 13,
        color: context.palette.textSecondary,
      ),
    );
  }
}
