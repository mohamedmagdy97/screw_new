import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String name;
  final String message;
  final DateTime timestamp;
  final List<String> seenBy;

  ChatMessage({
    required this.id,
    required this.name,
    required this.message,
    required this.timestamp,
    required this.seenBy,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      name: data['name'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seenBy: List<String>.from(data['seenBy'] ?? []),
    );
  }

  factory ChatMessage.fromHive(Map data) {
    return ChatMessage(
      id: data['id'],
      name: data['name'],
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
