import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/prayer/data/models/country_model.dart';
import 'package:screw_calculator/features/prayer/presentation/cubit/prayer_cubit.dart';

class BuildCitySelector extends StatelessWidget {
  const BuildCitySelector({super.key, required this.cubit});

  final PrayerCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        gradient: LinearGradient(
          colors: [
            AppColors.mainColor,
            AppColors.mainColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withValues(alpha: 0.3),
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
              value: cubit.state.selectedCity,
              borderRadius: BorderRadius.circular(AppRadii.md),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.white),
              isExpanded: true,
              underline: const SizedBox(),
              menuMaxHeight: 0.75.sh,
              dropdownColor: AppColors.mainColor,
              items: cubit.egyptGovernorates
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
                if (v != null) cubit.changeCity(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
