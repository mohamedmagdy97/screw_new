import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
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
        ..start(players: players, showTeamsView: showTeamsView),
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (a, b) => a.status != b.status && b.message != null,
      listener: (context, state) {
        if (state.message != null) {
          Utilities().showCustomSnack(context, txt: state.message);
        }
      },
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        final int round = cubit.currentRound;
        if (cubit.isFinished) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _confettiController.play(),
          );
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
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            CustomText(
                              text: round == kGameFinishedRound
                                  ? 'انتهت الجولات'
                                  : 'الجولة رقم $round',
                              color: AppColors.mainColorLight,
                              fontSize: 18,
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
                                          ? _TeamsBoard(cubit: cubit, state: state)
                                          : _PlayersBoard(
                                              cubit: cubit,
                                              state: state,
                                            ),
                                    ),
                                    ShareScreenBtn(
                                      cubit: cubit,
                                      screenshotController: _screenshotController,
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
        const CustomText(
          text: 'الان يمكنك حفظ الجولة واستكمالها لاحقا',
          fontSize: 14,
          color: Colors.red,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 2),
          child: CustomButton(text: '💾 حفظ النتيجة', onPressed: onSave),
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
      child: CustomButton(text: 'اعادة بدأ الجولة', onPressed: onReset),
    );
  }
}
