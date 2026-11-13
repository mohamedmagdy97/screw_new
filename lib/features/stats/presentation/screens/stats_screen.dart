import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/skeleton.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_stats.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_title.dart';
import 'package:screw_calculator/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:screw_calculator/features/stats/presentation/widgets/win_rate_chart.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsCubit>(
      create: (_) => sl<StatsCubit>(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context).statsTitle),
      bottomNavigationBar: const BottomNavigationText(),
      body: Directionality(
        textDirection: context.contentDirection,
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            switch (state.status) {
              case StatsStatus.loading:
                return const SkeletonList(itemHeight: 110);
              case StatsStatus.error:
                return Center(
                  child: CustomText(
                    text: AppLocalizations.of(context).statsLoadError,
                    fontSize: 16,
                  ),
                );
              case StatsStatus.loaded:
                if (state.players.isEmpty) return const _EmptyStats();
                return _StatsBody(state: state);
            }
          },
        ),
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: CustomText(
          text: AppLocalizations.of(context).statsEmpty,
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.state});

  final StatsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final best = state.players.first;
    final worst = state.mostLosses;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _Highlight(
                emoji: '👑',
                label: AppLocalizations.of(context).bestWinRate,
                value: best.name,
                color: palette.win,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Highlight(
                emoji: '😅',
                label: AppLocalizations.of(context).mostLosses,
                value: worst?.name ?? '—',
                color: palette.lose,
              ),
            ),
          ],
        ),
        if (state.titles.isNotEmpty) ...[
          const SizedBox(height: 20),
          _TitlesSection(titles: state.titles),
        ],
        const SizedBox(height: 20),
        _Section(
          title: AppLocalizations.of(context).winRate,
          child: WinRateChart(players: state.players),
        ),
        const SizedBox(height: 16),
        for (final p in state.players) _PlayerRow(stats: p),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.12), palette.surface),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          CustomText(text: label, fontSize: 13, color: palette.textSecondary),
          const SizedBox(height: 2),
          CustomText(text: value, fontSize: 18),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, fontSize: 16, textAlign: TextAlign.start),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: stats.name,
            fontSize: 18,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(
                label: AppLocalizations.of(context).played,
                value: '${stats.games}',
              ),
              _Metric(
                label: AppLocalizations.of(context).wins,
                value: '${stats.wins}',
              ),
              _Metric(
                label: AppLocalizations.of(context).lossesLabel,
                value: '${stats.losses}',
              ),
              _Metric(
                label: AppLocalizations.of(context).avgScore,
                value: stats.averageScore.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(text: value, fontSize: 18, color: context.palette.brandSoft),
        CustomText(
          text: label,
          fontSize: 12,
          color: context.palette.textSecondary,
        ),
      ],
    );
  }
}

/// «الألقاب»: كروت ذهبية، كل لقب وصاحبه.
class _TitlesSection extends StatelessWidget {
  const _TitlesSection({required this.titles});

  final List<PlayerTitle> titles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: l10n.titlesHeader,
          fontSize: 16,
          fontFamily: AppFonts.bold,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in titles)
                  SizedBox(
                    width: width,
                    child: TitleCard(title: t),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// كارت لقب واحد بلمسة ذهبي MegTech.
class TitleCard extends StatelessWidget {
  const TitleCard({super.key, required this.title});

  final PlayerTitle title;

  static String emoji(PlayerTitleKind kind) => switch (kind) {
    PlayerTitleKind.king => '👑',
    PlayerTitleKind.biggestScrew => '💥',
    PlayerTitleKind.cleanestGame => '✨',
    PlayerTitleKind.mostGames => '🃏',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final (label, detail) = switch (title.kind) {
      PlayerTitleKind.king => (
        l10n.titleKing,
        l10n.titleKingDetail(title.value),
      ),
      PlayerTitleKind.biggestScrew => (
        l10n.titleBiggestScrew,
        l10n.titlePointsDetail(title.value),
      ),
      PlayerTitleKind.cleanestGame => (
        l10n.titleCleanestGame,
        l10n.titlePointsDetail(title.value),
      ),
      PlayerTitleKind.mostGames => (
        l10n.titleMostGames,
        l10n.titleGamesDetail(title.value),
      ),
    };
    return Container(
      key: ValueKey('title-${title.kind.name}'),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          palette.gold.withValues(alpha: 0.12),
          palette.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Text(emoji(title.kind), style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          CustomText(
            text: label,
            fontSize: 13,
            fontFamily: AppFonts.bold,
            color: palette.gold,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          CustomText(text: title.name, fontSize: 16.5, maxLines: 1),
          CustomText(
            text: detail,
            fontSize: 12,
            color: palette.textSecondary,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
