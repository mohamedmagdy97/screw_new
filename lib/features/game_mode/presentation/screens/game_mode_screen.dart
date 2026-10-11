import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/helpers/firebase_notification_service.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/routing/build_fancy_route.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/active_game_repository.dart';
import 'package:screw_calculator/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:screw_calculator/features/game_mode/domain/entities/game_mode_item_entity.dart';
import 'package:screw_calculator/features/game_mode/presentation/cubit/game_mode_cubit.dart';
import 'package:screw_calculator/features/home/presentation/screens/home_screen.dart';
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

    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: CustomText(
          text: AppLocalizations.of(ctx).unfinishedGameTitle,
          fontSize: 18,
          textAlign: TextAlign.center,
        ),
        content: CustomText(
          text: AppLocalizations.of(ctx).unfinishedGameBody,
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).startNewGame),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx).resume),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (resume ?? false) {
      ModeClass.mode = game.friendly
          ? GameModeEnum.friendly
          : GameModeEnum.classic;
      await Navigator.push(
        context,
        buildFancyRoute<void>(
          DashboardScreen(players: game.players, teamsMode: game.friendly),
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
        child: const _GameModeView(),
      ),
    );
  }
}

class _GameModeView extends StatelessWidget {
  const _GameModeView();

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: CustomText(
          text: AppLocalizations.of(context).appName,
          fontSize: 22.sp,
        ),
      ),
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<GameModeCubit, GameModeState>(
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  CustomText(text: state.message, fontSize: 16),
                ],
              ),
            );
          }

          if (state is GameModeLoaded) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                CustomText(
                  text: AppLocalizations.of(context).chooseGameMode,
                  fontSize: 16.sp,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: context.readStartCross,
                  children: [
                    SingleChildScrollView(
                      child: Hero(
                        tag:
                            'gameMode-${state.gameModes.firstWhere((e) => e.isActive).key}',
                        child: Material(
                          color: Colors.transparent,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: 1,
                            child: Column(
                              children: List.generate(
                                state.gameModes.length,
                                (index) => _buildGameModeItem(
                                  context,
                                  state.gameModes[index],
                                  index,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    CustomButton(
                      text: AppLocalizations.of(context).next,
                      onPressed: () => _handleNext(context),
                    ),
                  ],
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGameModeItem(
    BuildContext context,
    GameModeItemEntity gameMode,
    int index,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 120.h,
      width: 1.sw,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: gameMode.isActive
              ? [
                  context.palette.brand,
                  context.palette.brand.withValues(alpha: 0.82),
                ]
              : [Colors.transparent, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gameMode.isActive ? Colors.transparent : AppColors.mainColor,
        ),
        boxShadow: gameMode.isActive
            ? [
                BoxShadow(
                  color: AppColors.mainColor.withValues(alpha: .3),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleSelectMode(context, index),
        child: Center(
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.normal,
              color: gameMode.isActive ? Colors.white : AppColors.black,
            ),
            duration: const Duration(milliseconds: 300),
            child: CustomText(
              text: gameMode.key == 0
                  ? AppLocalizations.of(context).modeClassic
                  : AppLocalizations.of(context).modeFriends,
              fontSize: 22,
              color: gameMode.isActive ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}
