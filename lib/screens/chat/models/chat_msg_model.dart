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

  factory ChatMessage.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return ChatMessage(
      id: d.id,
      name: m['name'],
      age: m['age'] != null ? m['age'] : 0,
      phoneNumber: m['phone'] ?? '01149504892',
      message: m['message'] ?? '',
      timestamp:
          ((m['timestamp'] != null ? m['timestamp'] : Timestamp.now())
                  as Timestamp)
              .toDate(),
      reactions: Map<String, dynamic>.from(m['reactions'] ?? {}),
      seenBy: List<String>.from(m['seenBy'] ?? []),
      isDeleted: m['isDeleted'] ?? false,
      isPinned: m['isPinned'] ?? false,
      isMe: m['isMe'] ?? false,
      status: m['status'],
      replyTo: m['replyTo'],
      audioUrl: m['audioUrl'],
      audioDuration: m['audioDuration'],
      type: m['type'],
      country: m['country'],
      deviceName: m['deviceName'],
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m) {
    return ChatMessage(
      id: m['id'],
      name: m['name'],
      age: m['age'] != null ? m['age'] : 0,
      phoneNumber: m['phone'] ?? '',
      message: m['message'],
      timestamp: DateTime.parse(m['timestamp']),
      reactions: Map<String, dynamic>.from(m['reactions'] ?? {}),
      seenBy: List<String>.from(m['seenBy']),
      isDeleted: m['isDeleted'] ?? false,
      isPinned: m['isPinned'] ?? false,
      isMe: m['isMe'] ?? false,
      status: m['status'],
      replyTo: m['replyTo'],
      audioUrl: m['audioUrl'],
      audioDuration: m['audioDuration'],
      type: m['type'],
      country: m['country'],
      deviceName: m['deviceName'],
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

