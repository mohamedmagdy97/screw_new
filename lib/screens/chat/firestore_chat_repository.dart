import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/screens/chat/chat_repository.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _messagesCol =>
      _firestore.collection('chats').doc('messages').collection('messages');

  CollectionReference<Map<String, dynamic>> get _typingCol =>
      _firestore.collection('chats').doc('typing').collection('typing');

  @override
  Stream<List<ChatMessage>> liveMessages({DateTime? after}) {
    Query q = _messagesCol.orderBy('timestamp');
    if (after != null) q = q.where('timestamp', isGreaterThan: after);

    return q.snapshots().map(
      (snap) => snap.docs.map((doc) => ChatMessage.fromDoc(doc)).toList(),
    );
  }

  @override
  Future<List<ChatMessage>> fetchInitialMessages({int limit = 20}) async {
    final snap = await _messagesCol
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map(ChatMessage.fromDoc).toList().reversed.toList();
  }

  @override
  Future<List<ChatMessage>> fetchOlderMessages(
    DocumentSnapshot lastDoc, {
    int limit = 20,
  }) async {
    final snap = await _messagesCol
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();

    return snap.docs.map(ChatMessage.fromDoc).toList().reversed.toList();
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    await _messagesCol.add(message.toMap());
  }

  @override
  Future<void> updateMessage(String id, Map<String, dynamic> data) async {
    await _messagesCol.doc(id).update(data);
  }

  @override
  Future<void> softDeleteMessage(String id) async {
    await _messagesCol.doc(id).update({
      'isDeleted': true,
      'message': '',
      'reactions': {},
    });
  }

  @override
  Future<void> toggleReaction(
    ChatMessage msg,
    String emoji,
    String userName,
    String userPhone,
  ) async {
    final docRef = _messagesCol.doc(msg.id);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;

      final reactions = Map<String, dynamic>.from(
        snap.data()!['reactions'] ?? {},
      );
      final value = '$userName|$emoji';

      if (reactions[userPhone] == value) {
        reactions.remove(userPhone);
      } else {
        reactions[userPhone] = value;
      }

      tx.update(docRef, {'reactions': reactions});
    });
  }

  @override
  Future<void> updateTyping(String userName, bool isTyping) async {
    await _typingCol.doc(userName).set({
      'typing': isTyping,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<Set<String>> typingUsers(String currentUserName) {
    return _typingCol.snapshots().map((snap) {
      final now = DateTime.now();
      final typing = <String>{};
      for (var d in snap.docs) {
        if (d.id == currentUserName) continue;
        final ts = (d['updatedAt'] as Timestamp?)?.toDate();
        if (d['typing'] == true &&
            ts != null &&
            now.difference(ts).inSeconds <= 5) {
          typing.add(d.id);
        }
      }
      return typing;
    });
  }
}
