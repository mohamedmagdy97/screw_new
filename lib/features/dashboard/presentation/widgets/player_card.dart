import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/routing/fade_animation.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/player_scores_row.dart';
import 'package:screw_calculator/generated/assets.dart';

/// بطاقة لاعب في الوضع الكلاسيكي تعرض اسمه ونتائجه ومجموعه.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.cubit,
    required this.player,
    required this.winnerTotal,
    required this.loserTotal,
  });

  final DashboardCubit cubit;
  final PlayerModel player;
  final int? winnerTotal;
  final int? loserTotal;

  @override
  Widget build(BuildContext context) {
    final bool isWinner = winnerTotal?.toString() == player.total;
    final bool isLoser = loserTotal?.toString() == player.total;

    final Color? bgColor = isWinner
        ? AppColors.green.withValues(alpha: 0.75)
        : isLoser
        ? AppColors.red.withValues(alpha: 0.75)
        : null;

    return FadeSlide(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.grayy),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: player.name.toString(),
                      fontSize: 20.sp,
                      height: 1,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  if (isWinner)
                    const Image(
                      image: AssetImage(Assets.kingIcon),
                      height: 20,
                      width: 20,
                    ),
                ],
              ),
              const SizedBox(
                width: 20,
                height: 2,
                child: Divider(color: AppColors.white),
              ),
              const SizedBox(height: 4),
              PlayerScoresRow(cubit: cubit, player: player),
            ],
          ),
        ),
      ),
    );
  }
}
