import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String name;
  final String phoneNumber;
  final String message;
  final dynamic replyPreview;
  final dynamic replyTo;
  final Map<String, dynamic> reactions;
  final DateTime timestamp;
  final List<String> seenBy;

  ChatMessage({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.message,
    required this.timestamp,
    required this.replyTo,
    required this.replyPreview,
    required this.reactions,
    required this.seenBy,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phone'] ?? '',
      replyPreview: data['replyPreview'] ?? '',
      replyTo: data['replyTo'] ?? '',
      reactions:
          data['reactions'] ??
          {
            // "❤️": ["Ali", "Ahmed"],
            // "😂": ["Mona"],
          },
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seenBy: List<String>.from(data['seenBy'] ?? []),
    );
  }

  factory ChatMessage.fromHive(Map data) {
    return ChatMessage(
      id: data['id'],
      name: data['name'],
      phoneNumber: data['phone'] != null ? data['phone'] : "",
      replyTo: data['replyTo'],
      replyPreview: data['replyPreview'],
      reactions: data['reactions'] != null ? data['reactions'] : {"": []},
      message: data['message'],
      timestamp: DateTime.parse(data['timestamp']),
      seenBy: List<String>.from(data['seenBy']),
    );
  }

  Map<String, dynamic> toHive() => {
    'id': id,
    'name': name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'seenBy': seenBy,
  };
}
