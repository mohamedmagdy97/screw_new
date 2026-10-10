import 'package:flutter_test/flutter_test.dart';
import 'package:screw_calculator/features/chat/data/models/chat_msg_model.dart';
import 'package:screw_calculator/features/prayer/data/models/prayer_time_model.dart';

void main() {
  group('PrayerTimeModel.fromJson', () {
    test('parses timings and strips timezone suffix', () {
      final model = PrayerTimeModel.fromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'timings': <String, dynamic>{
            'Fajr': '04:30 (EET)',
            'Dhuhr': '12:00 (EET)',
            'Asr': '15:30 (EET)',
            'Maghrib': '18:00 (EET)',
            'Isha': '19:30 (EET)',
          },
        },
      });

      expect(model.fajr24, '04:30');
      expect(model.isha24, '19:30');
      expect(model.dhuhr, contains('م'));
      expect(model.fajr, contains('ص'));
    });
  });

  group('ChatMessage', () {
    test('toMap/fromMap round-trips', () {
      final original = ChatMessage.fromMap(<String, dynamic>{
        'id': 'm1',
        'name': 'Ali',
        'age': 20,
        'phone': '0100',
        'message': 'hi',
        'timestamp': '2026-01-01T10:00:00.000',
        'reactions': <String, dynamic>{},
        'seenBy': <String>['Omar'],
      });

      final copy = ChatMessage.fromMap(original.toMap());

      expect(copy.id, 'm1');
      expect(copy.name, 'Ali');
      expect(copy.seenBy, <String>['Omar']);
      expect(copy.isDeleted, isFalse);
      expect(copy.timestamp, original.timestamp);
    });
  });
}
