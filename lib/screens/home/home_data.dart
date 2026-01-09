import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:screw_calculator/components/build_fancy_route.dart';
import 'package:screw_calculator/cubits/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/helpers/device_info.dart';
import 'package:screw_calculator/models/item.dart';
import 'package:screw_calculator/models/player_model.dart';
import 'package:screw_calculator/screens/dashboard/dashboard.dart';
import 'package:screw_calculator/utility/Enums.dart';
import 'package:uuid/uuid.dart';

HomeData homeData = HomeData();

class HomeData {
  GenericCubit<List<Item>> listCubit = GenericCubit<List<Item>>(data: []);
  GenericCubit<List<Item>> listTeamsCubit = GenericCubit<List<Item>>(data: []);

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
  final Box userBox = Hive.box('userBox');

  String? userName;
  String? userPhone;
  String? userCountry;

  final List<TextEditingController> controllers = List.generate(
    12,
    (_) => TextEditingController(),
  );

  List<PlayerModel> players = [];
  DateTime? currentBackPressTime;
  GenericCubit<bool> isLoadedCubit = GenericCubit(data: false);

  void init() {
    classicInit();
    friendsInit();
    initChatData();
    rateMyApp();
  }

  initChatData() {
    userName = userBox.get('name')?.toString();
    userPhone = userBox.get('phone')?.toString();
    userCountry = userBox.get('country')?.toString();
  }

  Future<void> addUserDataToDB() async {
    userBox.put('name', nameController.text);
    userBox.put('phone', phoneController.text);
    userBox.put('country', countryController.text);

    userName = nameController.text;
    userPhone = phoneController.text;
    userCountry = countryController.text;
    // final id = const Uuid().v4();

    final userData = {
      'id': userPhone,
      'userName': userName,
      'userPhone': userPhone,
      'userCountry': userCountry,
      'deviceName': await getDeviceName(),
      'datetime': DateTime.now(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('chats')
        .doc('users')
        .collection('users')
        .doc(userPhone)
        .set(userData);
  }

  Future<UserValidationResult> validateUser({
    required String name,
    required String phone,
    required String country,
  }) async {
    final queryName = await FirebaseFirestore.instance
        .collection('chats')
        .doc('users')
        .collection('users')
        // .where('userPhone', isEqualTo: phone)
        .where('userName', isEqualTo: name)
        .limit(1)
        .get();
    final queryPhone = await FirebaseFirestore.instance
        .collection('chats')
        .doc('users')
        .collection('users')
        .where('userPhone', isEqualTo: phone)
        // .where('userName', isEqualTo: name)
        .limit(1)
        .get();

    final query = await FirebaseFirestore.instance
        .collection('chats')
        .doc('users')
        .collection('users')
        .where('userPhone', isEqualTo: phone)
        .where('userName', isEqualTo: name)
        .limit(1)
        .get();

    if (queryName.docs.isEmpty && queryPhone.docs.isEmpty) {
      return UserValidationResult.notExists;
    } else if (queryName.docs.isNotEmpty && queryPhone.docs.isEmpty) {
      return UserValidationResult.existsName;
    } else if (queryPhone.docs.isNotEmpty && queryName.docs.isEmpty) {
      return UserValidationResult.existsNumber;
    }

    final data = query.docs.first.data();
    final storedCountry = data['userCountry']?.toString().trim();

    if (storedCountry == country.trim()) {
      return UserValidationResult.existsAndValidOwner;
    }

    return UserValidationResult.existsButInvalidCountry;
  }

  void classicInit() {
    listCubit.update(
      data: List.generate(
        11,
        (index) => Item(key: index + 2, value: '${index + 2}', isActive: false),
      ),
    );

    listCubit.state.data!.first.isActive = true;
    listCubit.update(data: listCubit.state.data!);
  }

  void friendsInit() {
    listTeamsCubit.update(
      data: List.generate(
        3,
        (index) => Item(key: index + 2, value: '${index + 2}', isActive: false),
      ),
    );

    listTeamsCubit.state.data!.first.isActive = true;
    listTeamsCubit.update(data: listTeamsCubit.state.data!);
  }

  void onSelect(int index) {
    for (var e in listCubit.state.data!) {
      e.isActive = false;
    }
    listCubit.state.data![index].isActive = true;
    listCubit.update(data: listCubit.state.data!);
  }

  void onSelectTeam(int index) {
    for (var e in listTeamsCubit.state.data!) {
      e.isActive = false;
    }
    listTeamsCubit.state.data![index].isActive = true;
    listTeamsCubit.update(data: listTeamsCubit.state.data!);
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
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Dashboard(players: players, teamsMode: teamsMode), // false
          ),
        ),
      ),
    );

    players.clear();
  }

  Future<void> goToNextTeams(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    players.add(PlayerModel(id: 1, name: playerOne.text));
    players.add(PlayerModel(id: 2, name: playerTwo.text));
    players.add(PlayerModel(id: 3, name: playerThree.text));
    players.add(PlayerModel(id: 4, name: playerFour.text));
    players.add(PlayerModel(id: 5, name: playerFive.text));
    players.add(PlayerModel(id: 6, name: playerSix.text));
    players.add(PlayerModel(id: 7, name: playerOne2.text));
    players.add(PlayerModel(id: 8, name: playerTwo2.text));

    players.removeWhere((e) => e.name!.isEmpty);

    int playersCount;
    switch (int.parse(
      listTeamsCubit.state.data!
              .where((element) => element.isActive!)
              .toList()[0]
              .value ??
          '2',
    )) {
      case 2:
        playersCount = 4;
        break;
      case 3:
        playersCount = 6;
        break;
      case 4:
        playersCount = 8;
        break;
      default:
        playersCount = 4;
        return;
    }

    players.removeWhere((element) => element.id! > playersCount);

    /* bool res = */

    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Dashboard(players: players, teamsMode: true),
          ),
        ),
      ),
    );
    players.clear();
  }

  void showSnackBar(String content, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void clearValues() {
    players.forEach((element) {
      element.gw1 = '';
      element.gw2 = '';
      element.gw3 = '';
      element.gw4 = '';
      element.gw5 = '';
      element.total = '0';
    });
  }

  void routeFromDrawer(BuildContext context, Widget widget) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 250));

    Navigator.of(context).push(buildFancyRoute(widget));
  }

  Future<void> rateMyApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }
}
