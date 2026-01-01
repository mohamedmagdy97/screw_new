import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String name;
  final String phoneNumber;
  final String message;
  final String? replyTo;
  final Map<String, String> reactions;
  final DateTime timestamp;
  final List<String> seenBy;
  final bool isDeleted;
  final String? audioUrl;
  final String? audioDuration;
  final String? type;

  ChatMessage({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.message,
    required this.timestamp,
    required this.reactions,
    required this.seenBy,
    required this.isDeleted,
    this.replyTo,
    this.audioUrl,
    this.audioDuration,
    this.type,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return ChatMessage(
      id: d.id,
      name: m['name'],
      phoneNumber: m['phone'] ?? '01149504892',
      message: m['message'] ?? '',
      timestamp:
      ((m['timestamp'] != null ? m['timestamp'] : Timestamp.now())
      as Timestamp)
          .toDate(),
      reactions: Map<String, String>.from(m['reactions'] ?? {}),
      seenBy: List<String>.from(m['seenBy'] ?? []),
      isDeleted: m['isDeleted'] ?? false,
      replyTo: m['replyTo'],
      audioUrl: m['audioUrl'],
      audioDuration: m['audioDuration'],
      type: m['type'],
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m) {
    return ChatMessage(
      id: m['id'],
      name: m['name'],
      phoneNumber: m['phone'] ?? '01149504892',
      message: m['message'],
      timestamp: DateTime.parse(m['timestamp']),
      reactions: Map<String, String>.from(m['reactions'] ?? {}),
      seenBy: List<String>.from(m['seenBy']),
      isDeleted: m['isDeleted'] ?? false,
      replyTo: m['replyTo'],
      audioUrl: m['audioUrl'],
      audioDuration: m['audioDuration'],
      type: m['type'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phoneNumber,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'reactions': reactions,
    'seenBy': seenBy,
    'isDeleted': isDeleted,
    'replyTo': replyTo,
    'audioUrl': audioUrl,
    'type': type,
  };
}

// class ChatMessage {
//   final String id;
//   final String name;
//   final String phoneNumber;
//   final String message;
//   final String type;
//   final dynamic replyPreview;
//   final dynamic replyTo;
//   final dynamic reactions;
//   final DateTime timestamp;
//   final List<String> seenBy;
//   final dynamic audio;
//   final bool deleted;
//
//   ChatMessage({
//     required this.id,
//     required this.name,
//     required this.phoneNumber,
//     required this.message,
//     required this.type,
//     required this.timestamp,
//     required this.replyTo,
//     required this.replyPreview,
//     required this.reactions,
//     required this.seenBy,
//     required this.audio,
//     required this.deleted,
//   });
//
//   factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return ChatMessage(
//       id: doc.id,
//       name: data['name'] ?? '',
//       phoneNumber: data['phone'] ?? '',
//       replyPreview: data['replyPreview'] ?? '',
//       replyTo: data['replyTo'] ?? '',
//       reactions: data['reactions'] ?? {},
//       message: data['message'] ?? '',
//       type: data['type'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       seenBy: List<String>.from(data['seenBy'] ?? []),
//       audio: data['audio'] ?? '',
//       deleted: data['deleted'] != null
//           ? (data['deleted'] == "false" ? false : true)
//           : false,
//     );
//   }
//
//   factory ChatMessage.fromHive(Map data) {
//     return ChatMessage(
//       id: data['id'],
//       name: data['name'],
//       phoneNumber: data['phone'] != null ? data['phone'] : "",
//       replyTo: data['replyTo'],
//       replyPreview: data['replyPreview'],
//       reactions: data['reactions'] != null ? data['reactions'] : {"": []},
//       message: data['message'],
//       type: data['type'] ?? "text",
//       timestamp: DateTime.parse(data['timestamp']),
//       seenBy: List<String>.from(data['seenBy']),
//       audio: data['audio'],
//       deleted: data['deleted'] != null
//           ? (data['deleted'] == "false" ? false : true)
//           : false,
//     );
//   }
//
//   Map<String, dynamic> toHive() => {
//     'id': id,
//     'name': name,
//     'message': message,
//     'timestamp': timestamp.toIso8601String(),
//     'seenBy': seenBy,
//     'audio': audio,
//     'deleted': deleted,
//   };
// }
