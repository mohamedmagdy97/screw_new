import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/score_input_dialog.dart';

/// صف يعرض نتائج جولات اللاعب الخمس مع أزرار الإضافة/التعديل والمجموع.
class PlayerScoresRow extends StatelessWidget {
  const PlayerScoresRow({super.key, required this.cubit, required this.player});

  final DashboardCubit cubit;
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final score = player.getRoundScore(i + 1);
          if (score.isEmpty) return const SizedBox();
          return CustomText(
            text: i == 0 ? ' $score' : ' + $score',
            fontSize: 20.sp,
          );
        }),
        if (player.gw5!.isEmpty) _ActionButtons(cubit: cubit, player: player),
        const Spacer(),
        CustomText(text: '=', fontSize: 20.sp),
        CustomText(text: ' ${player.total} ', fontSize: 20.sp),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.cubit, required this.player});

  final DashboardCubit cubit;
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (player.gw1!.isNotEmpty)
          _IconAction(
            icon: Icons.edit,
            size: 22,
            onTap: () => showScoreInputDialog(
              context: context,
              cubit: cubit,
              player: player,
              isEdit: true,
            ),
          ),
        _IconAction(
          icon: Icons.add_circle_sharp,
          size: 24,
          onTap: () => showScoreInputDialog(
            context: context,
            cubit: cubit,
            player: player,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: context.palette.accent, size: size),
      ),
    );
  }
}
