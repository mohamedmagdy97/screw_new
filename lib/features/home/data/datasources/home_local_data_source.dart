import 'package:hive/hive.dart';

/// بيانات المستخدم المخزّنة محليًا.
class CachedUser {
  const CachedUser({this.name, this.phone, this.country, this.age});

  final String? name;
  final String? phone;
  final String? country;
  final int? age;
}

/// تخزين/قراءة بيانات المستخدم محليًا في Hive.
abstract class HomeLocalDataSource {
  CachedUser getCachedUser();

  Future<void> cacheUser({
    required String name,
    required String phone,
    required String country,
    required String age,
  });
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  HomeLocalDataSourceImpl({required this.userBox});

  final Box userBox;

  @override
  CachedUser getCachedUser() {
    return CachedUser(
      name: userBox.get('name')?.toString(),
      phone: userBox.get('phone')?.toString(),
      country: userBox.get('country')?.toString(),
      age: int.tryParse((userBox.get('age') ?? '').toString()),
    );
  }

  @override
  Future<void> cacheUser({
    required String name,
    required String phone,
    required String country,
    required String age,
  }) async {
    await userBox.putAll({
      'name': name,
      'phone': phone,
      'country': country,
      'age': age,
    });
  }
}
