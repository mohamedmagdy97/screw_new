import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/dashboard/dashboard.dart';
import 'package:screw_calculator/features/history/data/datasources/history_data_source.dart';
import 'package:screw_calculator/features/history/data/repositories/history_repository_impl.dart';
import 'package:screw_calculator/features/history/domain/usecases/clear_all_games_usecase.dart';
import 'package:screw_calculator/features/history/domain/usecases/get_games_usecase.dart';
import 'package:screw_calculator/features/history/domain/usecases/remove_game_usecase.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/history/presentation/cubit/history_cubit.dart';
import 'package:screw_calculator/features/history/presentation/widgets/clear_all_confirmation_dialog.dart';
import 'package:screw_calculator/features/history/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:screw_calculator/features/history/presentation/widgets/history_item.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createHistoryCubit(),
      child: const _HistoryView(),
    );
  }

  /// Creates and configures HistoryCubit with all dependencies
  HistoryCubit _createHistoryCubit() {
    final dataSource = HistoryDataSourceImpl();
    final repository = HistoryRepositoryImpl(dataSource: dataSource);
    final getGamesUseCase = GetGamesUseCase(repository);
    final removeGameUseCase = RemoveGameUseCase(repository);
    final clearAllGamesUseCase = ClearAllGamesUseCase(repository);
    return HistoryCubit(
      getGamesUseCase: getGamesUseCase,
      removeGameUseCase: removeGameUseCase,
      clearAllGamesUseCase: clearAllGamesUseCase,
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  Future<void> _handleDeleteGame(BuildContext context, int index) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (_) => DeleteGameConfirmationDialog(gameIndex: index),
        ) ??
        false;

    if (shouldDelete) {
      context.read<HistoryCubit>().removeGame(index);
    }
  }

  Future<void> _handleClearAll(BuildContext context) async {
    final shouldClear =
        await showDialog<bool>(
          context: context,
          builder: (_) => const ClearAllConfirmationDialog(),
        ) ??
        false;

    if (shouldClear) {
      context.read<HistoryCubit>().clearAllGames();
    }
  }

  void _navigateToDashboard(BuildContext context, GameHistoryEntity game) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Dashboard(players: game.players, fromHistory: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الجولات السابقة',
        leading: IconButton(
          onPressed: () => _handleClearAll(context),
          icon: const Icon(Icons.delete_outline, color: AppColors.white),
        ),
      ),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryInitial || state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 4,
                backgroundColor: AppColors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
              ),
            );
          }

          if (state is HistoryEmpty) {
            return const Center(
              child: CustomText(
                text: 'لا يوجد سجلات سابقة',
                fontSize: 20,
                textAlign: TextAlign.end,
              ),
            );
          }

          if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  CustomText(text: state.message, fontSize: 16),
                ],
              ),
            );
          }

          if (state is HistoryLoaded ||
              state is HistoryDeleting ||
              state is HistoryClearing) {
            final games = state is HistoryLoaded
                ? state.games
                : state is HistoryDeleting
                ? state.games
                : (state as HistoryClearing).games;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                return HistoryItem(
                  game: games[index],
                  index: index,
                  onTap: () => _navigateToDashboard(context, games[index]),
                  onDelete: () => _handleDeleteGame(context, index),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.mainColor),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
