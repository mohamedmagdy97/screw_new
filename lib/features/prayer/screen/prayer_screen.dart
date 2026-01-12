import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/features/prayer/controllers/prayer_controller.dart';
import 'package:screw_calculator/features/prayer/core/notification_service.dart';
import 'package:screw_calculator/features/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/features/prayer/data/models/prayer_time_model.dart';
import 'package:screw_calculator/features/prayer/screen/widget/build_card_widget.dart';
import 'package:screw_calculator/features/prayer/screen/widget/build_city_selector.dart';
import 'package:screw_calculator/features/prayer/screen/widget/build_next_prayer_card.dart';
import 'package:screw_calculator/features/prayer/screen/widget/build_notification_setting_dialog.dart';
import 'package:screw_calculator/helpers/remote_config.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late final PrayerController controller;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PrayerController())..loadPrayerTimes();

    NotificationService.init();

    // تحديث الوقت المتبقي كل دقيقة
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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'مواقيت الصلاة',
        leading: Row(
          children: [
            if (RemoteConfig().enableCacheView())
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 24.sp,
                  color: AppColors.white,
                ),
                onPressed: _showCacheInfoDialog,
              ),
            IconButton(
              icon: Icon(
                size: 24.sp,
                Icons.notifications_outlined,
                color: AppColors.white,
              ),
              onPressed: _showNotificationSettings,
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: Obx(_buildBody),
    );
  }

  // بناء محتوى الشاشة
  Widget _buildBody() {
    if (controller.isLoading.value) {
      return _buildLoadingState();
    }

    if (controller.hasError.value) {
      return _buildErrorState();
    }

    final data = controller.prayerTimes.value;

    return Column(
      children: [
        BuildCitySelector(controller: controller),
        if (data != null) ...[
          BuildNextPrayerCard(data: data),
          Expanded(child: _buildPrayersList(data)),
        ] else
          _buildEmptyState(),
      ],
    );
  }

  // حالة التحميل
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

  // حالة الخطأ
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          CustomText(
            text: controller.errorMessage.value,
            fontSize: 16,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.retry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // حالة فارغة
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

  // قائمة المواقيت
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

  // تنسيق الوقت المتبقي
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '--';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return 'متبقي $hours ساعة و$minutes دقيقة';
      }
      return 'متبقي $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    }

    if (minutes > 0) {
      return 'متبقي $minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}';
    }

    if (seconds > 0) {
      return 'متبقي $seconds ${seconds == 1 ? 'ثانية' : 'ثواني'}';
    }

    return 'الآن';
  }

  // إعدادات الإشعارات
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          BuildNotificationSettingsDialog(controller: controller),
    );
  }

  // عرض معلومات الكاش
  void _showCacheInfoDialog() async {
    final info = await controller.apiService.getCacheInfo();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'معلومات الكاش',
          fontSize: 18,
          fontFamily: AppFonts.bold,
          color: AppColors.grayy,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildInfoRow(
              label: 'إجمالي المدخلات',
              value: '${info.totalEntries}',
            ),
            BuildInfoRow(
              label: 'البيانات المحفوظة',
              value: '${info.dataEntries}',
            ),
            BuildInfoRow(
              label: 'البيانات الصالحة',
              value: '${info.validEntries}',
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            BuildInfoRow(
              label: 'أقدم بيانات',
              value: _formatAge(
                DateTime.now().difference(info.oldestCacheDate),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => BuildInfoRow(
                label: 'حالة الاتصال',
                value: controller.isOnline.value ? 'متصل' : 'غير متصل',
                valueColor: controller.isOnline.value
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText(
              text: 'إغلاق',
              fontSize: 14,
              color: AppColors.grayy2,
              fontFamily: AppFonts.bold,
            ),
          ),
          TextButton(
            onPressed: () async {
              await controller.clearCache();
              if (context.mounted) Navigator.pop(context);
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
