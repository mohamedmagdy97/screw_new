import 'package:flutter/material.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/widgets/app_header.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/widgets/classic_mode.dart';
import 'package:screw_calculator/features/home/presentation/widgets/drawer_widget.dart';
import 'package:screw_calculator/features/home/presentation/widgets/friends_mode.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final int index;

  const HomeScreen({super.key, required this.index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeData = sl<HomeController>();

  @override
  void initState() {
    homeData.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'gameMode-${widget.index}',
      child: Scaffold(
        key: homeData.scaffoldKey,
        appBar: AppHeader(
          title: AppLocalizations.of(context).appName,
          left: HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          right: HeaderIconButton(
            icon: Icons.menu_rounded,
            onTap: () => homeData.scaffoldKey.currentState!.openEndDrawer(),
          ),
        ),
        endDrawer: const DrawerWidget(),
        bottomNavigationBar: const BottomNavigationText(),
        body: Form(
          key: homeData.formKey,
          child: ModeClass.mode == GameModeEnum.classic
              ? const ClassicMode()
              : const FriendsMode(),
        ),
      ),
    );
  }
}
