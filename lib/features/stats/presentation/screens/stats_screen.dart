import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/stats/domain/entities/player_stats.dart';
import 'package:screw_calculator/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:screw_calculator/features/stats/presentation/widgets/win_rate_chart.dart';

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
      appBar: const CustomAppBar(title: 'إحصائيات اللاعبين'),
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          switch (state.status) {
            case StatsStatus.loading:
              return const Center(child: CircularProgressIndicator.adaptive());
            case StatsStatus.error:
              return const Center(
                child: CustomText(text: 'تعذّر تحميل الإحصائيات', fontSize: 16),
              );
            case StatsStatus.loaded:
              if (state.players.isEmpty) return const _EmptyStats();
              return _StatsBody(state: state);
          }
        },
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CustomText(
          text:
              'لا توجد إحصائيات بعد.\nأكمل جولة واحدة واحفظها من لوحة النتائج وستظهر هنا.',
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
                label: 'أعلى نسبة فوز',
                value: best.name,
                color: palette.win,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Highlight(
                emoji: '😅',
                label: 'أكثر خسارة',
                value: worst?.name ?? '—',
                color: palette.lose,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'نسبة الفوز',
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
              _Metric(label: 'لعب', value: '${stats.games}'),
              _Metric(label: 'فوز', value: '${stats.wins}'),
              _Metric(label: 'خسارة', value: '${stats.losses}'),
              _Metric(
                label: 'متوسط النقاط',
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
