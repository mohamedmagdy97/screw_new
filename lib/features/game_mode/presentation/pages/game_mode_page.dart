import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/features/game_mode/domain/item.dart';
import 'package:screw_calculator/screens/home/home.dart';
import '../../../../components/custom_button.dart';
import '../../../../components/custom_text.dart';
import '../../../../utility/app_theme.dart';
import '../../application/game_mode_cubit.dart';
import '../widgets/game_mode_item.dart';

class GameModePage extends StatelessWidget {
  const GameModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameModeCubit(),
      child: BlocBuilder<GameModeCubit, GameModeState>(
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async =>
                context.read<GameModeCubit>().onWillPop(context),
            child: Scaffold(
              backgroundColor: AppColors.bg,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: AppColors.grayy,
                title: CustomText(text: "سكرو حاسبة", fontSize: 22.sp),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomText(
                      text: "اختر وضع اللعبة",
                      fontSize: 18.sp,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      flex: 2,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: state.isLoading ? 0.5 : 1,
                        child: ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return GameModeItem(
                              item: item,
                              onTap: () => context
                                  .read<GameModeCubit>()
                                  .toggleItem(index),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      flex: 2,
                      child: CustomButton(
                        text: "التالي",
                        onPressed: () {
                          final selected = state.items.firstWhere(
                            (i) => i.isActive!,
                            orElse: () => Item(value: ''),
                          );
                          if (selected.value.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyHomePage(),
                              ),
                            );
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('تم اختيار: ${selected.value}')),
                            // );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
