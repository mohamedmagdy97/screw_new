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
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedDate;

    // ✅ نتأكد إذا القيمة Timestamp أو String
    if (json['datetime'] is Timestamp) {
      parsedDate = (json['datetime'] as Timestamp).toDate();
    } else if (json['datetime'] is String) {
      parsedDate =
          DateTime.tryParse(json['datetime']!.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    return NotificationModel(
      id: docId,
      title: json['title']!.toString(),
      description: json['description']!.toString(),
      datetime: parsedDate /*(json['datetime'] != null)
          ? DateTime.parse(json['datetime']!.toString())
          : DateTime.now()*/,
      type: json['type']!.toString(),
      image: json['image']!.toString(),
      isRead: json['isRead'] is bool
          ? json['isRead'] as bool
          : json['isRead'].toString().toLowerCase() == 'true',
      priority: json['priority']!.toString(),
      actionUrl: json['actionUrl']!.toString(),
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
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
