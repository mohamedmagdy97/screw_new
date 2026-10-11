import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/app_header.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/skeleton.dart';
import 'package:screw_calculator/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/history/presentation/cubit/history_cubit.dart';
import 'package:screw_calculator/features/history/presentation/widgets/history_item.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryCubit>(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  Future<void> _handleDeleteGame(BuildContext context, int index) async {
    final shouldDelete =
        await showAppConfirmDialog(
          context,
          icon: Icons.delete_outline_rounded,
          tone: AppDialogTone.danger,
          title: AppLocalizations.of(context).warning,
          message: AppLocalizations.of(context).deleteGameWarning(index + 1),
        ) ??
        false;

    if (shouldDelete && context.mounted) {
      context.read<HistoryCubit>().removeGame(index);
    }
  }

  Future<void> _handleClearAll(BuildContext context) async {
    final shouldClear =
        await showAppConfirmDialog(
          context,
          icon: Icons.delete_sweep_rounded,
          tone: AppDialogTone.danger,
          title: AppLocalizations.of(context).warning,
          message: AppLocalizations.of(context).clearAllWarning,
        ) ??
        false;

    if (shouldClear && context.mounted) {
      context.read<HistoryCubit>().clearAllGames();
    }
  }

  void _navigateToDashboardScreen(
    BuildContext context,
    GameHistoryEntity game,
  ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            DashboardScreen(players: game.players, fromHistory: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).historyTitle,
        leading: HeaderIconButton(
          icon: Icons.delete_sweep_rounded,
          onTap: () => _handleClearAll(context),
        ),
      ),
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryInitial || state is HistoryLoading) {
            return const SkeletonList();
          }

          if (state is HistoryEmpty) {
            return Center(
              child: CustomText(
                text: AppLocalizations.of(context).historyEmpty,
                fontSize: 20,
                textAlign: context.readStart,
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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                return HistoryItem(
                  game: games[index],
                  index: index,
                  onTap: () =>
                      _navigateToDashboardScreen(context, games[index]),
                  onDelete: () => _handleDeleteGame(context, index),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
