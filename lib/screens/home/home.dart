import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/home/home_data.dart';
import 'package:screw_calculator/screens/home/widgets/classic_mode.dart';
import 'package:screw_calculator/screens/home/widgets/drawer_widget.dart';
import 'package:screw_calculator/screens/home/widgets/friends_mode.dart';
import 'package:screw_calculator/utility/Enums.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // WidgetsBinding.instance.addObserver(
    //   LifecycleEventHandler(
    //     resumeCallBack: () async => setState(
    //           () {
    //         // print('looooooooooool ===');
    //       },
    //     ),
    //   ),
    // );
    homeData.init();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // final AdSize adSize = const AdSize(width: 300, height: 50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeData.scaffoldKey,
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.grayy,
          title: CustomText(text: "سكرو حاسبة", fontSize: 22.sp),
          actions: [
            InkWell(
              onTap: () => homeData.scaffoldKey.currentState!.openEndDrawer(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ]),
      endDrawer: const DrawerWidget(),
      backgroundColor: AppColors.bg,
      body: Form(
          key: homeData.formKey,
          child: ModeClass.mode == GameMode.classic
              ? const ClassicMode()
              : const FriendsMode()),
    );
  }
}