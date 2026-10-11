import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// بطاقة لعبة محفوظة: رقم اللعبة، الفائز (أقل سكور) بمجموعه، وزر حذف.
class HistoryItem extends StatelessWidget {
  final GameHistoryEntity game;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryItem({
    super.key,
    required this.game,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  /// (اسم الفائز، مجموعه) — الأقل نقاطًا يفوز.
  (String, int) _winner() {
    if (game.players.isEmpty) return ('', 0);
    final best = game.players.reduce(
      (curr, next) =>
          (int.tryParse(curr.total ?? '0') ?? 0) <=
              (int.tryParse(next.total ?? '0') ?? 0)
          ? curr
          : next,
    );
    return (best.name ?? '', int.tryParse(best.total ?? '0') ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final (winner, total) = _winner();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: palette.brandGradient,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontFamily: AppFonts.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: context.readStartCross,
                    children: [
                      CustomText(
                        text: l10n.gameN(index + 1),
                        fontSize: 17,
                        fontFamily: AppFonts.bold,
                        textAlign: context.readStart,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        text: '👑 $winner · $total',
                        fontSize: 14,
                        color: palette.win,
                        textAlign: context.readStart,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: palette.lose),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
