import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/marquee_bar.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/player_card.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/share_screen_btn.dart';
import 'package:screw_calculator/features/dashboard/presentation/widgets/team_card.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.players,
    this.fromHistory = false,
    this.teamsMode = false,
  });

  final List<PlayerModel> players;
  final bool fromHistory;
  final bool teamsMode;

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
        return AlertDialog(
          title: CustomText(
            text: AppLocalizations.of(ctx).gameOver,
            fontSize: 20,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: AppLocalizations.of(ctx).winnerLabel(winners),
                fontSize: 18,
                color: palette.win,
              ),
              const SizedBox(height: 8),
              CustomText(
                text: AppLocalizations.of(ctx).loserLabel(losers),
                fontSize: 16,
                color: palette.lose,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).ok),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: round == kGameFinishedRound
                                      ? AppLocalizations.of(
                                          context,
                                        ).roundsFinished
                                      : AppLocalizations.of(
                                          context,
                                        ).roundNumber(round),
                                  color: context.palette.brandSoft,
                                  fontSize: 18,
                                ),
                                if (!widget.fromHistory)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 12,
                                    ),
                                    child: TextButton.icon(
                                      onPressed: cubit.canUndo
                                          ? cubit.undo
                                          : null,
                                      icon: const Icon(Icons.undo, size: 18),
                                      label: Text(
                                        AppLocalizations.of(context).undo,
                                      ),
                                    ),
                                  ),
                              ],
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
                                    ShareScreenBtn(
                                      cubit: cubit,
                                      screenshotController:
                                          _screenshotController,
                                    ),
                                    if (state.showTeamsView)
                                      _ResetSection(onReset: cubit.resetGame)
                                    else if (!widget.fromHistory)
                                      _SaveSection(onSave: cubit.saveGame),
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

class _SaveSection extends StatelessWidget {
  const _SaveSection({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          text: AppLocalizations.of(context).saveHint,
          fontSize: 14,
          color: Colors.red,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 2),
          child: CustomButton(
            text: AppLocalizations.of(context).saveResult,
            onPressed: onSave,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ResetSection extends StatelessWidget {
  const _ResetSection({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomButton(
        text: AppLocalizations.of(context).resetRound,
        onPressed: onReset,
      ),
    );
  }
}
