import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String name;
  final int age;
  final String phoneNumber;
  final String message;
  final String? replyTo;
  final Map<String, dynamic> reactions;
  final DateTime timestamp;
  final List<String> seenBy;
  final bool isDeleted;
  final bool? isPinned;
  final String? audioUrl;
  final String? audioDuration;
  final String? type;
  final String? status;
  final bool? isMe;
  final String? country;
  final String? deviceName;

  ChatMessage({
    required this.id,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.message,
    required this.timestamp,
    required this.reactions,
    required this.seenBy,
    required this.isDeleted,
    this.country,
    this.deviceName,
    this.isPinned,
    this.replyTo,
    this.audioUrl,
    this.audioDuration,
    this.type,
    this.status,
    this.isMe,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Object?> d) {
    final m = d.data()! as Map<String, dynamic>;
    return ChatMessage._fromJson(
      m,
      id: d.id,
      timestamp: ((m['timestamp'] ?? Timestamp.now()) as Timestamp).toDate(),
      defaultPhone: '01149504892',
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m) {
    return ChatMessage._fromJson(
      m,
      id: m['id'] as String,
      timestamp: DateTime.parse(m['timestamp'] as String),
      defaultPhone: '',
    );
  }

  factory ChatMessage._fromJson(
    Map<String, dynamic> m, {
    required String id,
    required DateTime timestamp,
    required String defaultPhone,
  }) {
    return ChatMessage(
      id: id,
      name: m['name'] as String,
      age: (m['age'] as int?) ?? 0,
      phoneNumber: (m['phone'] as String?) ?? defaultPhone,
      message: (m['message'] as String?) ?? '',
      timestamp: timestamp,
      reactions: Map<String, dynamic>.from(
        (m['reactions'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{},
      ),
      seenBy: List<String>.from(
        (m['seenBy'] as Iterable<dynamic>?) ?? <String>[],
      ),
      isDeleted: (m['isDeleted'] as bool?) ?? false,
      isPinned: (m['isPinned'] as bool?) ?? false,
      isMe: (m['isMe'] as bool?) ?? false,
      status: m['status'] as String?,
      replyTo: m['replyTo'] as String?,
      audioUrl: m['audioUrl'] as String?,
      audioDuration: m['audioDuration'] as String?,
      type: m['type'] as String?,
      country: m['country'] as String?,
      deviceName: m['deviceName'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'phone': phoneNumber,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'reactions': reactions,
    'seenBy': seenBy,
    'isDeleted': isDeleted,
    'isPinned': isPinned,
    'isMe': isMe,
    'status': status,
    'replyTo': replyTo,
    'audioUrl': audioUrl,
    'type': type,
    'deviceName': deviceName,
    'country': country,
  };
}
