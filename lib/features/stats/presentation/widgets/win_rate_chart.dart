import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_stats.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// رسم بياني أفقي لنسبة فوز كل لاعب (بدون مكتبات خارجية).
class WinRateChart extends StatelessWidget {
  const WinRateChart({super.key, required this.players});

  final List<PlayerStats> players;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        for (final p in players.take(8))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Semantics(
              label: AppLocalizations.of(
                context,
              ).winRateSemantics(p.name, (p.winRate * 100).round()),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: CustomText(
                      text: '${(p.winRate * 100).round()}%',
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Stack(
                        children: [
                          Container(height: 14, color: palette.border),
                          FractionallySizedBox(
                            widthFactor: p.winRate.clamp(0.02, 1),
                            alignment: AlignmentDirectional.centerEnd,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                gradient: palette.brandGradient,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 84,
                    child: CustomText(
                      text: p.name,
                      fontSize: 14,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
