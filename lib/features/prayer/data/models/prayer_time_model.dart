import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimeModel {
  final String fajr, dhuhr, asr, maghrib, isha;
  final String fajr24, dhuhr24, asr24, maghrib24, isha24;

  PrayerTimeModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.fajr24,
    required this.dhuhr24,
    required this.asr24,
    required this.maghrib24,
    required this.isha24,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    return PrayerTimeModel(
      fajr: _convertTo12Hour(timings['Fajr']),
      dhuhr: _convertTo12Hour(timings['Dhuhr']),
      asr: _convertTo12Hour(timings['Asr']),
      maghrib: _convertTo12Hour(timings['Maghrib']),
      isha: _convertTo12Hour(timings['Isha']),
      fajr24: _cleanTime24(timings['Fajr']),
      dhuhr24: _cleanTime24(timings['Dhuhr']),
      asr24: _cleanTime24(timings['Asr']),
      maghrib24: _cleanTime24(timings['Maghrib']),
      isha24: _cleanTime24(timings['Isha']),
    );
  }

  static String _cleanTime24(String time) => time.split(' ')[0].trim();

  static String _convertTo12Hour(String time24) {
    try {
      final cleanTime = _cleanTime24(time24);
      final date = DateFormat('HH:mm').parse(cleanTime);
      return DateFormat(
        'h:mm a',
      ).format(date).replaceAll('AM', 'ص').replaceAll('PM', 'م');
    } catch (e) {
      return time24;
    }
  }

  // --- المنطق المحدث لحل المشكلة ---

  List<Map<String, String>> get _prayersList => [
    {'name': 'الفجر', 'time': fajr24},
    {'name': 'الظهر', 'time': dhuhr24},
    {'name': 'العصر', 'time': asr24},
    {'name': 'المغرب', 'time': maghrib24},
    {'name': 'العشاء', 'time': isha24},
  ];

  String getCurrentPrayer() {
    final now = DateTime.now();
    // نبحث من العشاء نزولاً للفجر، أول صلاة وقتها مر هي الحالية
    for (int i = _prayersList.length - 1; i >= 0; i--) {
      final prayerTime = _parseTime24(_prayersList[i]['time']!, now);
      if (prayerTime != null && now.isAfter(prayerTime)) {
        return _prayersList[i]['name']!;
      }
    }
    // إذا لم يجد (أي الوقت قبل الفجر)، فالحالية هي العشاء (تبعاً لليوم السابق)
    return 'العشاء';
  }

  String getNextPrayer() {
    final now = DateTime.now();
    for (var prayer in _prayersList) {
      final prayerTime = _parseTime24(prayer['time']!, now);
      if (prayerTime != null && prayerTime.isAfter(now)) {
        return prayer['name']!;
      }
    }
    // إذا مر وقت العشاء، فالصلاة القادمة هي الفجر
    return 'الفجر';
  }

  Duration getTimeUntilNextPrayer() {
    final now = DateTime.now();
    final nextName = getNextPrayer();

    final prayerTimesMap = {
      'الفجر': fajr24,
      'الظهر': dhuhr24,
      'العصر': asr24,
      'المغرب': maghrib24,
      'العشاء': isha24,
    };

    var prayerDateTime = _parseTime24(prayerTimesMap[nextName]!, now)!;

    // أهم خطوة: إذا كانت الصلاة القادمة هي الفجر والآن نحن في وقت متأخر (بعد العشاء)
    // أو إذا كان وقت الصلاة المحسوب أصلاً قبل الآن، فهذا يعني أنها غداً
    if (prayerDateTime.isBefore(now)) {
      prayerDateTime = prayerDateTime.add(const Duration(days: 1));
    }

    return prayerDateTime.difference(now);
  }

  Map<String, String> getNextPrayerInfo() {
    final nextName = getNextPrayer();
    final duration = getTimeUntilNextPrayer();

    final displayTimes = {
      'الفجر': fajr,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };

    return {
      'name': nextName,
      'time': displayTimes[nextName] ?? '--',
      'remaining': _formatDuration(duration),
    };
  }

  DateTime? _parseTime24(String timeStr, DateTime baseDate) {
    final parts = timeStr.split(':');
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0)
      return 'متبقي ${d.inHours} ساعة و${d.inMinutes % 60} دقيقة';
    if (d.inMinutes > 0) return 'متبقي ${d.inMinutes} دقيقة';
    return 'متبقي ${d.inSeconds} ثانية';
  }
}
