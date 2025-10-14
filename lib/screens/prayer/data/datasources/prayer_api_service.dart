import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:screw_calculator/helpers/app_print.dart';

import '../models/prayer_time_model.dart';

class PrayerApiService {
  final _box = Hive.box('prayerCache');

  Future<PrayerTimeModel> fetchPrayerTimes(String city) async {
    final cacheKey = city.toLowerCase().trim();

    try {
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=Egypt&method=5',
      );

      // Add timeout to prevent hanging
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        await _box.put(cacheKey, jsonEncode(body));

        Printing.info('✅ [Online] Prayer times fetched & cached for $city');
        return PrayerTimeModel.fromJson(body);
      } else {
        Printing.info('⚠️ Server responded with ${response.statusCode}');
        return _loadFromCacheOrThrow(cacheKey);
      }
    } on SocketException {
      Printing.info('📴 No Internet connection. Loading from cache...');
      return _loadFromCacheOrThrow(cacheKey);
    } on TimeoutException {
      Printing.info('⏰ Request timed out. Using cache if available...');
      return _loadFromCacheOrThrow(cacheKey);
    } on FormatException {
      Printing.info('⚠️ Data format issue. Using cache...');
      return _loadFromCacheOrThrow(cacheKey);
    } catch (e) {
      Printing.info('❌ Unexpected error: $e');
      return _loadFromCacheOrThrow(cacheKey);
    }
  }

  PrayerTimeModel _loadFromCacheOrThrow(String cacheKey) {
    final cachedData = _box.get(cacheKey);
    if (cachedData != null) {
      Printing.info('📦 Loaded cached prayer times for $cacheKey');
      return PrayerTimeModel.fromJson(jsonDecode(cachedData));
    } else {
      throw Exception('❌ No cached data available for $cacheKey');
    }
  }
}
