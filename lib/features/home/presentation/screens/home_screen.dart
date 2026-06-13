import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/features/home/presentation/widgets/classic_mode.dart';
import 'package:screw_calculator/features/home/presentation/widgets/drawer_widget.dart';
import 'package:screw_calculator/features/home/presentation/widgets/friends_mode.dart';

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
        appBar: AppBar(
          centerTitle: true,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.back, color: Colors.white),
            ),
          ),
          backgroundColor: AppColors.grayy,
          title: CustomText(text: 'سكرو حاسبة', fontSize: 22.sp),
          actions: [
            InkWell(
              onTap: () => homeData.scaffoldKey.currentState!.openEndDrawer(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ],
        ),
        endDrawer: const DrawerWidget(),
        backgroundColor: AppColors.bg,
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
