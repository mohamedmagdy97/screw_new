import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/models/item.dart';
import 'package:screw_calculator/core/state/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/widgets/build_team_field.dart';
import 'package:screw_calculator/features/home/presentation/widgets/recent_players_bar.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class FriendsMode extends StatelessWidget {
  const FriendsMode({super.key});

  @override
  Widget build(BuildContext context) {
    final homeData = sl<HomeController>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CustomText(
          text: AppLocalizations.of(context).chooseNumberOfTeams,
          fontSize: 16.sp,
          textAlign: context.readStart,
        ),
        const SizedBox(height: 16),
        BlocBuilder<GenericCubit<List<Item>>, GenericState<List<Item>>>(
          bloc: homeData.listTeamsCubit,
          builder: (context, state) {
            final activeTeams = state.data!
                .firstWhere((e) => e.isActive == true)
                .key!;
            return Column(
              crossAxisAlignment: context.readStartCross,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      state.data!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Semantics(
                          button: true,
                          selected: state.data![index].isActive,
                          label: state.data![index].value,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.sp),
                            onTap: () => homeData.onSelectTeam(index),
                            child: Container(
                              width: (1.sw - 120.w) / 5,
                              height: 50,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.sp),
                                gradient: LinearGradient(
                                  colors: state.data![index].isActive!
                                      ? [
                                          context.palette.brand,
                                          context.palette.brand.withValues(
                                            alpha: 0.82,
                                          ),
                                        ]
                                      : [
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),

                                // color: state.data![index].isActive!
                                //     ? AppColors.mainColor
                                //     : null,
                                border: Border.all(
                                  color: !state.data![index].isActive!
                                      ? AppColors.mainColor
                                      : Colors.transparent,
                                ),
                              ),
                              child: CustomText(
                                text: state.data![index].value.toString(),
                                fontSize: 18.sp,
                                color: state.data![index].isActive!
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RecentPlayersBar(
                  names: homeData.recentPlayers,
                  onPick: (name) => homeData.pickRecentPlayer(name, [
                    homeData.playerOne,
                    homeData.playerTwo,
                    homeData.playerThree,
                    homeData.playerFour,
                    if (activeTeams >= 3) ...[
                      homeData.playerFive,
                      homeData.playerSix,
                    ],
                    if (activeTeams >= 4) ...[
                      homeData.playerOne2,
                      homeData.playerTwo2,
                    ],
                  ]),
                ),
                BuildTeamFields(
                  teamName: AppLocalizations.of(context).teamFirst,
                  controllers: [homeData.playerOne, homeData.playerTwo],
                ),
                BuildTeamFields(
                  teamName: AppLocalizations.of(context).teamSecond,
                  controllers: [homeData.playerThree, homeData.playerFour],
                ),
                if (activeTeams >= 3)
                  BuildTeamFields(
                    teamName: AppLocalizations.of(context).teamThird,
                    controllers: [homeData.playerFive, homeData.playerSix],
                  ),
                if (activeTeams >= 4)
                  BuildTeamFields(
                    teamName: AppLocalizations.of(context).teamFourth,
                    controllers: [homeData.playerOne2, homeData.playerTwo2],
                  ),
                const SizedBox(height: 16),
                CustomButton(
                  text: AppLocalizations.of(context).next,
                  onPressed: () => homeData.goToNextTeams(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
