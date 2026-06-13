import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/core/constants/local_storage_keys.dart';
import 'package:screw_calculator/core/utils/local_store.dart';
import 'package:screw_calculator/features/prayer/core/notification_service.dart';
import 'package:screw_calculator/features/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/features/prayer/data/models/country_model.dart';
import 'package:screw_calculator/features/prayer/data/models/prayer_time_model.dart';

part 'prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> {
  PrayerCubit({required this.apiService})
    : super(const PrayerState(selectedCity: _defaultCity));

  final PrayerApiService apiService;

  static const CountryModel _defaultCity = CountryModel(
    id: 1,
    nameAr: 'القاهرة',
    nameEn: 'Cairo',
  );

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

  Future<void> init() async {
    emit(state.copyWith(status: PrayerStatus.loading));
    await _initializeCity();
    await apiService.init();
    await loadPrayerTimes();
    await apiService.clearOldCache();
  }

  Future<void> _initializeCity() async {
    final savedCity = await AppLocalStore.getString(LocalStoreNames.prayerCity);
    if (savedCity != null && savedCity.isNotEmpty) {
      final city = egyptGovernorates.firstWhere(
        (e) => e.nameEn == savedCity,
        orElse: () => _defaultCity,
      );
      emit(state.copyWith(selectedCity: city));
    }
  }

  Future<void> loadPrayerTimes() async {
    try {
      emit(state.copyWith(status: PrayerStatus.loading, errorMessage: ''));

      final isOnline = await apiService.checkInternetConnection();
      final data = await apiService.fetchPrayerTimes(state.selectedCity.nameEn);

      if (data != null) {
        await AppLocalStore.setString(
          LocalStoreNames.prayerCity,
          state.selectedCity.nameEn,
        );
        await _scheduleNotifications(data);
        emit(
          state.copyWith(
            status: PrayerStatus.loaded,
            prayerTimes: data,
            isOnline: isOnline,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PrayerStatus.error,
            isOnline: isOnline,
            errorMessage: isOnline
                ? 'لم يتم العثور على مواقيت الصلاة'
                : 'لا يوجد اتصال بالإنترنت',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PrayerStatus.error,
          errorMessage: 'حدث خطأ في تحميل المواقيت',
        ),
      );
      debugPrint('Error loading prayer times: $e');
    }
  }

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

      await NotificationService.cancelAllNotifications();
      for (final entry in times.entries) {
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
    } catch (e) {
      debugPrint('Error in _scheduleNotifications: $e');
    }
  }

  Future<void> changeCity(CountryModel newCity) async {
    emit(state.copyWith(selectedCity: newCity));
    await loadPrayerTimes();
  }

  Future<void> retry() => loadPrayerTimes();

  Future<void> clearCache() async {
    await apiService.clearAllCache();
    await loadPrayerTimes();
  }
}
