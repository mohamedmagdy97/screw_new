import 'dart:io';

import 'package:screw_calculator/core/models/game_model.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:screw_calculator/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:screw_calculator/features/history/data/datasources/history_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required this.historyDataSource,
    required this.remoteDataSource,
  });

  /// يُعاد استخدام مصدر بيانات السجل لأن "حفظ الجولة" يضيف إلى نفس السجل.
  final HistoryDataSource historyDataSource;
  final DashboardRemoteDataSource remoteDataSource;

  @override
  Future<void> saveGame(List<PlayerModel> players) async {
    final games = await historyDataSource.getGames();
    games.add(GameModel(game: players));
    await historyDataSource.saveGames(games);
  }

  @override
  Future<void> uploadScreenshot(File file, {required String title}) {
    return remoteDataSource.uploadScreenshot(file, title: title);
  }
}
