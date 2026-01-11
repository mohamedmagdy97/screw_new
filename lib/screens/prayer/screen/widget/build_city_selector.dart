import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/prayer/controllers/prayer_controller.dart';
import 'package:screw_calculator/screens/prayer/data/models/country_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class BuildCitySelector extends StatelessWidget {
  const BuildCitySelector({super.key, required this.controller});

  final PrayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.mainColor, AppColors.mainColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.white),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<CountryModel>(
              value: controller.city,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.white),
              isExpanded: true,
              underline: const SizedBox(),
              menuMaxHeight: 0.75.sh,
              dropdownColor: AppColors.mainColor,
              items: controller.egyptGovernorates
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: CustomText(
                        text: c.nameAr,
                        fontSize: 18,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  controller.changeCity(v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
