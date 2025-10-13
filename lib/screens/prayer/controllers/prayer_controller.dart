import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/screens/prayer/core/notification_service.dart';
import 'package:screw_calculator/screens/prayer/data/datasources/prayer_api_service.dart';
import 'package:screw_calculator/screens/prayer/data/models/country_model.dart';
import 'package:screw_calculator/screens/prayer/data/models/prayer_time_model.dart';
import 'package:screw_calculator/utility/local_store.dart';
import 'package:screw_calculator/utility/local_storge_key.dart';

class PrayerController extends GetxController {
  final PrayerApiService apiService;

  PrayerController(this.apiService);

  var prayerTimes = Rxn<PrayerTimeModel>();
  var isLoading = false.obs;
  late CountryModel city = egyptGovernorates.first;
  late CountryModel selectedCity = egyptGovernorates.first.obs.value;

  List<CountryModel> egyptGovernorates = const [
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

  Future<void> loadPrayerTimes({String? selectCity}) async {
    final String? res = await AppLocalStore.getString(
      LocalStoreNames.prayerCity,
    );
    if (res != null) {
      selectedCity = egyptGovernorates
          .where((e) => e.nameEn == res)
          .toList()
          .first;
      city = egyptGovernorates.where((e) => e.nameEn == res).toList().first;

      AppLocalStore.setString(LocalStoreNames.prayerCity, selectedCity.nameEn);
    } else {
      selectedCity = egyptGovernorates.last.obs.value;
      city = egyptGovernorates.last;
    }
    try {
      isLoading.value = true;
      final data = await apiService.fetchPrayerTimes(selectedCity.nameEn);
      prayerTimes.value = data;

      _scheduleNotifications(data);
    } finally {
      isLoading.value = false;
    }
  }

  void _scheduleNotifications(PrayerTimeModel data) {
    final format = DateFormat('HH:mm');
    final now = DateTime.now();

    final times = {
      'الفجر': data.fajr,
      'الظهر': data.dhuhr,
      'العصر': data.asr,
      'المغرب': data.maghrib,
      'العشاء': data.isha,
    };

    for (var entry in times.entries) {
      final prayerTime = format.parse(entry.value);
      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );
      if (scheduled.isAfter(now)) {
        NotificationService.schedulePrayerNotification(
          prayerName: entry.key,
          time: scheduled,
        );
      }
    }
  }
}
