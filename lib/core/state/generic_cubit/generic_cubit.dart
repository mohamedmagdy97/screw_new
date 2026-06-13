import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'generic_state.dart';

class GenericCubit<T> extends Cubit<GenericState<T>> {
  GenericCubit({T? data}) : super(GenericInitial<T>(data));

  void update({required T data}) {
    emit(GenericUpdate<T>(change: !state.change, data: data));
  }

  void reInitial({required T data}) {
    emit(GenericInitial<T>(data));
  }
}
