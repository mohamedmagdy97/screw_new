import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/models/item.dart';
import 'package:screw_calculator/core/state/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/validation_form.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/custom_text_field.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/widgets/recent_players_bar.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class ClassicMode extends StatelessWidget {
  const ClassicMode({super.key});

  @override
  Widget build(BuildContext context) {
    final homeData = sl<HomeController>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CustomText(
          text: AppLocalizations.of(context).chooseNumberOfPlayers,
          fontSize: 16.sp,
          textAlign: context.readStart,
        ),
        const SizedBox(height: 16),
        BlocBuilder<GenericCubit<List<Item>>, GenericState<List<Item>>>(
          bloc: homeData.listCubit,
          builder: (context, state) {
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
                            onTap: () => homeData.onSelect(index),
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
                const SizedBox(height: 24),
                RecentPlayersBar(
                  names: homeData.recentPlayers,
                  onPick: (name) => homeData.pickRecentPlayer(
                    name,
                    homeData.controllers
                        .take(
                          state.data!
                              .firstWhere((e) => e.isActive == true)
                              .key!,
                        )
                        .toList(),
                  ),
                ),
                for (
                  int i = 0;
                  i < state.data!.firstWhere((e) => e.isActive == true).key!;
                  i++
                )
                  CustomTextField(
                    controller: homeData.controllers[i],
                    hintText: '',
                    labelText: AppLocalizations.of(
                      context,
                    ).enterPlayerNameN(i + 1),
                    containtPaddingRight: 0,
                    inputType: TextInputType.text,
                    textFieldVaidType: TextFieldValidatorType.displayText,
                  ),
                const SizedBox(height: 16),
                CustomButton(
                  text: AppLocalizations.of(context).next,
                  onPressed: () => homeData.goToNext(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
