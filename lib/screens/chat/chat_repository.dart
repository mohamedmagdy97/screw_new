

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> liveMessages({DateTime? after});
  Future<List<ChatMessage>> fetchInitialMessages({int limit = 20});
  Future<List<ChatMessage>> fetchOlderMessages(DocumentSnapshot lastDoc, {int limit = 20});
  Future<void> sendMessage(ChatMessage message);
  Future<void> updateMessage(String id, Map<String, dynamic> data);
  Future<void> softDeleteMessage(String id);
  Future<void> toggleReaction(ChatMessage message, String emoji, String userName, String userPhone);
  Future<void> updateTyping(String userName, bool isTyping);
  Stream<Set<String>> typingUsers(String currentUserName);
}
