import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/features/game_mode/domain/entities/game_mode_item_entity.dart';
import 'package:screw_calculator/features/game_mode/presentation/cubit/game_mode_cubit.dart';
import 'package:screw_calculator/helpers/firebase_notification_service.dart';
import 'package:screw_calculator/screens/home/home.dart';
import 'package:screw_calculator/utility/Enums.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/utilities.dart';

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
  }

  Future<void> _initializeNotifications() async {
    await FirebaseNotificationService.init(context);
  }

  Future<bool> _onWillPop() {
    final DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Utilities().showCustomSnack(context, txt: 'للخروج اضغط مرتين ');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameModeCubit(),
      child: WillPopScope(onWillPop: _onWillPop, child: const _GameModeView()),
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
        pageBuilder: (_, __, ___) => MyHomePage(index: selectedKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'سكرو حاسبة', fontSize: 22.sp),
      ),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<GameModeCubit, GameModeState>(
        builder: (context, state) {
          if (state is GameModeInitial || state is GameModeLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 4,
                backgroundColor: AppColors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
              ),
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
                  text: 'اختر وضع اللعبة',
                  fontSize: 16.sp,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
                      text: 'التالي',
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
              ? [Colors.purple.shade600, Colors.purple.shade800]
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
                  color: AppColors.mainColor.withOpacity(.3),
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
            child: CustomText(text: gameMode.value, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
