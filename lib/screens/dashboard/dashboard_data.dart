import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_button.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/models/game_model.dart';
import 'package:screw_calculator/models/player_model.dart';
import 'package:screw_calculator/models/team_model_new.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';
import 'package:screw_calculator/utility/utilities.dart';

class DashboardData {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late List<Team> teams;

  void init() {
    hideMarquee.update(data: false);
    getSavedGames();
    // loadNativeAdvanced();
  }

  void initTeams(List<PlayerModel> players, bool? teamsMode) {
    // Assuming we have 4 players for 2 teams
    if (teamsMode == true && players.length >= 4) {
      teams = [
        Team(
          name: "الفريق الأول",
          playerOne: players[0],
          playerTwo: players[1],
        ),
        Team(
          name: "الفريق الثاني",
          playerOne: players[2],
          playerTwo: players[3],
        ),
        if (players.length > 4)
          Team(
            name: "الفريق الثالث",
            playerOne: players[4],
            playerTwo: players[5],
          ),
        if (players.length > 6)
          Team(
            name: "الفريق الرابع",
            playerOne: players[6],
            playerTwo: players[7],
          ),
      ];
    } else {
      teams = [];
    }
  }

  checkAllGwPlayed(int gw, List<PlayerModel> players, int index) {
    debugPrint('ddddddddd=gw1=${players[index].gw1!.isNotEmpty}');
    debugPrint('ddddddddd=gw2=${players[index].gw2!.isNotEmpty}');
    debugPrint('ddddddddd=gw3=${players[index].gw3!.isNotEmpty}');
    debugPrint('ddddddddd=gw4=${players[index].gw4!.isNotEmpty}');
    debugPrint('ddddddddd=gw5=${players[index].gw5!.isNotEmpty}');
    debugPrint('ddddddddd==$gw');
    debugPrint(
      'dd=1=${players.where((element) => element.gw1!.isEmpty).toList().length > 1}',
    );
    debugPrint(
      'dd=2=${players.where((element) => element.gw2!.isEmpty).toList().length > 1}',
    );
    debugPrint(
      'dd=3=${players.where((element) => element.gw3!.isEmpty).toList().length > 1}',
    );
    debugPrint(
      'dd=4=${players.where((element) => element.gw4!.isEmpty).toList().length > 1}',
    );
    debugPrint(
      'dd=5=${players.where((element) => element.gw5!.isEmpty).toList().length > 1}',
    );

    if (gw == 1) {
      if (players[index].gw1!.isNotEmpty != false &&
          (players.where((element) => element.gw1!.isEmpty).toList().length >
                  1 !=
              false)) {
        debugPrint('ssssss  lol 1');
      }
    } else if (gw == 2) {
      if (players[index].gw2!.isNotEmpty != false &&
          (players.where((element) => element.gw2!.isEmpty).toList().length >
                  1 !=
              false)) {
        debugPrint('ssssss  lol 2');
      }
    } else if (gw == 3) {
      if (players[index].gw3!.isNotEmpty != false &&
          (players.where((element) => element.gw3!.isEmpty).toList().length >
                  1 !=
              false)) {
        debugPrint('ssssss  lol 3');
      }
    } else if (gw == 4) {
      if (players[index].gw4!.isNotEmpty != false &&
          (players.where((element) => element.gw4!.isEmpty).toList().length >
                  1 !=
              false)) {
        debugPrint('ssssss  lol 4');
      }
    } else if (gw == 5) {
      if (players[index].gw5!.isNotEmpty != false &&
          (players.where((element) => element.gw5!.isEmpty).toList().length >
                  1 !=
              false)) {
        debugPrint('ssssss  lol 5');
      }
    }

    // if(gw ==1){
    //   if(
    //   players.where((element) => element.gw1!.isEmpty).toList().length >1){
    //     print('lolllllll11 11');
    //
    //     return;
    //   }
    // }else if(gw ==2){
    //   if(
    //   players.where((element) => element.gw2!.isEmpty).toList().length >1){
    //     print('lolllllll11 22');
    //
    //     return;
    //   }
    // } else if(gw ==3){
    //   if(
    //   players.where((element) => element.gw2!.isEmpty).toList().length >1){
    //     print('lolllllll11 33');
    //
    //     return;
    //   }
    // }else if(gw ==4){
    //   if(
    //   players.where((element) => element.gw2!.isEmpty).toList().length >1){
    //     print('lolllllll11 44');
    //
    //     return;
    //   }
    // }else if(gw ==5){
    //   if(
    //   players.where((element) => element.gw2!.isEmpty).toList().length >1){
    //     print('lolllllll11 55');
    //
    //     return;
    //   }
    // }
    /*switch (gw) {
      // case 1:
      //   if ((players.where((element) => element.gw1!.isNotEmpty).toList().length !=
      //       players.length)) {
      //
      //     return;
      //   }
      //   break;
      case 2:
        if ((players
                .where((element) => element.gw2!.isNotEmpty)
                .toList()
                .length <
            players.length)) {
          print(
              'looooool= case 2 = you will not add after Add all players values');
          return;
        }
        break;
      case 3:
        if ((players
                .where((element) => element.gw3!.isNotEmpty)
                .toList()
                .length <
            players.length)) {
          print(
              'looooool= case 3 ==you will not add after Add all players values');
          return;
        }
        break;
      case 4:
        if ((players
                .where((element) => element.gw4!.isNotEmpty)
                .toList()
                .length ==
            players.length)) {
          print(
              'looooool= case 4 ==you will not add after Add all players values');
          return;
        }
        break;
      case 5:
        if ((players
                .where((element) => element.gw5!.isNotEmpty)
                .toList()
                .length ==
            players.length)) {
          print('looooool=you will not add after Add all players values');
          return;
        }
        break;
    }*/
  }

  List<GameModel> listGames = [];
  GenericCubit<List<GameModel>> jobsCubit = GenericCubit<List<GameModel>>();
  GenericCubit<bool> hideMarquee = GenericCubit<bool>(data: false);

  getSavedGames() async {
    String? res = await AppLocalStore.getString(LocalStoreNames.gamesHistory);

    final List<dynamic> jsonData = jsonDecode(res ?? '[]');

    listGames = jsonData.map<GameModel>((jsonItem) {
      return GameModel.fromJson(jsonItem);
    }).toList();

    jobsCubit.update(data: listGames.toList());
  }

  reloadGame(BuildContext context, Function? onPressed) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: "تحذير",
                fontSize: 18.sp,
                color: AppColors.mainColor,
              ),
              const SizedBox(height: 40),
              CustomText(text: "هل تريد اعادة بدأ الجولة", fontSize: 18.sp),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const CustomText(text: "لا", fontSize: 18),
                  ),
                  CustomButton(
                    width: 0.25.sw,
                    height: 40,
                    text: "نعم",
                    isButtonBorder: true,
                    onPressed: onPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  saveGame(List<PlayerModel> listPlayers, context) {
    if (listPlayers.last.gw5 != null &&
        listPlayers.last.gw5!.isNotEmpty &&
        listPlayers.first.gw5 != null &&
        listPlayers.first.gw5!.isNotEmpty) {
      listGames.add(GameModel(game: listPlayers));
      addGameToDB();
      Utilities().showCustomSnack(context, txt: "تم حفظ الجولة");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HistoryScreen()),
      // );
      // Navigator.pop(context);
      // AdManager().loadInterstitialAd();
    } else {
      return Utilities().showCustomSnack(
        context,
        txt: "لحفظ النتائج يجب ادخال جميع الجولات",
      );
    }
  }

  addGameToDB() async {
    AppLocalStore.setString(
      LocalStoreNames.gamesHistory,
      jsonEncode(listGames),
    );
  }
}
