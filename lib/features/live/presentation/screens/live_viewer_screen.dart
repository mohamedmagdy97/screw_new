import 'package:flutter/material.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/live/domain/entities/live_game.dart';
import 'package:screw_calculator/features/live/domain/repositories/live_game_repository.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// متابعة لعبة لايف: الترتيب والجولات بيتحدّثوا لوحدهم.
class LiveViewerScreen extends StatefulWidget {
  const LiveViewerScreen({super.key, required this.code});

  final String code;

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  late final Stream<LiveGame?> _stream = sl<LiveGameRepository>().watch(
    widget.code,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: l10n.liveViewerTitle(widget.code)),
      body: Directionality(
        textDirection: context.contentDirection,
        child: StreamBuilder<LiveGame?>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return _Message(
                icon: Icons.wifi_off_rounded,
                text: l10n.liveLoadError,
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final game = snap.data;
            if (game == null) {
              return _Message(
                icon: Icons.search_off_rounded,
                text: l10n.liveNotFound,
              );
            }
            return _LiveBoard(game: game);
          },
        ),
      ),
    );
  }
}

class _LiveBoard extends StatelessWidget {
  const _LiveBoard({required this.game});

  final LiveGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final ranking = game.ranking;
    final best = ranking.isEmpty ? null : ranking.first.total;
    final worst = ranking.isEmpty ? null : ranking.last.total;
    final decided = best != worst;
    final status = game.ended
        ? l10n.liveEnded
        : game.finished
        ? l10n.liveFinished
        : l10n.liveRound(game.round);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            key: const ValueKey('live-status'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (game.ended ? palette.textSecondary : palette.lose)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!game.ended && !game.finished) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: palette.lose,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                CustomText(text: status, fontSize: 14, maxLines: 1),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < ranking.length; i++)
          _Row(
            rank: i + 1,
            player: ranking[i],
            leader: decided && ranking[i].total == best,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.player, required this.leader});

  final int rank;
  final LivePlayer player;
  final bool leader;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = leader ? palette.gold : palette.border;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: leader
            ? Color.alphaBlend(
                palette.gold.withValues(alpha: 0.12),
                palette.surface,
              )
            : palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: accent, width: leader ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                child: CustomText(
                  text: leader ? '👑' : '$rank',
                  fontSize: 17,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text: player.name,
                  fontSize: 17,
                  fontFamily: AppFonts.bold,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                ),
              ),
              CustomText(
                text: '${player.total}',
                fontSize: 22,
                fontFamily: AppFonts.bold,
                color: leader ? palette.gold : palette.brandSoft,
                maxLines: 1,
              ),
            ],
          ),
          if (player.rounds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (final r in player.rounds)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: palette.screen,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: CustomText(
                        text: r.isEmpty ? '–' : r,
                        fontSize: 14,
                        color: r.isEmpty
                            ? palette.textSecondary
                            : palette.textPrimary,
                        maxLines: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: palette.textSecondary),
            const SizedBox(height: 12),
            CustomText(
              text: text,
              fontSize: 15.5,
              color: palette.textSecondary,
              height: 1.6,
            ),
          ],
        ),
      ),
    );
  }
}
