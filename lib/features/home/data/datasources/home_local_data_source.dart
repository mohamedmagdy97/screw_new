import 'package:hive/hive.dart';

/// بيانات المستخدم المخزّنة محليًا.
class CachedUser {
  const CachedUser({this.name, this.phone, this.country});

  final String? name;
  final String? phone;
  final String? country;
}

/// تخزين/قراءة بيانات المستخدم محليًا في Hive.
abstract class HomeLocalDataSource {
  CachedUser getCachedUser();

  Future<void> cacheUser({
    required String name,
    required String phone,
    required String country,
  });
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  HomeLocalDataSourceImpl({required this.userBox});

  final Box<dynamic> userBox;

  @override
  CachedUser getCachedUser() {
    return CachedUser(
      name: userBox.get('name')?.toString(),
      phone: userBox.get('phone')?.toString(),
      country: userBox.get('country')?.toString(),
    );
  }

  @override
  Future<void> cacheUser({
    required String name,
    required String phone,
    required String country,
  }) async {
    await userBox.putAll({'name': name, 'phone': phone, 'country': country});
    // السن ما بقاش بيتطلب؛ نمسح أي قيمة قديمة.
    await userBox.delete('age');
  }
}
