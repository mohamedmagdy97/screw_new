import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/prayer/controllers/prayer_controller.dart';
import 'package:screw_calculator/screens/prayer/core/notification_service.dart';
import 'package:screw_calculator/screens/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/screens/prayer/data/models/country_model.dart';
import 'package:screw_calculator/screens/prayer/data/models/prayer_time_model.dart';
import 'package:screw_calculator/screens/prayer/screen/widget/build_card_widget.dart';
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
      appBar: _buildAppBar(),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: Obx(_buildBody),
    );
  }

  // بناء AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.grayy,
      title: CustomText(text: 'مواقيت الصلاة', fontSize: 22.sp),
      leadingWidth: 105.w,
      leading: Row(
        children: [
          IconButton(
            icon: Icon(
              size: 24.sp,
              Icons.notifications_outlined,
              color: AppColors.white,
            ),
            onPressed: _showNotificationSettings,
          ),
          IconButton(
            icon: Icon(Icons.info_outline, size: 24.sp, color: AppColors.white),
            onPressed: _showCacheInfoDialog,
          ),
        ],
      ),
      actions: [
        // زر معلومات الكاش
        // IconButton(
        //   icon: const Icon(Icons.info_outline, color: AppColors.white),
        //   onPressed: _showCacheInfoDialog,
        // ),
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
        _buildCitySelector(),
        if (data != null) ...[
          _buildNextPrayerCard(data),
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

  // محدد المدينة
  Widget _buildCitySelector() {
    return Container(
      margin: const EdgeInsets.all(16),
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

  // كارت الصلاة القادمة
  Widget _buildNextPrayerCard(PrayerTimeModel data) {
    final nextPrayer = _getNextPrayer(data);
    final remaining = nextPrayer['remaining'] ?? '--';
    final isComingSoon =
        remaining.contains('دقيقة') || remaining.contains('ثانية');

    return Container(
      margin: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComingSoon
              ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)]
              : [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isComingSoon ? Colors.red : Colors.blue).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isComingSoon ? Icons.notifications_active : Icons.access_time,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              const CustomText(
                text: 'الصلاة القادمة',
                fontSize: 14,
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(
            text: nextPrayer['name'] ?? '--',
            fontSize: 28,
            fontFamily: AppFonts.bold,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              text: nextPrayer['time'] ?? '--:--',
              fontSize: 28,
              fontFamily: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isComingSoon
                      ? Icons.warning_amber_rounded
                      : Icons.timer_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                CustomText(
                  text: remaining,
                  fontSize: 14,
                  fontFamily: AppFonts.bold,
                ),
              ],
            ),
          ),
        ],
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
        _buildPrayerCard(
          'الفجر',
          data.fajr,
          Icons.wb_twilight,
          isCurrent: currentPrayer == 'الفجر',
          isNext: nextPrayer == 'الفجر',
        ),

        _buildPrayerCard(
          'الظهر',
          data.dhuhr,
          Icons.wb_sunny,
          isCurrent: currentPrayer == 'الظهر',
          isNext: nextPrayer == 'الظهر',
        ),
        _buildPrayerCard(
          'العصر',
          data.asr,
          Icons.cloud,
          isCurrent: currentPrayer == 'العصر',
          isNext: nextPrayer == 'العصر',
        ),
        _buildPrayerCard(
          'المغرب',
          data.maghrib,
          Icons.nights_stay,
          isCurrent: currentPrayer == 'المغرب',
          isNext: nextPrayer == 'المغرب',
        ),
        _buildPrayerCard(
          'العشاء',
          data.isha,
          Icons.bedtime,
          isCurrent: currentPrayer == 'العشاء',
          isNext: nextPrayer == 'العشاء',
        ),
      ],
    );
  }

  // كارت الصلاة مع تحسينات
  Widget _buildPrayerCard(
    String title,
    String time,
    IconData icon, {
    bool isCurrent = false,
    bool isNext = false,
    bool isInfo = false,
  }) {
    Color cardColor = Colors.white;
    Color textColor = AppColors.black;
    Color iconColor = AppColors.mainColor;
    Widget? badge;

    if (isCurrent) {
      cardColor = AppColors.mainColorAccent.withOpacity(0.15);
      iconColor = AppColors.mainColor;
      textColor = AppColors.white;
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CustomText(
          text: 'الآن',
          fontFamily: AppFonts.bold,
          fontSize: 10,
        ),
      );
    } else if (isNext) {
      cardColor = Colors.blue[50]!;
      iconColor = Colors.blue[700]!;
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(8),
        ),

        child: const CustomText(
          text: 'القادمة',
          fontFamily: AppFonts.bold,
          fontSize: 10,
        ),
      );
    } else if (isInfo) {
      cardColor = Colors.grey[100]!;
      iconColor = Colors.grey[600]!;
      textColor = Colors.grey[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: (isCurrent || isNext)
            ? Border.all(
                color: isCurrent ? AppColors.mainColor : Colors.blue[700]!,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          CustomText(
            text: time,
            fontSize: 24,
            fontFamily: AppFonts.bold,
            color: isCurrent || isNext ? iconColor : AppColors.mainColor,
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (badge != null) badge,
                const SizedBox(width: 8),

                CustomText(
                  text: title,
                  fontSize: 18,
                  fontFamily: AppFonts.bold,
                  textAlign: TextAlign.right,
                  color: textColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }

  // حساب الصلاة القادمة
  Map<String, String> _getNextPrayer(PrayerTimeModel data) {
    try {
      // استخدام الدالة المحسنة من Model
      return data.getNextPrayerInfo();
    } catch (e) {
      debugPrint('❌ Error in _getNextPrayer: $e');
      return {'name': 'الفجر', 'time': data.fajr, 'remaining': '--'};
    }
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomText(
              text: 'إعدادات الإشعارات',
              fontSize: 20,
              fontFamily: AppFonts.bold,
              color: AppColors.black,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.notification_add),
              title: const CustomText(
                text: 'اختبار الإشعار',
                fontSize: 14,
                color: AppColors.black,
                textAlign: TextAlign.end,
              ),
              onTap: () {
                NotificationService.showInstantNotification(
                  title: 'إشعار تجريبي',
                  body: 'هذا إشعار تجريبي للتأكد من عمل الإشعارات',
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const CustomText(
                text: 'إعادة جدولة الإشعارات',
                fontSize: 14,
                color: AppColors.black,
                textAlign: TextAlign.end,
              ),
              onTap: () {
                controller.loadPrayerTimes();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const CustomText(
                text: 'إلغاء جميع الإشعارات',
                fontSize: 14,
                color: AppColors.black,
                textAlign: TextAlign.end,
              ),
              onTap: () async {
                await NotificationService.cancelAllNotifications();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('إجمالي المدخلات', '${info.totalEntries}'),
            _buildInfoRow('البيانات المحفوظة', '${info.dataEntries}'),
            _buildInfoRow('البيانات الصالحة', '${info.validEntries}'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              'أقدم بيانات',
              _formatAge(DateTime.now().difference(info.oldestCacheDate)),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildInfoRow(
                'حالة الاتصال',
                controller.isOnline.value ? 'متصل' : 'غير متصل',
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
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () async {
              await controller.clearCache();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('مسح الكاش', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
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
