import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/features/home/data/datasources/home_local_data_source.dart';
import 'package:screw_calculator/features/home/data/datasources/home_remote_data_source.dart';
import 'package:screw_calculator/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  @override
  CachedUser getCachedUser() => localDataSource.getCachedUser();

  @override
  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
  }) {
    return remoteDataSource.validateUser(
      name: name,
      phone: phone,
      country: country,
    );
  }

  @override
  Future<void> registerUser({
    required String name,
    required String phone,
    required String country,
    required String age,
  }) async {
    await remoteDataSource.registerUser(
      name: name,
      phone: phone,
      country: country,
      age: int.tryParse(age) ?? 0,
    );
    await localDataSource.cacheUser(
      name: name,
      phone: phone,
      country: country,
      age: age,
    );
  }

  @override
  Future<bool> canEnterChat({required String phone, required String name}) {
    return remoteDataSource.canEnterChat(phone: phone, name: name);
  }
}
