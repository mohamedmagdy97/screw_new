import 'package:screw_calculator/features/history/data/datasources/history_data_source.dart';
import 'package:screw_calculator/features/history/data/mappers/game_history_mapper.dart';
import 'package:screw_calculator/features/history/domain/entities/game_history_entity.dart';
import 'package:screw_calculator/features/history/domain/repositories/history_repository.dart';

/// Implementation of HistoryRepository
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;
  List<GameHistoryEntity> _cachedGames = [];

  HistoryRepositoryImpl({
    required HistoryDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<GameHistoryEntity>> getGames() async {
    final models = await _dataSource.getGames();
    _cachedGames = models.map((model) => GameHistoryMapper.toEntity(model)).toList();
    return _cachedGames;
  }

  @override
  Future<bool> removeGame(int index) async {
    if (index < 0 || index >= _cachedGames.length) {
      return false;
    }

    _cachedGames.removeAt(index);
    
    // Convert back to models and save
    final models = _cachedGames.map((e) => GameHistoryMapper.toModel(e)).toList();
    return await _dataSource.saveGames(models);
  }

  @override
  Future<bool> clearAllGames() async {
    _cachedGames.clear();
    return await _dataSource.clearAllGames();
  }
}

