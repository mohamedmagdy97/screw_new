import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/models/item.dart';
import 'package:screw_calculator/screens/game_mode/game_mode_data.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class GameMode extends StatefulWidget {
  const GameMode({super.key});

  @override
  State<GameMode> createState() => _GameModeState();
}

class _GameModeState extends State<GameMode> {
  GameModeData gameModeData = GameModeData();

  @override
  void initState() {
    gameModeData.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => gameModeData.onWillPop(context),
      child: Scaffold(
        key: gameModeData.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.grayy,
          title: CustomText(text: "سكرو حاسبة", fontSize: 22.sp),
        ),
        backgroundColor: AppColors.bg,
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CustomText(
              text: "Game mode",
              fontSize: 16.sp,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            BlocBuilder<GenericCubit<List<Item>>, GenericState<List<Item>>>(
              bloc: gameModeData.listCubit,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Hero(
                        tag:
                            'gameMode-${state.data!.where((e) => e.isActive!).toList().first.key}', // معرف فريد لكل عنصر
                        child: Material(
                          color: Colors.transparent,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: /*state.isLoading ? 0.5 :*/ 1,

                            child: Column(
                              children: List.generate(
                                state.data!.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  height: 120.h,
                                  width: 1.sw,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: state.data![index].isActive!
                                        ? AppColors.mainColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: state.data![index].isActive!
                                          ? Colors.transparent
                                          : AppColors.mainColor,
                                    ),
                                    boxShadow: state.data![index].isActive!
                                        ? [
                                            BoxShadow(
                                              color: AppColors.mainColor
                                                  .withOpacity(.3),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () =>
                                        gameModeData.onSelect(context, index),
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.normal,
                                          color: state.data![index].isActive!
                                              ? Colors.white
                                              : AppColors.black,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: CustomText(
                                          text: state.data![index].value
                                              .toString(),
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    CustomButton(
                      text: "التالي",
                      onPressed: () => gameModeData.goHome(
                        context,
                        state.data!
                            .where((e) => e.isActive!)
                            .toList()
                            .first
                            .key,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
