import 'package:intl/intl.dart';

class PrayerTimeModel {
  final String fajr, dhuhr, asr, maghrib, isha;

  PrayerTimeModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    return PrayerTimeModel(
      fajr: convertTo12Hour(timings['Fajr']),
      dhuhr: convertTo12Hour(timings['Dhuhr']),
      asr: convertTo12Hour(timings['Asr']),
      maghrib: convertTo12Hour(timings['Maghrib']),
      isha: convertTo12Hour(timings['Isha']),
    );
  }
}

String convertTo12Hour(String time24) {
  final date = DateFormat('HH:mm').parse(time24);
  return DateFormat(
    'h:mm a',
  ).format(date).replaceAll('AM', 'ص').replaceAll('PM', 'م');
}
