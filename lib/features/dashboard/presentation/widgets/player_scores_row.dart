import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/score_input_sheet.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// صف نتائج جولات اللاعب: كل نتيجة شريحة قابلة للضغط للتعديل، ثم زر الإضافة
/// والمجموع. النتيجة المعدّلة بعد إدخالها تظهر بعلامة مميّزة.
class PlayerScoresRow extends StatelessWidget {
  const PlayerScoresRow({super.key, required this.cubit, required this.player});

  final DashboardCubit cubit;
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < 5; i++)
                if (player.getRoundScore(i + 1).isNotEmpty)
                  _ScoreChip(
                    value: player.getRoundScore(i + 1),
                    edited: cubit.isEdited(player, i + 1),
                    semanticLabel: l10n.scoreSheetEditTitle(
                      player.name ?? '',
                      i + 1,
                    ),
                    onTap: () => showScoreInputSheet(
                      context: context,
                      cubit: cubit,
                      player: player,
                      editRoundIndex: i,
                    ),
                  ),
              if (player.gw5!.isEmpty)
                _AddButton(
                  semanticLabel: l10n.addScoreSemantic(player.name ?? ''),
                  onTap: () => showScoreInputSheet(
                    context: context,
                    cubit: cubit,
                    player: player,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: palette.brand.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: CustomText(
            text: '${player.total}',
            fontSize: 22.sp,
            fontFamily: AppFonts.bold,
            color: palette.brandSoft,
          ),
        ),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.value,
    required this.edited,
    required this.semanticLabel,
    required this.onTap,
  });

  final String value;
  final bool edited;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: '$semanticLabel: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm + 4),
        child: Container(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: palette.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadii.sm + 4),
            border: Border.all(
              color: edited ? palette.accent : palette.border,
              width: edited ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(text: value, fontSize: 18.sp, height: 1),
              if (edited) ...[
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 12, color: palette.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.semanticLabel, required this.onTap});

  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: palette.brandGradient,
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
