import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/models/team_model_new.dart';
import 'package:screw_calculator/core/routing/fade_animation.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/player_scores_row.dart';

/// بطاقة فريق في وضع الفرق: لاعبان ومجموع الفريق مع إبراز الفريق الفائز.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.cubit,
    required this.team,
    required this.isWinning,
  });

  final DashboardCubit cubit;
  final Team team;
  final bool isWinning;

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isWinning ? AppColors.mainColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.grayy),
        ),
        child: Column(
          children: [
            CustomText(
              text: team.name,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            _TeamPlayerRow(cubit: cubit, name: team.playerOne.name, player: team.playerOne),
            _TeamPlayerRow(cubit: cubit, name: team.playerTwo.name, player: team.playerTwo),
            const Divider(),
            CustomText(
              text: 'المجموع: ${team.totalScore}',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamPlayerRow extends StatelessWidget {
  const _TeamPlayerRow({
    required this.cubit,
    required this.name,
    required this.player,
  });

  final DashboardCubit cubit;
  final String? name;
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(text: '${name ?? ''} | ', fontSize: 16.sp),
        Expanded(child: PlayerScoresRow(cubit: cubit, player: player)),
      ],
    );
  }
}
