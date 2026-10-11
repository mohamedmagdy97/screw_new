import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

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

  String _getWinnerName() {
    if (game.players.isEmpty) return '';
    return game.players
        .reduce(
          (curr, next) =>
              int.parse(curr.total ?? '0') < int.parse(next.total ?? '0')
              ? curr
              : next,
        )
        .name
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: AppLocalizations.of(context).gameN(index + 1),
                  fontSize: 18,
                  fontFamily: AppFonts.bold,
                  textAlign: TextAlign.end,
                ),
                CustomText(
                  text: AppLocalizations.of(
                    context,
                  ).lowestScoreWinner(_getWinnerName()),
                  fontSize: 14,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
