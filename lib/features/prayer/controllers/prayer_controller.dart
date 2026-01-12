import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/features/prayer/core/notification_service.dart';
import 'package:screw_calculator/features/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/features/prayer/data/models/country_model.dart';
import 'package:screw_calculator/features/prayer/data/models/prayer_time_model.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';

class PrayerController extends GetxController {
  final PrayerApiService apiService = PrayerApiService();

  var prayerTimes = Rxn<PrayerTimeModel>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isOnline = true.obs;

  late CountryModel city;
  late CountryModel selectedCity;

  final List<CountryModel> egyptGovernorates = const [
    CountryModel(id: 1, nameAr: 'القاهرة', nameEn: 'Cairo'),
    CountryModel(id: 2, nameAr: 'الجيزة', nameEn: 'Giza'),
    CountryModel(id: 3, nameAr: 'الإسكندرية', nameEn: 'Alexandria'),
    CountryModel(id: 4, nameAr: 'الدقهلية', nameEn: 'Dakahlia'),
    CountryModel(id: 5, nameAr: 'الشرقية', nameEn: 'Sharqia'),
    CountryModel(id: 6, nameAr: 'القليوبية', nameEn: 'Qalyubia'),
    CountryModel(id: 7, nameAr: 'كفر الشيخ', nameEn: 'Kafr El Sheikh'),
    CountryModel(id: 8, nameAr: 'الغربية', nameEn: 'Gharbia'),
    CountryModel(id: 9, nameAr: 'المنوفية', nameEn: 'Monufia'),
    CountryModel(id: 10, nameAr: 'البحيرة', nameEn: 'Beheira'),
    CountryModel(id: 11, nameAr: 'بورسعيد', nameEn: 'Port Said'),
    CountryModel(id: 12, nameAr: 'الإسماعيلية', nameEn: 'Ismailia'),
    CountryModel(id: 13, nameAr: 'السويس', nameEn: 'Suez'),
    CountryModel(id: 14, nameAr: 'دمياط', nameEn: 'Damietta'),
    CountryModel(id: 15, nameAr: 'الفيوم', nameEn: 'Fayoum'),
    CountryModel(id: 16, nameAr: 'بني سويف', nameEn: 'Beni Suef'),
    CountryModel(id: 17, nameAr: 'المنيا', nameEn: 'Minya'),
    CountryModel(id: 18, nameAr: 'أسيوط', nameEn: 'Assiut'),
    CountryModel(id: 19, nameAr: 'سوهاج', nameEn: 'Sohag'),
    CountryModel(id: 20, nameAr: 'قنا', nameEn: 'Qena'),
    CountryModel(id: 21, nameAr: 'الأقصر', nameEn: 'Luxor'),
    CountryModel(id: 22, nameAr: 'أسوان', nameEn: 'Aswan'),
    CountryModel(id: 23, nameAr: 'البحر الأحمر', nameEn: 'Red Sea'),
    CountryModel(id: 24, nameAr: 'الوادي الجديد', nameEn: 'New Valley'),
    CountryModel(id: 25, nameAr: 'مطروح', nameEn: 'Matrouh'),
    CountryModel(id: 26, nameAr: 'شمال سيناء', nameEn: 'North Sinai'),
    CountryModel(id: 27, nameAr: 'جنوب سيناء', nameEn: 'South Sinai'),
  ];

  @override
  void onInit() {
    super.onInit();

    // تهيئة API Service
    apiService.init().then((_) {
      _initializeCity();
      loadPrayerTimes();

      // مسح الكاش القديم (أقدم من 7 أيام)
      apiService.clearOldCache();
    });
  }

  // تهيئة المدينة من التخزين المحلي
  void _initializeCity() {
    final savedCity = AppLocalStore.getString(LocalStoreNames.prayerCity);

    if (savedCity != null && savedCity.toString().isNotEmpty) {
      try {
        selectedCity = egyptGovernorates.firstWhere(
          (e) => e.nameEn == savedCity,
          orElse: () => egyptGovernorates.first,
        );
        city = selectedCity;
      } catch (e) {
        debugPrint('Error loading saved city: $e');
        selectedCity = egyptGovernorates.first;
        city = egyptGovernorates.first;
      }
    } else {
      selectedCity = egyptGovernorates.first;
      city = egyptGovernorates.first;
    }
  }

  // تحميل مواقيت الصلاة
  Future<void> loadPrayerTimes() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // التحقق من الاتصال بالإنترنت
      isOnline.value = await apiService.checkInternetConnection();

      final data = await apiService.fetchPrayerTimes(selectedCity.nameEn);

      if (data != null) {
        prayerTimes.value = data;

        // عرض معلومات إضافية
        debugPrint('✅ Current Prayer: ${data.getCurrentPrayer() ?? "None"}');
        debugPrint('✅ Next Prayer: ${data.getNextPrayer() ?? "Fajr tomorrow"}');

        final timeUntil = data.getTimeUntilNextPrayer();
        if (timeUntil != null) {
          final hours = timeUntil.inHours;
          final minutes = timeUntil.inMinutes % 60;
          debugPrint('⏰ Time until next: ${hours}h ${minutes}m');
        }

        await _scheduleNotifications(data);

        // حفظ المدينة المختارة
        await AppLocalStore.setString(
          LocalStoreNames.prayerCity,
          selectedCity.nameEn,
        );
      } else {
        hasError.value = true;
        errorMessage.value = isOnline.value
            ? 'لم يتم العثور على مواقيت الصلاة'
            : 'لا يوجد اتصال بالإنترنت';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'حدث خطأ في تحميل المواقيت';
      debugPrint('❌ Error loading prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // جدولة الإشعارات
  Future<void> _scheduleNotifications(PrayerTimeModel data) async {
    try {
      final format = DateFormat('HH:mm');
      final now = DateTime.now();

      final times = {
        'الفجر': data.fajr,
        'الظهر': data.dhuhr,
        'العصر': data.asr,
        'المغرب': data.maghrib,
        'العشاء': data.isha,
      };

      // إلغاء جميع الإشعارات السابقة أولاً
      await NotificationService.cancelAllNotifications();

      // جدولة الإشعارات الجديدة
      for (var entry in times.entries) {
        try {
          final prayerTime = format.parse(entry.value);

          await NotificationService.schedulePrayerNotification(
            prayerName: entry.key,
            time: DateTime(
              now.year,
              now.month,
              now.day,
              prayerTime.hour,
              prayerTime.minute,
            ),
          );
        } catch (e) {
          debugPrint('Error scheduling ${entry.key}: $e');
        }
      }

      // التحقق من الإشعارات المجدولة
      final pending = await NotificationService.getPendingNotifications();
      debugPrint('✅ Scheduled ${pending.length} notifications');
    } catch (e) {
      debugPrint('Error in _scheduleNotifications: $e');
    }
  }

  // تغيير المدينة
  Future<void> changeCity(CountryModel newCity) async {
    selectedCity = newCity;
    city = newCity;
    await loadPrayerTimes();
  }

  // إعادة المحاولة
  Future<void> retry() async {
    await loadPrayerTimes();
  }

  // عرض معلومات الكاش
  Future<void> showCacheInfo() async {
    final info = await apiService.getCacheInfo();
    debugPrint('📊 Cache Info:\n${info.summary}');
    return;
  }

  // مسح الكاش
  Future<void> clearCache() async {
    await apiService.clearAllCache();
    await loadPrayerTimes();
  }

  @override
  void onClose() {
    // يمكنك إلغاء الإشعارات هنا إذا أردت
    // NotificationService.cancelAllNotifications();
    super.onClose();
  }
}
