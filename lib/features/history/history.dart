import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/features/history/history_data.dart';
import 'package:screw_calculator/models/game_model.dart';
import 'package:screw_calculator/screens/dashboard/dashboard.dart';
 import 'package:screw_calculator/utility/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryData historyData = HistoryData();

  @override
  void initState() {
    historyData.init();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الجولات السابقة',
        leading: IconButton(
          onPressed: () => historyData.clearDB(context),
          icon: const Icon(Icons.delete_outline, color: AppColors.white),
        ),
      ),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body:
          BlocBuilder<
            GenericCubit<List<GameModel>>,
            GenericState<List<GameModel>>
          >(
            bloc: historyData.gamesCubit,
            builder: (context, state) {
              if (state.data != null && state.data!.isNotEmpty) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.data!.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Dashboard(
                              players: state.data![index].game!,
                              fromHistory: true,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () =>
                                historyData.removeGame(context, index),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.white,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomText(
                                text: 'الجولة ${index + 1} ',
                                fontSize: 18,
                                fontFamily: AppFonts.bold,
                                textAlign: TextAlign.end,
                              ),
                              CustomText(
                                text:
                                    '(${state.data![index].game!.reduce((curr, next) => int.parse(curr.total!) < int.parse(next.total!) ? (curr) : (next)).name.toString()}) صاحب أقل سكور ',
                                fontSize: 14,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.mainColor),
                );
              } else {
                return const Center(
                  child: CustomText(
                    text: 'لا يوجد سجلات سابقة',
                    fontSize: 20,
                    textAlign: TextAlign.end,
                  ),
                );
              }
            },
          ),
    );
  }
}
