import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/game_mode/domain/item.dart';
import 'package:screw_calculator/utility/Enums.dart';
import 'package:screw_calculator/utility/utilities.dart';

class GameModeState {
  final List<Item> items;
  final bool isLoading;

  GameModeState({required this.items, this.isLoading = false});

  GameModeState copyWith({List<Item>? items, bool? isLoading}) {
    return GameModeState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GameModeCubit extends Cubit<GameModeState> {
  GameModeCubit()
    : super(
        GameModeState(
          items: List.generate(2, (i) {
            return i == 0
                ? Item(value: "كلاسيك\n (فردي)", isActive: true)
                : Item(value: "صاحب صاحبه\n (زوجي)");
          }),
        ),
      );
  DateTime? currentBackPressTime;

  void toggleItem(int index) {
    final List<Item> updated;
    if (index == 0) {
      ModeClass.mode = GameMode.classic;
      updated = state.items
          .asMap()
          .entries
          .map(
            (e) => e.key == index
                ? e.value.copyWith(isActive: !e.value.isActive!)
                : e.value.copyWith(isActive: false),
          )
          .toList();
    } else {
      ModeClass.mode = GameMode.friendly;
      updated = state.items
          .asMap()
          .entries
          .map(
            (e) => e.key == index
                ? e.value.copyWith(isActive: !e.value.isActive!)
                : e.value.copyWith(isActive: false),
          )
          .toList();
    }

    emit(state.copyWith(items: updated));
  }

  Future<bool> onWillPop(BuildContext context) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Utilities().customSnackBarTerms(context, txt: "للخروج اضغط مرتين ");
      return Future.value(false);
    }
    return Future.value(true);
  }
}
