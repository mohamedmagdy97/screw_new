import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/routing/fade_animation.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/player_scores_row.dart';
import 'package:screw_calculator/generated/assets.dart';

/// بطاقة لاعب في الوضع الكلاسيكي: صورة رمزية بالحرف الأول، الاسم مع تاج
/// الفائز، ثم صف النتائج والمجموع. الفائز أخضر والخاسر وردي.
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
    final palette = context.palette;
    final bool isWinner = winnerTotal?.toString() == player.total;
    final bool isLoser = loserTotal?.toString() == player.total;
    final bool decided = winnerTotal != loserTotal;

    final Color accent = isWinner && decided
        ? palette.win
        : isLoser && decided
        ? palette.lose
        : palette.brand;
    final Color bgColor = isWinner && decided
        ? palette.win.withValues(alpha: 0.12)
        : isLoser && decided
        ? palette.lose.withValues(alpha: 0.10)
        : palette.surface;
    final Color borderColor = isWinner && decided
        ? palette.win
        : isLoser && decided
        ? palette.lose
        : palette.border;
    final name = player.name?.toString() ?? '';
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first;

    return FadeSlide(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: borderColor,
              width: isWinner && decided ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.18),
                    ),
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: accent,
                        fontSize: 18,
                        fontFamily: AppFonts.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomText(
                      text: name,
                      fontSize: 19.sp,
                      fontFamily: AppFonts.bold,
                      height: 1.1,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  if (isWinner && decided)
                    const Image(
                      image: AssetImage(Assets.kingIcon),
                      height: 24,
                      width: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              PlayerScoresRow(cubit: cubit, player: player),
            ],
          ),
        ),
      ),
    );
  }
}
