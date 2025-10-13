import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_time_model.dart';

class PrayerApiService {
  Future<PrayerTimeModel> fetchPrayerTimes(String city) async {

    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=Egypt&method=5');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return PrayerTimeModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch prayer times');
    }
  }
}
