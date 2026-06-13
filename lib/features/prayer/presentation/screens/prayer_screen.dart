import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/helpers/remote_config.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/features/prayer/data/models/prayer_time_model.dart';
import 'package:screw_calculator/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:screw_calculator/features/prayer/presentation/widgets/build_card_widget.dart';
import 'package:screw_calculator/features/prayer/presentation/widgets/build_city_selector.dart';
import 'package:screw_calculator/features/prayer/presentation/widgets/build_next_prayer_card.dart';
import 'package:screw_calculator/features/prayer/presentation/widgets/build_notification_setting_dialog.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PrayerCubit>(
      create: (_) => sl<PrayerCubit>()..init(),
      child: const _PrayerView(),
    );
  }
}

class _PrayerView extends StatefulWidget {
  const _PrayerView();

  @override
  State<_PrayerView> createState() => _PrayerViewState();
}

class _PrayerViewState extends State<_PrayerView> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // تحديث الوقت المتبقي للصلاة القادمة كل دقيقة.
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerCubit>();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'مواقيت الصلاة',
        leading: Row(
          children: [
            if (RemoteConfig().enableCacheView())
              IconButton(
                icon: Icon(Icons.info_outline, size: 24.sp, color: AppColors.white),
                onPressed: () => _showCacheInfoDialog(cubit),
              ),
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: 24.sp,
                color: AppColors.white,
              ),
              onPressed: () => _showNotificationSettings(cubit),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocBuilder<PrayerCubit, PrayerState>(
        builder: (context, state) => _buildBody(cubit, state),
      ),
    );
  }

  Widget _buildBody(PrayerCubit cubit, PrayerState state) {
    if (state.status == PrayerStatus.loading) return _buildLoadingState();
    if (state.status == PrayerStatus.error) return _buildErrorState(cubit, state);

    final data = state.prayerTimes;
    return Column(
      children: [
        BuildCitySelector(cubit: cubit),
        if (data != null) ...[
          BuildNextPrayerCard(data: data),
          Expanded(child: _buildPrayersList(data)),
        ] else
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          CustomText(text: 'جاري تحميل مواقيت الصلاة...', fontSize: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(PrayerCubit cubit, PrayerState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          CustomText(text: state.errorMessage, fontSize: 16, color: Colors.red),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: cubit.retry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            CustomText(text: 'اختر مدينة لعرض المواقيت', fontSize: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayersList(PrayerTimeModel data) {
    final currentPrayer = PrayerTimeModelExtension(data).getCurrentPrayer();
    final nextPrayer = PrayerTimeModelExtension(data).getNextPrayer();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        BuildPrayerCard(
          title: 'الفجر',
          time: data.fajr,
          icon: Icons.wb_twilight,
          isCurrent: currentPrayer == 'الفجر',
          isNext: nextPrayer == 'الفجر',
        ),
        BuildPrayerCard(
          title: 'الظهر',
          time: data.dhuhr,
          icon: Icons.wb_sunny,
          isCurrent: currentPrayer == 'الظهر',
          isNext: nextPrayer == 'الظهر',
        ),
        BuildPrayerCard(
          title: 'العصر',
          time: data.asr,
          icon: Icons.cloud,
          isCurrent: currentPrayer == 'العصر',
          isNext: nextPrayer == 'العصر',
        ),
        BuildPrayerCard(
          title: 'المغرب',
          time: data.maghrib,
          icon: Icons.nights_stay,
          isCurrent: currentPrayer == 'المغرب',
          isNext: nextPrayer == 'المغرب',
        ),
        BuildPrayerCard(
          title: 'العشاء',
          time: data.isha,
          icon: Icons.bedtime,
          isCurrent: currentPrayer == 'العشاء',
          isNext: nextPrayer == 'العشاء',
        ),
      ],
    );
  }

  void _showNotificationSettings(PrayerCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => BuildNotificationSettingsDialog(cubit: cubit),
    );
  }

  Future<void> _showCacheInfoDialog(PrayerCubit cubit) async {
    final info = await cubit.apiService.getCacheInfo();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const CustomText(
          text: 'معلومات الكاش',
          fontSize: 18,
          fontFamily: AppFonts.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildInfoRow(label: 'إجمالي المدخلات', value: '${info.totalEntries}'),
            BuildInfoRow(label: 'البيانات المحفوظة', value: '${info.dataEntries}'),
            BuildInfoRow(label: 'البيانات الصالحة', value: '${info.validEntries}'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            BuildInfoRow(
              label: 'أقدم بيانات',
              value: _formatAge(DateTime.now().difference(info.oldestCacheDate)),
            ),
            const SizedBox(height: 8),
            BuildInfoRow(
              label: 'حالة الاتصال',
              value: cubit.state.isOnline ? 'متصل' : 'غير متصل',
              valueColor: cubit.state.isOnline ? Colors.green : Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const CustomText(
              text: 'إغلاق',
              fontSize: 14,
              color: AppColors.grayy2,
              fontFamily: AppFonts.bold,
            ),
          ),
          TextButton(
            onPressed: () async {
              await cubit.clearCache();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const CustomText(
              text: 'مسح الكاش',
              fontSize: 14,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAge(Duration age) {
    if (age.inDays > 0) return 'منذ ${age.inDays} يوم';
    if (age.inHours > 0) return 'منذ ${age.inHours} ساعة';
    if (age.inMinutes > 0) return 'منذ ${age.inMinutes} دقيقة';
    return 'الآن';
  }
}

class BuildInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const BuildInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: value,
            fontSize: 14,
            color: valueColor ?? Colors.black,
            fontFamily: AppFonts.bold,
          ),
          CustomText(text: label, fontSize: 14, color: AppColors.grayy2),
        ],
      ),
    );
  }
}
