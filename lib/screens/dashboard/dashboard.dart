import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/dox_decoration.dart';
import 'package:screw_calculator/components/fade_animation.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/models/player_model.dart';
import 'package:screw_calculator/models/team_model_new.dart';
import 'package:screw_calculator/screens/dashboard/dashboard_data.dart';
import 'package:screw_calculator/screens/dashboard/widgets/add_value_dialog.dart';
import 'package:screw_calculator/screens/dashboard/widgets/dashboard_appbar.dart';
import 'package:screw_calculator/screens/dashboard/widgets/marquee_bar.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/utility/Enums.dart' as enums;
import 'package:screw_calculator/utility/app_theme.dart';

class Dashboard extends StatefulWidget {
  final List<PlayerModel> players;
  final bool? teamsMode;
  final bool? fromHistory;

  const Dashboard({
    super.key,
    required this.players,
    this.fromHistory = false,
    this.teamsMode = false,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardData dashboardData = DashboardData();

  late ConfettiController _controller;

  @override
  void initState() {
    dashboardData.init();
    dashboardData.initTeams(widget.players, widget.teamsMode);
    _controller = ConfettiController(duration: const Duration(seconds: 5));

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _celebrate() {
    _controller.play();
  }

  int getCurrentRound() {
    for (int i = 1; i <= 5; i++) {
      if (widget.players.any((player) => player.getRoundScore(i).isEmpty)) {
        return i;
      }
    }
    _celebrate();
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    final int gw = getCurrentRound();
    int winnerResult = 0;
    int loserResult = 0;
    if (widget.players.isNotEmpty) {
      winnerResult = widget.players
          .map((p) => int.parse(p.total!))
          .reduce((a, b) => a < b ? a : b);

      loserResult = widget.players
          .map((p) => int.parse(p.total!))
          .reduce((a, b) => a > b ? a : b);
    }

    Team? winningTeam;
    if (dashboardData.teams.isNotEmpty) {
      winningTeam = dashboardData.teams.reduce(
        (curr, next) => curr.totalScore < next.totalScore ? curr : next,
      );
    }

    return Hero(
      tag: 'players-tag',
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return true;
        },
        child: Scaffold(
          appBar: DashBoardAppBar(
            fromHistory: widget.fromHistory ?? false,
            onPressed: () {
              homeData.clearValues();
              setState(() {});
            },
          ),
          backgroundColor: AppColors.bg,
          bottomNavigationBar: const BottomNavigationText(),
          floatingActionButton: InkWell(
            onTap: () => dashboardData.captureAndShare(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: customBoxDecoration(
                borderRadius: 8,
                color: AppColors.mainColor,
              ),

              // shape: Border.all(color: AppColors.red),
              // extendedPadding: const EdgeInsets.symmetric(horizontal: 8),
              // heroTag: null,
              child:
                  // Text("📲")
                  const CustomText(text: '📲 مشاركة', fontSize: 18),
            ),
          ),
          body: Column(
            children: [
              MarqueeBar(dashboardData: dashboardData),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Screenshot(
                      controller: dashboardData.screenshotController,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            CustomText(
                              text: gw == 10
                                  ? 'انتهت الجولات'
                                  : 'الجولة رقم $gw',
                              color: AppColors.mainColorLight,
                              fontSize: 18,
                            ),
                            enums.ModeClass.mode == enums.GameMode.classic ||
                                    widget.fromHistory == true
                                ? Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 1,
                                      ),
                                      child: Column(
                                        children: widget.players
                                            .map(
                                              (player) => buildPlayerCard(
                                                player,
                                                winnerResult,
                                                loserResult,
                                              ),
                                            )
                                            .toList(),
                                        // ..addAll(
                                        //   widget.fromHistory!
                                        //       ? []
                                        //       : buildGameSaveSection(),
                                        // ),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 1,
                                      ),
                                      child: Column(
                                        spacing: 8,
                                        children: [
                                          if (dashboardData.teams.isNotEmpty)
                                            ...dashboardData.teams.map((team) {
                                              return FadeSlide(
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: team == winningTeam
                                                        ? AppColors.mainColor
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.grayy,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CustomText(
                                                        text: team.name,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      Row(
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                '${team.playerOne.name} | ',
                                                            fontSize: 16.sp,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                buildPlayerScoresRow(
                                                                  team.playerOne,
                                                                ),
                                                          ),
                                                        ],
                                                      ),

                                                      // Divider(
                                                      //   color: team == winningTeam
                                                      //       ? AppColors.grey.withOpacity(
                                                      //           0.25,
                                                      //         )
                                                      //       : AppColors.opacity_1,
                                                      // ),
                                                      Row(
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                '${team.playerTwo.name} | ',
                                                            fontSize: 16.sp,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                buildPlayerScoresRow(
                                                                  team.playerTwo,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(),
                                                      CustomText(
                                                        text:
                                                            'المجموع: ${team.totalScore}',
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),

                    /// confetti 🎉
                    ConfettiWidget(
                      confettiController: _controller,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
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
              Column(
                children:
                    enums.ModeClass.mode == enums.GameMode.classic ||
                        widget.fromHistory == true
                    ? buildGameSaveSection()
                    : buildGameSaveSectionTeams(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlayerCard(PlayerModel player, int resWinner, int loserResult) {
    return FadeSlide(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          decoration: BoxDecoration(
            color: resWinner.toString() == player.total
                ? AppColors.green.withOpacity(0.75)
                : loserResult.toString() == player.total
                ? AppColors.red.withOpacity(0.75)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayy),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: player.name.toString(),
                      fontSize: 20.sp,
                      textAlign: TextAlign.start,
                    ),
                  ),

                  ?resWinner.toString() == player.total
                      ? const Image(
                          image: AssetImage(Assets.kingIcon),
                          height: 25,
                          width: 25,
                        )
                      : null,
                ],
              ),
              const SizedBox(width: 20, child: Divider(color: AppColors.white)),
              const SizedBox(height: 4),
              buildPlayerScoresRow(player),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlayerScoresRow(PlayerModel player) {
    return Row(
      children:
          List.generate(5, (i) {
            final String? roundScore = player.getRoundScore(i + 1);
            return roundScore != null && roundScore.isNotEmpty
                ? CustomText(
                    text: i == 0 ? ' $roundScore' : ' + $roundScore',
                    fontSize: 20.sp,
                  )
                : const SizedBox();
          })..addAll([
            if (player.gw5!.isEmpty)
              Row(
                children: [
                  if (player.gw1!.isNotEmpty)
                    InkWell(
                      onTap: player.gw5?.isNotEmpty ?? false
                          ? null
                          : () async {
                              await addValue(
                                context,
                                player: player,
                                edit: true,
                              );
                              setState(() {});
                            },
                      borderRadius: BorderRadius.circular(50),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: player.gw5?.isNotEmpty ?? false
                        ? null
                        : () async {
                            await addValue(context, player: player);
                            setState(() {});
                          },
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.add_circle_sharp,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            const Spacer(),
            CustomText(text: '=', fontSize: 20.sp),
            CustomText(text: ' ${player.total} ', fontSize: 20.sp),
          ]),
    );
  }

  List<Widget> buildGameSaveSection() {
    return [
      const SizedBox(height: 8),
      CustomText(
        text: 'بعد انتهاء جميع الجولات يمكنك حفظها لتراها في السجلات الخاصة بك',
        fontSize: 14.sp,
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: CustomButton(
          text: 'حفظ',
          width: 0.3.sw,

          onPressed: () => dashboardData.saveGame(widget.players, context),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> buildGameSaveSectionTeams() {
    return [
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),

        child: CustomButton(
          text: 'اعادة بدأ الجولة',
          color: AppColors.textColorTitle,
          width: 0.45.sw,
          onPressed: () => dashboardData.reloadGame(context, () {
            homeData.clearValues();
            setState(() {});
          }),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  addValue(
    BuildContext context, {
    required PlayerModel player,
    bool? edit = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => (edit ?? false)
          ? EditValueDialog(
              dashboardData: dashboardData,
              player: player,
              fun: () => setState(() {}),
            )
          : AddValueDialog(
              dashboardData: dashboardData,
              player: player,
              fun: () => setState(() {}),
            ),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curvedValue = Curves.easeInOut.transform(anim.value);

        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim.value,
            child: (edit ?? false)
                ? EditValueDialog(
                    dashboardData: dashboardData,
                    player: player,
                    fun: () => setState(() {}),
                  )
                : AddValueDialog(
                    dashboardData: dashboardData,
                    player: player,
                    fun: () => setState(() {}),
                  ),
          ),
        );
      },
    );
  }
}
