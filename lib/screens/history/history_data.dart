import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/models/game_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';

class HistoryData {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  GenericCubit<List<GameModel>> gamesCubit = GenericCubit<List<GameModel>>(
    data: [],
  );

  List<bool?> loadDetails = [];

  List<GameModel> listGames = [];

  void init() {
    getSavedGames();
  }

  Future<void> getSavedGames() async {
    final String? res = await AppLocalStore.getString(
      LocalStoreNames.gamesHistory,
    );

    if (res != null && res.isNotEmpty) {
      final dynamic decoded = jsonDecode(res);

      if (decoded is List) {
        // cast كل عنصر إلى Map<String, dynamic>
        final List<Map<String, dynamic>> jsonData = decoded
            .map<Map<String, dynamic>>((e) {
              if (e is Map<String, dynamic>) {
                return e;
              } else {
                return <String, dynamic>{};
              }
            })
            .toList();

        listGames = jsonData
            .map<GameModel>((json) => GameModel.fromJson(json))
            .toList();
      } else {
        listGames = [];
      }
    } else {
      listGames = [];
    }

    //   String? res = await AppLocalStore.getString(LocalStoreNames.gamesHistory);
    //
    //   log('>>>>>>>>>>>>>EEEE==$res');
    //
    //   final List<dynamic> jsonData;
    //   if (res != null) {
    //     jsonData = jsonDecode(res);
    //     listGames = List<GameModel>.from(
    //       jsonData.map((e) => GameModel.fromJson(e)),
    //     ).toList();
    //   } else {
    //     listGames = [];
    //   }

    gamesCubit.update(data: listGames.toList());
  }

  void removeGame(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'تحذير',
                fontSize: 18.sp,
                color: AppColors.mainColor,
              ),
              const SizedBox(height: 40),
              CustomText(
                text: 'سيتم حذف الجولة رقم ${index + 1}',
                fontSize: 18.sp,
              ),
                const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const CustomText(text: 'لا', fontSize: 18),
                  ),
                  CustomButton(
                    width: 0.25.sw,
                    height: 40,
                    text: 'نعم',
                    isButtonBorder: true,
                    onPressed: () {
                      gamesCubit.state.data!.removeAt(index);
                      gamesCubit.update(data: gamesCubit.state.data!);
                      listGames.removeAt(index);
                      updateGameDB();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearDB(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'تحذير',
                fontSize: 18.sp,
                color: AppColors.mainColor,
              ),
              const SizedBox(height: 40),
              CustomText(text: 'سيتم حذف جميع السجلات', fontSize: 18.sp),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const CustomText(text: 'لا', fontSize: 18),
                  ),
                  CustomButton(
                    width: 0.25.sw,
                    height: 40,
                    text: 'نعم',
                    isButtonBorder: true,
                    onPressed: () {
                      AppLocalStore.removeString(LocalStoreNames.gamesHistory);
                      gamesCubit.update(data: []);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateGameDB() {
    var list = listGames
        // .where((element) => element.isFavorite == true)
        .map((e) => e)
        .toList();
    log('>>>>>>>>>>>listGamesssss=${jsonEncode(list)}');

    AppLocalStore.setString(LocalStoreNames.gamesHistory, jsonEncode(list));
  }
}
