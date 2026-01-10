import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/prayer_time_model.dart';

class PrayerApiService {
  // Singleton pattern
  static final PrayerApiService _instance = PrayerApiService._internal();

  factory PrayerApiService() => _instance;

  PrayerApiService._internal();

  // Constants
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheBoxName = 'prayerCache';
  static const Duration _cacheValidDuration = Duration(hours: 12);
  static const Duration _requestTimeout = Duration(seconds: 20);

  // Calculation method (Egyptian General Authority of Survey)
  static const int _calculationMethod = 5;

  late Box _cacheBox;
  bool _isInitialized = false;

  // تهيئة الـ Cache Box
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _cacheBox = await Hive.openBox(_cacheBoxName);
      _isInitialized = true;
      debugPrint('✅ Prayer API Service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Prayer API Service: $e');
      rethrow;
    }
  }

  // جلب مواقيت الصلاة
  Future<PrayerTimeModel?> fetchPrayerTimes(String city) async {
    if (!_isInitialized) {
      await init();
    }

    final cacheKey = _getCacheKey(city);

    try {
      // 1. التحقق من الكاش أولاً
      final cachedData = _getFromCache(cacheKey);
      if (cachedData != null && _isCacheValid(cacheKey)) {
        debugPrint('📦 [Cache] Loaded prayer times for $city');
        return cachedData;
      }

      // 2. جلب من الإنترنت
      debugPrint('🌐 [Online] Fetching prayer times for $city...');
      final onlineData = await _fetchFromApi(city);

      // 3. حفظ في الكاش
      if (onlineData != null) {
        await _saveToCache(cacheKey, onlineData);
        debugPrint('✅ [Online] Prayer times fetched & cached for $city');
        return onlineData;
      }

      // 4. إذا فشل، استخدم الكاش حتى لو قديم
      if (cachedData != null) {
        debugPrint('⚠️ Using old cached data for $city');
        return cachedData;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in fetchPrayerTimes: $e');

      // محاولة أخيرة من الكاش
      final cachedData = _getFromCache(cacheKey);
      if (cachedData != null) {
        debugPrint('📦 [Fallback] Using cached data for $city');
        return cachedData;
      }

      rethrow;
    }
  }

  // جلب من API
  Future<PrayerTimeModel?> _fetchFromApi(String city) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/timingsByCity?city=$city&country=Egypt&method=$_calculationMethod',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        // التحقق من صحة البيانات
        if (body['code'] == 200 && body['status'] == 'OK') {
          return PrayerTimeModel.fromJson(body);
        } else {
          debugPrint('⚠️ API returned invalid data: ${body['status']}');
          return null;
        }
      } else if (response.statusCode == 429) {
        debugPrint('⚠️ Rate limit exceeded. Using cache...');
        return null;
      } else {
        debugPrint('⚠️ Server responded with ${response.statusCode}');
        return null;
      }
    } on SocketException {
      debugPrint('📴 No Internet connection');
      return null;
    } on TimeoutException {
      debugPrint('⏰ Request timed out');
      return null;
    } on FormatException catch (e) {
      debugPrint('⚠️ Data format error: $e');
      return null;
    } on http.ClientException catch (e) {
      debugPrint('⚠️ HTTP Client error: $e');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error in _fetchFromApi: $e');
      return null;
    }
  }

  // الحصول من الكاش
  PrayerTimeModel? _getFromCache(String cacheKey) {
    try {
      final cachedJson = _cacheBox.get('${cacheKey}_data');
      if (cachedJson != null) {
        final Map<String, dynamic> data = jsonDecode(cachedJson);
        return PrayerTimeModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error reading from cache: $e');
      return null;
    }
  }

  // حفظ في الكاش
  Future<void> _saveToCache(String cacheKey, PrayerTimeModel data) async {
    try {
      final jsonData = jsonEncode(data.toJson());
      await _cacheBox.put('${cacheKey}_data', jsonData);
      await _cacheBox.put(
        '${cacheKey}_timestamp',
        DateTime.now().toIso8601String(),
      );
      debugPrint('💾 Cached prayer times for $cacheKey');
    } catch (e) {
      debugPrint('⚠️ Error saving to cache: $e');
    }
  }

  // التحقق من صلاحية الكاش
  bool _isCacheValid(String cacheKey) {
    try {
      final timestampStr = _cacheBox.get('${cacheKey}_timestamp');
      if (timestampStr == null) return false;

      final cachedTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(cachedTime);

      return difference < _cacheValidDuration;
    } catch (e) {
      debugPrint('⚠️ Error checking cache validity: $e');
      return false;
    }
  }

  // إنشاء مفتاح الكاش
  String _getCacheKey(String city) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return '${city.toLowerCase().trim()}_$today';
  }

  // مسح الكاش القديم
  Future<void> clearOldCache() async {
    if (!_isInitialized) await init();

    try {
      final keysToDelete = <String>[];
      final now = DateTime.now();

      for (var key in _cacheBox.keys) {
        if (key.toString().endsWith('_timestamp')) {
          final timestampStr = _cacheBox.get(key);
          if (timestampStr != null) {
            try {
              final cachedTime = DateTime.parse(timestampStr);
              if (now.difference(cachedTime) > const Duration(days: 7)) {
                final baseKey = key.toString().replaceAll('_timestamp', '');
                keysToDelete.add(baseKey);
              }
            } catch (e) {
              debugPrint('⚠️ Error parsing timestamp for $key: $e');
            }
          }
        }
      }

      for (var baseKey in keysToDelete) {
        await _cacheBox.delete('${baseKey}_data');
        await _cacheBox.delete('${baseKey}_timestamp');
      }

      if (keysToDelete.isNotEmpty) {
        debugPrint('🗑️ Cleared ${keysToDelete.length} old cache entries');
      }
    } catch (e) {
      debugPrint('❌ Error clearing old cache: $e');
    }
  }

  // مسح كل الكاش
  Future<void> clearAllCache() async {
    if (!_isInitialized) await init();

    try {
      await _cacheBox.clear();
      debugPrint('🗑️ All cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  // الحصول على معلومات الكاش
  Future<CacheInfo> getCacheInfo() async {
    if (!_isInitialized) await init();

    try {
      final totalEntries = _cacheBox.length;
      final dataEntries = _cacheBox.keys
          .where((key) => key.toString().endsWith('_data'))
          .length;

      final now = DateTime.now();
      var validEntries = 0;
      var oldestCacheDate = now;

      for (var key in _cacheBox.keys) {
        if (key.toString().endsWith('_timestamp')) {
          final timestampStr = _cacheBox.get(key);
          if (timestampStr != null) {
            try {
              final cachedTime = DateTime.parse(timestampStr);

              if (now.difference(cachedTime) < _cacheValidDuration) {
                validEntries++;
              }

              if (cachedTime.isBefore(oldestCacheDate)) {
                oldestCacheDate = cachedTime;
              }
            } catch (e) {
              debugPrint('⚠️ Error parsing timestamp: $e');
            }
          }
        }
      }

      return CacheInfo(
        totalEntries: totalEntries,
        dataEntries: dataEntries,
        validEntries: validEntries,
        oldestCacheDate: oldestCacheDate,
      );
    } catch (e) {
      debugPrint('❌ Error getting cache info: $e');
      return CacheInfo(
        totalEntries: 0,
        dataEntries: 0,
        validEntries: 0,
        oldestCacheDate: DateTime.now(),
      );
    }
  }

  // جلب مواقيت لتاريخ محدد
  Future<PrayerTimeModel?> fetchPrayerTimesForDate({
    required String city,
    required DateTime date,
  }) async {
    if (!_isInitialized) await init();

    try {
      final timestamp = date.millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        '$_baseUrl/timingsByCity/$timestamp?city=$city&country=Egypt&method=$_calculationMethod',
      );

      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['code'] == 200 && body['status'] == 'OK') {
          debugPrint(
            '✅ Fetched prayer times for $city on ${DateFormat('yyyy-MM-dd').format(date)}',
          );
          return PrayerTimeModel.fromJson(body);
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching prayer times for date: $e');
      return null;
    }
  }

  // جلب مواقيت الشهر كامل
  Future<List<PrayerTimeModel>> fetchMonthlyPrayerTimes({
    required String city,
    required int year,
    required int month,
  }) async {
    if (!_isInitialized) await init();

    try {
      final url = Uri.parse(
        '$_baseUrl/calendarByCity/$year/$month?city=$city&country=Egypt&method=$_calculationMethod',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['code'] == 200 && body['status'] == 'OK') {
          final List<dynamic> data = body['data'];
          return data
              .map((json) => PrayerTimeModel.fromJson({'data': json}))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching monthly prayer times: $e');
      return [];
    }
  }

  // التحقق من الاتصال بالإنترنت
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('api.aladhan.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (e) {
      debugPrint('⚠️ Error checking internet: $e');
      return false;
    }
  }
}

// ============================================
// Cache Info Model - معلومات الكاش
// ============================================

class CacheInfo {
  final int totalEntries;
  final int dataEntries;
  final int validEntries;
  final DateTime oldestCacheDate;

  CacheInfo({
    required this.totalEntries,
    required this.dataEntries,
    required this.validEntries,
    required this.oldestCacheDate,
  });

  String get summary {
    final age = DateTime.now().difference(oldestCacheDate);
    final ageText = age.inDays > 0
        ? '${age.inDays} يوم'
        : age.inHours > 0
        ? '${age.inHours} ساعة'
        : '${age.inMinutes} دقيقة';

    return '''
إجمالي المدخلات: $totalEntries
البيانات المحفوظة: $dataEntries
البيانات الصالحة: $validEntries
أقدم بيانات: منذ $ageText
''';
  }
}

// ============================================
// Prayer Time Model Enhancement - تحسين النموذج
// ============================================

extension PrayerTimeModelExtension on PrayerTimeModel {
  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'code': 200,
      'status': 'OK',
      'data': {
        'timings': {
          'Fajr': fajr,
          // 'Sunrise': sunrise,
          'Dhuhr': dhuhr,
          'Asr': asr,
          'Maghrib': maghrib,
          'Isha': isha,
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
    final format = DateFormat('HH:mm');

    final prayers = {
      'الفجر': fajr,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };

    String? lastPrayer;
    for (var entry in prayers.entries) {
      try {
        final prayerTime = format.parse(entry.value);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        if (prayerDateTime.isBefore(now)) {
          lastPrayer = entry.key;
        } else {
          break;
        }
      } catch (e) {
        debugPrint('Error parsing prayer time: $e');
      }
    }

    return lastPrayer;
  }

  // الحصول على الصلاة القادمة
  String? getNextPrayer() {
    final now = DateTime.now();
    final format = DateFormat('HH:mm');

    final prayers = {
      'الفجر': fajr,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };

    for (var entry in prayers.entries) {
      try {
        final prayerTime = format.parse(entry.value);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        if (prayerDateTime.isAfter(now)) {
          return entry.key;
        }
      } catch (e) {
        debugPrint('Error parsing prayer time: $e');
      }
    }

    return 'الفجر'; // اليوم التالي
  }

  // الوقت المتبقي للصلاة القادمة
  Duration? getTimeUntilNextPrayer() {
    final now = DateTime.now();
    final format = DateFormat('HH:mm');
    final nextPrayer = getNextPrayer();

    if (nextPrayer == null) return null;

    final prayers = {
      'الفجر': fajr,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };

    final timeStr = prayers[nextPrayer];
    if (timeStr == null) return null;

    try {
      final prayerTime = format.parse(timeStr);
      var prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );

      // إذا كان الفجر وقد مر وقته اليوم
      if (nextPrayer == 'الفجر' && prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      return prayerDateTime.difference(now);
    } catch (e) {
      debugPrint('Error calculating time until next prayer: $e');
      return null;
    }
  }
}
