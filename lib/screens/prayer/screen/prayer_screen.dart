import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/prayer/controllers/prayer_controller.dart';
import 'package:screw_calculator/screens/prayer/core/notification_service.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(PrayerController());

    NotificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: Obx(() => _buildBody()),
    );
  }

  // بناء AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.grayy,
      title: CustomText(text: 'مواقيت الصلاة', fontSize: 22.sp),
      leading:
          // زر الإشعارات
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
            ),
            onPressed: _showNotificationSettings,
          ),

      actions: [
        // زر معلومات الكاش
        // IconButton(
        //   icon: const Icon(Icons.info_outline, color: AppColors.white),
        //   onPressed: _showCacheInfoDialog,
        // ),

        // زر الرجوع
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
      margin: const EdgeInsets.only(right: 16, left: 16, top: 16),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const CustomText(
            text: 'الصلاة القادمة',
            fontSize: 14,
            color: Colors.white70,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: nextPrayer['name']!,
            fontSize: 22,
            fontFamily: AppFonts.bold,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: nextPrayer['time']!,
            fontSize: 30,
            fontFamily: AppFonts.bold,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: nextPrayer['remaining']!,
            fontSize: 14,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  // قائمة المواقيت
  Widget _buildPrayersList(PrayerTimeModel data) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        BuildCardWidget('الفجر', data.fajr, Icons.wb_twilight),
        // BuildCardWidget('الشروق', data.sunrise ?? '--:--', Icons.wb_sunny),
        BuildCardWidget('الظهر', data.dhuhr, Icons.wb_sunny),
        BuildCardWidget('العصر', data.asr, Icons.cloud),
        BuildCardWidget('المغرب', data.maghrib, Icons.nights_stay),
        BuildCardWidget('العشاء', data.isha, Icons.bedtime),
      ],
    );
  }

  // حساب الصلاة القادمة
  Map<String, String> _getNextPrayer(PrayerTimeModel data) {
    final format = DateFormat('HH:mm');
    final now = DateTime.now();

    final prayers = [
      {'name': 'الفجر', 'time': data.fajr},
      {'name': 'الظهر', 'time': data.dhuhr},
      {'name': 'العصر', 'time': data.asr},
      {'name': 'المغرب', 'time': data.maghrib},
      {'name': 'العشاء', 'time': data.isha},
    ];

    for (var prayer in prayers) {
      try {
        final prayerTime = format.parse(prayer['time']!);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        if (prayerDateTime.isAfter(now)) {
          final diff = prayerDateTime.difference(now);
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;

          return {
            'name': prayer['name']!,
            'time': prayer['time']!,
            'remaining': 'متبقي $hours ساعة و $minutes دقيقة',
          };
        }
      } catch (e) {
        debugPrint('Error parsing prayer time: $e');
      }
    }

    // إذا انتهت جميع الصلوات، أعد الفجر لليوم التالي
    return {'name': 'الفجر', 'time': data.fajr, 'remaining': 'غداً'};
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
            // ListTile(
            //   leading: const Icon(Icons.notification_add),
            //   title: const Text('اختبار الإشعار'),
            //   onTap: () {
            //     NotificationService.showInstantNotification(
            //       title: 'إشعار تجريبي',
            //       body: 'هذا إشعار تجريبي للتأكد من عمل الإشعارات',
            //     );
            //     Navigator.pop(context);
            //   },
            // ),
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
