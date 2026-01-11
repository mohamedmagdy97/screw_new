import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerTimeModel {
  final String fajr, dhuhr, asr, maghrib, isha;

  // حفظ الأوقات بصيغة 24 ساعة للحسابات
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
      // للعرض - صيغة 12 ساعة
      fajr: _convertTo12Hour(timings['Fajr']),
      dhuhr: _convertTo12Hour(timings['Dhuhr']),
      asr: _convertTo12Hour(timings['Asr']),
      maghrib: _convertTo12Hour(timings['Maghrib']),
      isha: _convertTo12Hour(timings['Isha']),

      // للحسابات - صيغة 24 ساعة
      fajr24: _cleanTime24(timings['Fajr']),
      dhuhr24: _cleanTime24(timings['Dhuhr']),
      asr24: _cleanTime24(timings['Asr']),
      maghrib24: _cleanTime24(timings['Maghrib']),
      isha24: _cleanTime24(timings['Isha']),
    );
  }

  // تنظيف الوقت من الأقواس والمسافات (مثل: "05:30 (EET)" -> "05:30")
  static String _cleanTime24(String time) {
    return time.split(' ')[0].trim();
  }

  // تحويل لصيغة 12 ساعة للعرض
  static String _convertTo12Hour(String time24) {
    try {
      final cleanTime = _cleanTime24(time24);
      final date = DateFormat('HH:mm').parse(cleanTime);
      return DateFormat(
        'h:mm a',
      ).format(date).replaceAll('AM', 'ص').replaceAll('PM', 'م');
    } catch (e) {
      debugPrint('❌ Error converting time: $time24 - $e');
      return time24;
    }
  }

  // تحويل JSON للحفظ في الكاش
  Map<String, dynamic> toJson() {
    return {
      'code': 200,
      'status': 'OK',
      'data': {
        'timings': {
          'Fajr': fajr24,
          'Dhuhr': dhuhr24,
          'Asr': asr24,
          'Maghrib': maghrib24,
          'Isha': isha24,
        },
        'date': {
          'readable': DateFormat('dd MMM yyyy').format(DateTime.now()),
          'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      },
    };
  }

  // الحصول على الصلاة الحالية
  String? getCurrentPrayer() {
    final now = DateTime.now();

    final prayers = [
      {'name': 'الفجر', 'time': fajr24},
      {'name': 'الظهر', 'time': dhuhr24},
      {'name': 'العصر', 'time': asr24},
      {'name': 'المغرب', 'time': maghrib24},
      {'name': 'العشاء', 'time': isha24},
    ];

    String? currentPrayer;

    for (int i = 0; i < prayers.length; i++) {
      final prayerDateTime = _parseTime24(prayers[i]['time']!, now);

      if (prayerDateTime != null && prayerDateTime.isBefore(now)) {
        currentPrayer = prayers[i]['name'];
      } else {
        break;
      }
    }

    return currentPrayer;
  }

  // الحصول على الصلاة القادمة
  String? getNextPrayer() {
    final now = DateTime.now();

    final prayers = [
      {'name': 'الفجر', 'time': fajr24},
      {'name': 'الظهر', 'time': dhuhr24},
      {'name': 'العصر', 'time': asr24},
      {'name': 'المغرب', 'time': maghrib24},
      {'name': 'العشاء', 'time': isha24},
    ];

    for (var prayer in prayers) {
      final prayerDateTime = _parseTime24(prayer['time']!, now);

      if (prayerDateTime != null && prayerDateTime.isAfter(now)) {
        return prayer['name'];
      }
    }

    return 'الفجر'; // اليوم التالي
  }

  // حساب الوقت المتبقي للصلاة القادمة
  Duration? getTimeUntilNextPrayer() {
    final now = DateTime.now();
    final nextPrayer = getNextPrayer();

    if (nextPrayer == null) return null;

    final prayerTimes = {
      'الفجر': fajr24,
      'الظهر': dhuhr24,
      'العصر': asr24,
      'المغرب': maghrib24,
      'العشاء': isha24,
    };

    final timeStr = prayerTimes[nextPrayer];
    if (timeStr == null) return null;

    var prayerDateTime = _parseTime24(timeStr, now);

    if (prayerDateTime == null) return null;

    // إذا كان الفجر وقد مر وقته اليوم، أضف يوم
    if (nextPrayer == 'الفجر' && prayerDateTime.isBefore(now)) {
      prayerDateTime = prayerDateTime.add(const Duration(days: 1));
    }

    return prayerDateTime.difference(now);
  }

  // الحصول على معلومات الصلاة القادمة (الاسم + الوقت + المتبقي)
  Map<String, String> getNextPrayerInfo() {
    final nextPrayer = getNextPrayer();
    final timeUntil = getTimeUntilNextPrayer();

    if (nextPrayer == null) {
      return {
        'name': 'الفجر',
        'time': fajr,
        'time24': fajr24,
        'remaining': '--',
      };
    }

    final prayerTimes12 = {
      'الفجر': fajr,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };

    final prayerTimes24 = {
      'الفجر': fajr24,
      'الظهر': dhuhr24,
      'العصر': asr24,
      'المغرب': maghrib24,
      'العشاء': isha24,
    };

    return {
      'name': nextPrayer,
      'time': prayerTimes12[nextPrayer] ?? '--:--',
      'time24': prayerTimes24[nextPrayer] ?? '--:--',
      'remaining': timeUntil != null ? _formatDuration(timeUntil) : '--',
    };
  }

  // تحليل الوقت بصيغة 24 ساعة
  DateTime? _parseTime24(String timeStr, DateTime baseDate) {
    try {
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) return null;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing time "$timeStr": $e');
      return null;
    }
  }

  // تنسيق المدة الزمنية
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

  // للتصحيح - طباعة كل الأوقات
  void debugPrintTimes() {
    debugPrint('=== Prayer Times (12h format) ===');
    debugPrint('الفجر: $fajr');
    debugPrint('الظهر: $dhuhr');
    debugPrint('العصر: $asr');
    debugPrint('المغرب: $maghrib');
    debugPrint('العشاء: $isha');
    debugPrint('=== Prayer Times (24h format) ===');
    debugPrint('الفجر: $fajr24');
    debugPrint('الظهر: $dhuhr24');
    debugPrint('العصر: $asr24');
    debugPrint('المغرب: $maghrib24');
    debugPrint('العشاء: $isha24');
    debugPrint('=== Current Status ===');
    debugPrint('Current Prayer: ${getCurrentPrayer() ?? "None"}');
    debugPrint('Next Prayer: ${getNextPrayer() ?? "Fajr tomorrow"}');
    final info = getNextPrayerInfo();
    debugPrint('Next Prayer Info: $info');
  }
}
