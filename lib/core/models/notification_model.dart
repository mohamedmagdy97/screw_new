import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime datetime;
  final String type;
  final String? image;
  final bool isRead;
  final String priority;
  final String? actionUrl;
  final String? createdAt;
  final String? token;
  final String? messageId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.datetime,
    required this.type,
    this.image,
    this.isRead = false,
    this.priority = 'low',
    this.actionUrl,
    this.createdAt,
    this.token,
    this.messageId,
  });

  /// ينسخ الإشعار مع تغيير حالة القراءة (تُدار محليًا على الجهاز).
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      datetime: datetime,
      type: type,
      image: image,
      isRead: isRead ?? this.isRead,
      priority: priority,
      actionUrl: actionUrl,
      createdAt: createdAt,
      token: token,
      messageId: messageId,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static String _str(dynamic value, [String fallback = '']) =>
      value == null ? fallback : value.toString();

  /// يقبل شكلين للبيانات: الشكل المعروض (`description`/`image`/`datetime`)
  /// والشكل الذي يحفظه التطبيق عند استلام FCM (`body`/`imageUrl`/`sentTime`).
  factory NotificationModel.fromJson(Map<String, dynamic> json, String docId) {
    return NotificationModel(
      id: docId,
      title: _str(json['title']),
      description: _str(json['description'] ?? json['body']),
      datetime: _parseDate(
        json['datetime'] ?? json['sentTime'] ?? json['createdAt'],
      ),
      type: _str(json['type'], 'general'),
      image: _str(json['image'] ?? json['imageUrl']),
      isRead: json['isRead'] is bool
          ? json['isRead'] as bool
          : _str(json['isRead']).toLowerCase() == 'true',
      priority: _str(json['priority']),
      actionUrl: _str(json['actionUrl']),
      createdAt: _str(json['createdAt']),
      messageId: _str(json['messageId']),
      token: _str(json['token']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'datetime': datetime.toIso8601String(),
      'type': type,
      'image': image,
      'isRead': isRead,
      'priority': priority,
      'actionUrl': actionUrl,
      'messageId': messageId,
      'token': token,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
