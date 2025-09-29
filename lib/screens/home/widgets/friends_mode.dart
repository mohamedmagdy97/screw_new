import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/models/item.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/screens/home/widgets/build_team_field.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class FriendsMode extends StatelessWidget {
  const FriendsMode({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CustomText(
          text: 'أختر عدد الفرق',
          fontSize: 16.sp,
          textAlign: TextAlign.end,
        ),
        const SizedBox(height: 16),
        BlocBuilder<GenericCubit<List<Item>>, GenericState<List<Item>>>(
          bloc: homeData.listTeamsCubit,
          builder: (context, state) {
            final activeTeams = state.data!
                .firstWhere((e) => e.isActive == true)
                .key!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      state.data!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                        Colors.purple.shade600,
                                        Colors.purple.shade800,
                                      ]
                                    : [Colors.transparent, Colors.transparent],
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BuildTeamFields(
                  teamName: 'الفريق الأول',
                  controllers: [homeData.playerOne, homeData.playerTwo],
                ),
                BuildTeamFields(
                  teamName: 'الفريق الثاني',
                  controllers: [homeData.playerThree, homeData.playerFour],
                ),
                if (activeTeams >= 3)
                  BuildTeamFields(
                    teamName: 'الفريق الثالث',
                    controllers: [homeData.playerFive, homeData.playerSix],
                  ),
                if (activeTeams >= 4)
                  BuildTeamFields(
                    teamName: 'الفريق الرابع',
                    controllers: [homeData.playerOne2, homeData.playerTwo2],
                  ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'التالي',
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
