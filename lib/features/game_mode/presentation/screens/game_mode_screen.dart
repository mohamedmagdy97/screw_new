import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/helpers/firebase_notification_service.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/routing/build_fancy_route.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:screw_calculator/features/game_mode/domain/entities/game_mode_item_entity.dart';
import 'package:screw_calculator/features/game_mode/presentation/cubit/game_mode_cubit.dart';
import 'package:screw_calculator/features/home/presentation/screens/home_screen.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class GameMode extends StatefulWidget {
  const GameMode({super.key});

  @override
  State<GameMode> createState() => _GameModeState();
}

class _GameModeState extends State<GameMode> {
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerResume());
  }

  /// يعرض استكمال لعبة لم تنتهِ (حُفظت تلقائيًا) إن وُجدت.
  Future<void> _offerResume() async {
    final game = await sl<ActiveGameRepository>().load();
    if (game == null || !game.hasProgress || !mounted) return;

    final l10n = AppLocalizations.of(context);
    final resume = await showAppConfirmDialog(
      context,
      icon: Icons.history_rounded,
      title: l10n.unfinishedGameTitle,
      message: l10n.unfinishedGameBody,
      confirmText: l10n.resume,
      cancelText: l10n.startNewGame,
    );
    if (!mounted) return;
    if (resume ?? false) {
      ModeClass.mode = game.friendly
          ? GameModeEnum.friendly
          : GameModeEnum.classic;
      await Navigator.push(
        context,
        buildFancyRoute<void>(
          DashboardScreen(
            players: game.players,
            teamsMode: game.friendly,
            initialEdits: game.edits,
          ),
        ),
      );
    } else {
      await sl<ActiveGameRepository>().clear();
    }
  }

  Future<void> _initializeNotifications() async {
    await FirebaseNotificationService.init(context);
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    final DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Utilities().showCustomSnack(
        context,
        txt: AppLocalizations.of(context).pressBackAgain,
      );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameModeCubit>(),
      child: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: _onPopInvoked,
        child: const GameModeView(),
      ),
    );
  }
}

class GameModeView extends StatelessWidget {
  const GameModeView({super.key});

  void _handleSelectMode(BuildContext context, int index) {
    final cubit = context.read<GameModeCubit>();
    cubit.selectGameMode(index);

    // Update game mode enum
    if (index == 1) {
      ModeClass.mode = GameModeEnum.friendly;
    } else {
      ModeClass.mode = GameModeEnum.classic;
    }
  }

  void _handleNext(BuildContext context) {
    final cubit = context.read<GameModeCubit>();
    final selectedKey = cubit.getSelectedModeKey() ?? 0;

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 750),
        pageBuilder: (_, _, _) => HomeScreen(index: selectedKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      bottomNavigationBar: const BottomNavigationText(),
      body: Column(
        children: [
          const _HeroHeader(),
          Expanded(
            child: BlocBuilder<GameModeCubit, GameModeState>(
              builder: (context, state) {
                if (state is GameModeInitial || state is GameModeLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(strokeWidth: 4),
                  );
                }
                if (state is GameModeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: context.palette.lose,
                        ),
                        const SizedBox(height: 16),
                        CustomText(text: state.message, fontSize: 16),
                      ],
                    ),
                  );
                }
                if (state is GameModeLoaded) {
                  return Directionality(
                    textDirection: context.contentDirection,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      children: [
                        CustomText(
                          text: l10n.chooseGameMode,
                          fontSize: 18,
                          fontFamily: AppFonts.bold,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 14),
                        Hero(
                          tag:
                              'gameMode-${state.gameModes.firstWhere((e) => e.isActive).key}',
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                for (var i = 0; i < state.gameModes.length; i++)
                                  _ModeCard(
                                    gameMode: state.gameModes[i],
                                    onTap: () => _handleSelectMode(context, i),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: l10n.next,
                          onPressed: () => _handleNext(context),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ترويسة الشاشة الرئيسية: تدرّج الهوية بزوايا سفلية كبيرة، الشعار والاسم.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 28,
        24,
        30,
      ),
      decoration: BoxDecoration(
        gradient: palette.brandGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: palette.brand.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(Assets.iconsMark, width: 76, height: 76),
          ),
          const SizedBox(height: 14),
          CustomText(
            text: l10n.appName,
            fontSize: 26,
            fontFamily: AppFonts.bold,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: l10n.heroTagline,
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }
}

/// بطاقة وضع لعب: أيقونة، عنوان، وصف، ومؤشر اختيار.
class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.gameMode, required this.onTap});

  final GameModeItemEntity gameMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final selected = gameMode.isActive;
    final isClassic = gameMode.key == 0;
    final title = isClassic ? l10n.modeClassicTitle : l10n.modeFriendsTitle;
    final desc = isClassic ? l10n.modeClassicDesc : l10n.modeFriendsDesc;
    final fg = selected ? Colors.white : palette.textPrimary;
    final fgSoft = selected
        ? Colors.white.withValues(alpha: 0.85)
        : palette.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $desc',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          gradient: selected ? palette.brandGradient : null,
          color: selected ? null : palette.surface,
          border: Border.all(
            color: selected ? Colors.transparent : palette.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.brand.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: selected
                          ? Colors.white.withValues(alpha: 0.2)
                          : palette.brand.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      isClassic ? Icons.person_rounded : Icons.groups_rounded,
                      size: 30,
                      color: selected ? Colors.white : palette.brandSoft,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: title,
                          fontSize: 19,
                          fontFamily: AppFonts.bold,
                          color: fg,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: desc,
                          fontSize: 13.5,
                          color: fgSoft,
                          textAlign: TextAlign.start,
                          height: 1.4,
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(selected),
                      color: selected ? Colors.white : palette.border,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
