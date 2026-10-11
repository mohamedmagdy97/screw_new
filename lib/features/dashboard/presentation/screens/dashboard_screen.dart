import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/score_edit.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/marquee_bar.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/player_card.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/round_header.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/share_screen_btn.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/team_card.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.players,
    this.fromHistory = false,
    this.teamsMode = false,
    this.initialEdits = const [],
  });

  final List<PlayerModel> players;
  final bool fromHistory;
  final bool teamsMode;

  /// سجل التعديلات المستعاد مع لعبة محفوظة.
  final List<ScoreEdit> initialEdits;

  @override
  Widget build(BuildContext context) {
    final bool showTeamsView =
        ModeClass.mode == GameModeEnum.friendly && !fromHistory;
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()
        ..start(
          players: players,
          showTeamsView: showTeamsView,
          teamNames: [
            AppLocalizations.of(context).teamFirst,
            AppLocalizations.of(context).teamSecond,
            AppLocalizations.of(context).teamThird,
            AppLocalizations.of(context).teamFourth,
          ],
        ),
      child: _DashboardView(fromHistory: fromHistory),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({required this.fromHistory});

  final bool fromHistory;

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showResultDialog(DashboardCubit cubit) {
    final winners = cubit.state.players
        .where((p) => (int.tryParse(p.total ?? '') ?? -1) == cubit.winnerTotal)
        .map((p) => p.name ?? '')
        .join(AppLocalizations.of(context).andJoin);
    final losers = cubit.state.players
        .where((p) => (int.tryParse(p.total ?? '') ?? -1) == cubit.loserTotal)
        .map((p) => p.name ?? '')
        .join(AppLocalizations.of(context).andJoin);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final palette = ctx.palette;
        final l10n = AppLocalizations.of(ctx);
        return AppDialog(
          icon: Icons.emoji_events_rounded,
          tone: AppDialogTone.success,
          title: l10n.gameOver,
          content: Column(
            children: [
              _ResultPill(text: l10n.winnerLabel(winners), color: palette.win),
              const SizedBox(height: 8),
              _ResultPill(text: l10n.loserLabel(losers), color: palette.lose),
            ],
          ),
          actions: [
            Expanded(
              child: AppDialogButton(
                label: l10n.ok,
                primary: true,
                tone: AppDialogTone.success,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (a, b) => a.status != b.status && b.message != null,
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        final message = state.message;
        if (message != null) {
          Utilities().showCustomSnack(
            context,
            txt: switch (message) {
              DashboardMessage.saved => l10n.roundSaved,
              DashboardMessage.saveFailed => l10n.roundSaveFailed,
            },
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        final int round = cubit.currentRound;
        if (cubit.isFinished && !cubit.finishAnnounced && !widget.fromHistory) {
          cubit.finishAnnounced = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _confettiController.play();
            HapticFeedback.heavyImpact();
            _showResultDialog(cubit);
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) Navigator.pop(context, true);
          },
          child: Scaffold(
            appBar: DashboardAppBar(
              fromHistory: widget.fromHistory,
              onResetConfirmed: cubit.resetGame,
            ),
            bottomNavigationBar: const BottomNavigationText(),
            body: Column(
              children: [
                const MarqueeBar(),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Directionality(
                        textDirection: context.contentDirection,
                        child: Column(
                          children: [
                            RoundHeader(
                              cubit: cubit,
                              round: round,
                              readOnly: widget.fromHistory,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 1,
                                ),
                                child: Column(
                                  children: [
                                    Screenshot(
                                      controller: _screenshotController,
                                      child: state.showTeamsView
                                          ? _TeamsBoard(
                                              cubit: cubit,
                                              state: state,
                                            )
                                          : _PlayersBoard(
                                              cubit: cubit,
                                              state: state,
                                            ),
                                    ),
                                    _ActionsRow(
                                      cubit: cubit,
                                      screenshotController:
                                          _screenshotController,
                                      teamsView: state.showTeamsView,
                                      fromHistory: widget.fromHistory,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink,
                          Colors.orange,
                          Colors.purple,
                        ],
                        gravity: 0.3,
                        emissionFrequency: 0.05,
                        numberOfParticles: 25,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayersBoard extends StatelessWidget {
  const _PlayersBoard({required this.cubit, required this.state});

  final DashboardCubit cubit;
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final player in state.players)
          PlayerCard(
            cubit: cubit,
            player: player,
            winnerTotal: cubit.winnerTotal,
            loserTotal: cubit.loserTotal,
          ),
      ],
    );
  }
}

class _TeamsBoard extends StatelessWidget {
  const _TeamsBoard({required this.cubit, required this.state});

  final DashboardCubit cubit;
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final winning = cubit.winningTeam;
    return Column(
      spacing: 8,
      children: [
        for (final team in state.teams)
          TeamCard(cubit: cubit, team: team, isWinning: team == winning),
      ],
    );
  }
}

/// أزرار أسفل اللوحة: مشاركة + (حفظ النتيجة | إعادة اللعبة) مع تلميح الحفظ.
class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.cubit,
    required this.screenshotController,
    required this.teamsView,
    required this.fromHistory,
  });

  final DashboardCubit cubit;
  final ScreenshotController screenshotController;
  final bool teamsView;
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: Column(
        children: [
          if (!teamsView && !fromHistory)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomText(
                text: l10n.saveHint,
                fontSize: 13,
                color: palette.textSecondary,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ShareScreenBtn(
                  cubit: cubit,
                  screenshotController: screenshotController,
                ),
              ),
              if (teamsView || !fromHistory) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: teamsView ? cubit.resetGame : cubit.saveGame,
                      icon: Icon(
                        teamsView
                            ? Icons.restart_alt_rounded
                            : Icons.save_alt_rounded,
                        size: 20,
                      ),
                      label: FittedBox(
                        child: Text(
                          teamsView ? l10n.resetRound : l10n.saveResult,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// شريحة نتيجة (فائز/خاسر) داخل حوار نهاية اللعبة.
class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: CustomText(text: text, fontSize: 17, color: color),
    );
  }
}
