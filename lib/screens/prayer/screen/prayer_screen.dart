import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/prayer/controllers/prayer_controller.dart';
import 'package:screw_calculator/screens/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/screens/prayer/data/models/country_model.dart';
import 'package:screw_calculator/screens/prayer/screen/widget/build_card_widget.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final PrayerController controller = Get.put(
    PrayerController(PrayerApiService()),
  );

  @override
  void initState() {
    controller.loadPrayerTimes();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'مواقيت الصلاة', fontSize: 22.sp),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Transform.flip(
              flipX: true,
              child: const Icon(
                Icons.arrow_back_ios_sharp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = controller.prayerTimes.value;
        if (data == null) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CustomText(text: 'اختر مدينة', fontSize: 22),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(8),
                width: 1.sw,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mainColor,
                      AppColors.mainColor.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DropdownButton<CountryModel>(
                  value: controller.city,
                  borderRadius: BorderRadius.circular(12),
                  icon: const SizedBox(),
                  isExpanded: true,
                  underline: const SizedBox(),
                  alignment: Alignment.centerLeft,
                  dropdownColor: AppColors.mainColor,
                  items:
                      // ['Cairo', 'Alexandria', 'Giza', 'Mansoura']
                      controller.egyptGovernorates
                          .map(
                            (c) => DropdownMenuItem(
                              alignment: Alignment.centerRight,
                              value: c,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.white,
                                  ),
                                  CustomText(text: c.nameAr, fontSize: 22),
                                ],
                              ),
                            ),
                          )
                          .toList(),

                  onChanged: (v) {
                    controller.selectedCity = v!;
                    controller.city = v;
                    AppLocalStore.setString(LocalStoreNames.prayerCity, v.nameEn);

                    controller.loadPrayerTimes();
                  },
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                width: 1.sw,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mainColor,
                      AppColors.mainColor.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DropdownButton<CountryModel>(
                  value: controller.city,
                  borderRadius: BorderRadius.circular(12),
                  icon: const SizedBox(),
                  isExpanded: true,
                  underline: const SizedBox(),
                  menuMaxHeight: 0.75.sh,
                  alignment: Alignment.centerLeft,
                  dropdownColor: AppColors.mainColor,
                  items:
                      // ['Cairo', 'Alexandria', 'Giza', 'Mansoura']
                      controller.egyptGovernorates
                          .map(
                            (c) => DropdownMenuItem(
                              alignment: Alignment.centerRight,
                              value: c,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.white,
                                  ),
                                  CustomText(text: c.nameAr, fontSize: 22),
                                ],
                              ),
                            ),
                          )
                          .toList(),

                  onChanged: (v) {
                    controller.selectedCity = v!;
                    controller.city = v;
                    AppLocalStore.setString(LocalStoreNames.prayerCity, v.nameEn);
                    controller.loadPrayerTimes();
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    BuildCardWidget('الفجر', data!.fajr),
                    BuildCardWidget('الظهر', data.dhuhr),
                    BuildCardWidget('العصر', data.asr),
                    BuildCardWidget('المغرب', data.maghrib),
                    BuildCardWidget('العشاء', data.isha),
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
