import 'package:cloud_firestore/cloud_firestore.dart';

 class ScreenShootModel {
  final String id;
  final String title;
  final String description;
  final DateTime datetime;
  final String? imageBase64;

  ScreenShootModel({
    required this.id,
    required this.title,
    required this.description,
    required this.datetime,
    this.imageBase64,
  });

  factory ScreenShootModel.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedDate;

    if (json['datetime'] is Timestamp) {
      parsedDate = (json['datetime'] as Timestamp).toDate();
    } else if (json['datetime'] is String) {
      parsedDate =
          DateTime.tryParse(json['datetime']!.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    return ScreenShootModel(
      id: docId,
      title: json['title']!.toString(),
      description: json['description'] ?? "",
      datetime: parsedDate,
      imageBase64: json['imageBase64'] != null
          ? json['imageBase64']!.toString()
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'datetime': datetime.toIso8601String(),
      'imageBase64': imageBase64,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
