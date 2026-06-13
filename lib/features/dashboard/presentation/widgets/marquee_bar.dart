import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/marquee_widget.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';

/// شريط الأذكار المتحرك أعلى لوحة النتائج (قابل للإخفاء).
class MarqueeBar extends StatelessWidget {
  const MarqueeBar({super.key});

  static const String _dhikr =
      '      صلي على النبي, لا اله الا الله وحده لا شريك له, له الملك وله الحمد '
      'يحي ويميت وهو على كل شيء قدير, سبحان الله والحمد لله ولا اله الا الله ولا '
      'حول ولا قوة الا بالله, استغفر الله العظيم وأتوب اليه, لا اله الا انت '
      'سبحانك اني كنت من الظالمين     ';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (a, b) => a.marqueeVisible != b.marqueeVisible,
      builder: (context, state) {
        if (!state.marqueeVisible) return const SizedBox.shrink();
        final palette = context.palette;
        return Container(
          width: 1.sw,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: palette.brand.withValues(alpha: 0.12),
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: MarqueeWidget(
                  child: CustomText(
                    text: _dhikr,
                    fontSize: 16,
                    color: palette.brandSoft,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.read<DashboardCubit>().hideMarquee(),
                icon: Icon(Icons.close, color: palette.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}
