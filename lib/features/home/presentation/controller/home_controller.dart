import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:screw_calculator/core/models/item.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/routing/build_fancy_route.dart';
import 'package:screw_calculator/core/state/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:screw_calculator/features/home/domain/repositories/home_repository.dart';

/// مُتحكّم الشاشة الرئيسية (طبقة العرض): يدير حالة النموذج والاختيارات والتنقّل،
/// ويفوّض عمليات البيانات (تسجيل/تحقق المستخدم) إلى [HomeRepository] بدل الوصول
/// المباشر لـ Firebase — تحقيقًا لمبدأ Dependency Inversion.
class HomeController {
  HomeController({required HomeRepository repository}) : _repository = repository;

  final HomeRepository _repository;

  final GenericCubit<List<Item>> listCubit = GenericCubit<List<Item>>(data: []);
  final GenericCubit<List<Item>> listTeamsCubit = GenericCubit<List<Item>>(
    data: [],
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyUserData = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController playerOne = TextEditingController();
  final TextEditingController playerTwo = TextEditingController();
  final TextEditingController playerThree = TextEditingController();
  final TextEditingController playerFour = TextEditingController();
  final TextEditingController playerFive = TextEditingController();
  final TextEditingController playerSix = TextEditingController();
  final TextEditingController playerOne2 = TextEditingController();
  final TextEditingController playerTwo2 = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final List<TextEditingController> controllers = List.generate(
    12,
    (_) => TextEditingController(),
  );

  String? userName;
  String? userPhone;
  String? userCountry;
  int? userAge;

  List<PlayerModel> players = [];

  void init() {
    classicInit();
    friendsInit();
    loadCachedUser();
    rateMyApp();
  }

  void loadCachedUser() {
    final user = _repository.getCachedUser();
    userName = user.name;
    userPhone = user.phone;
    userCountry = user.country;
    userAge = user.age;
  }

  Future<bool> canUserEnterChat({
    required String phone,
    required String name,
  }) => _repository.canEnterChat(phone: phone, name: name);

  Future<void> addUserDataToDB() async {
    userName = nameController.text;
    userPhone = phoneController.text;
    userCountry = countryController.text;
    userAge = int.tryParse(ageController.text);
    await _repository.registerUser(
      name: nameController.text,
      phone: phoneController.text,
      country: countryController.text,
      age: ageController.text,
    );
  }

  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
    required String age,
  }) => _repository.validateUser(name: name, phone: phone, country: country);

  void classicInit() {
    final items = List.generate(
      11,
      (index) => Item(key: index + 2, value: '${index + 2}'),
    );
    items.first.isActive = true;
    listCubit.update(data: items);
  }

  void friendsInit() {
    final items = List.generate(
      3,
      (index) => Item(key: index + 2, value: '${index + 2}'),
    );
    items.first.isActive = true;
    listTeamsCubit.update(data: items);
  }

  void onSelect(int index) {
    final items = listCubit.state.data!;
    for (final e in items) {
      e.isActive = false;
    }
    items[index].isActive = true;
    listCubit.update(data: items);
  }

  void onSelectTeam(int index) {
    final items = listTeamsCubit.state.data!;
    for (final e in items) {
      e.isActive = false;
    }
    items[index].isActive = true;
    listTeamsCubit.update(data: items);
  }

  Future<void> goToNext(BuildContext context, {bool teamsMode = false}) async {
    if (!formKey.currentState!.validate()) return;

    players = controllers
        .asMap()
        .entries
        .map((entry) => PlayerModel(id: entry.key + 1, name: entry.value.text))
        .where((player) => player.name!.isNotEmpty)
        .toList();

    final int playersCount = int.parse(
      (teamsMode ? listTeamsCubit : listCubit).state.data!
              .firstWhere((element) => element.isActive!)
              .value ??
          '2',
    );

    players.removeWhere((element) => element.id! > playersCount);

    await Navigator.push(
      context,
      buildFancyRoute(DashboardScreen(players: players, teamsMode: teamsMode)),
    );

    players.clear();
  }

  Future<void> goToNextTeams(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    players = [
      PlayerModel(id: 1, name: playerOne.text),
      PlayerModel(id: 2, name: playerTwo.text),
      PlayerModel(id: 3, name: playerThree.text),
      PlayerModel(id: 4, name: playerFour.text),
      PlayerModel(id: 5, name: playerFive.text),
      PlayerModel(id: 6, name: playerSix.text),
      PlayerModel(id: 7, name: playerOne2.text),
      PlayerModel(id: 8, name: playerTwo2.text),
    ]..removeWhere((e) => e.name!.isEmpty);

    final int teams = int.parse(
      listTeamsCubit.state.data!.firstWhere((e) => e.isActive!).value ?? '2',
    );
    final int playersCount = switch (teams) {
      2 => 4,
      3 => 6,
      4 => 8,
      _ => 4,
    };

    players.removeWhere((element) => element.id! > playersCount);

    await Navigator.of(
      context,
    ).push(buildFancyRoute(DashboardScreen(players: players, teamsMode: true)));
    players.clear();
  }

  /// يصفّر نتائج اللاعبين الحاليين (لإعادة بدء الجولة من لوحة النتائج).
  void clearValues() {
    for (final player in players) {
      player.resetRounds();
    }
  }

  Future<void> routeFromDrawer(BuildContext context, Widget widget) async {
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!context.mounted) return;
    await Navigator.of(context).push(buildFancyRoute(widget));
  }

  Future<void> rateMyApp() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }
}
