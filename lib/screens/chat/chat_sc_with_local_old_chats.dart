import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/helpers/device_info.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _firstLoad = true;

  DocumentSnapshot? _lastDoc;
  StreamSubscription? _liveSub;

  final List<ChatMessage> _messages = [];

  late Box userBox;
  late Box cacheBox;

  String? userName;
  String? userPhone;
  String? userCountry;
  @override
  void initState() {
    super.initState();

    userBox = Hive.box('userBox');
    cacheBox = Hive.box('cachedMessages');

    userName = userBox.get('name')?.toString();
    userPhone = userBox.get('phone')?.toString();
    userCountry = userBox.get('country')?.toString();

    _loadCachedMessages();
    _fetchInitialMessages();
    _listenRealtime();

    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  // -------------------- DATA --------------------

  void _loadCachedMessages() {
    final cached =
        cacheBox.values
            .map((e) => ChatMessage.fromHive(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _messages.addAll(cached);
  }

  Future<void> _fetchInitialMessages() async {
    final q = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    final snap = await q.get();
    if (snap.docs.isEmpty) {
      _hasMore = false;
      return;
    }

    _lastDoc = snap.docs.last;

    final fresh = snap.docs
        .map(ChatMessage.fromFirestore)
        .toList()
        .reversed
        .toList();

    _messages
      ..clear()
      ..addAll(fresh);

    _cacheMessages(fresh);

    setState(() {});
    _scrollToBottom(force: true);
  }

  Future<void> _fetchOlderMessages() async {
    if (_isLoadingMore || !_hasMore || _lastDoc == null) return;
    _isLoadingMore = true;

    final beforeOffset = _scrollCtrl.offset;

    final q = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDoc!)
        .limit(_pageSize);

    final snap = await q.get();

    if (snap.docs.isEmpty) {
      _hasMore = false;
      _isLoadingMore = false;
      return;
    }

    _lastDoc = snap.docs.last;

    final older = snap.docs
        .map(ChatMessage.fromFirestore)
        .toList()
        .reversed
        .toList();

    _messages.insertAll(0, older);
    _cacheMessages(older);

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.jumpTo(beforeOffset + 250);
    });

    _isLoadingMore = false;
  }

  void _listenRealtime() {
    _liveSub = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
          final incoming = snap.docs
              .map(ChatMessage.fromFirestore)
              .where((m) => !_messages.any((e) => e.id == m.id))
              .toList();

          if (incoming.isEmpty) return;

          _messages.addAll(incoming);
          _cacheMessages(incoming);

          setState(() {});
          _scrollToBottomIfNear();
        });
  }

  void _cacheMessages(List<ChatMessage> msgs) {
    for (final m in msgs) {
      cacheBox.put(m.id, m.toHive());
    }
  }

  // -------------------- SCROLL --------------------

  void _onScroll() {
    if (_scrollCtrl.position.pixels <= 60) {
      _fetchOlderMessages();
    }
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollCtrl.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollToBottomIfNear() {
    if (!_scrollCtrl.hasClients) return;

    final distance = _scrollCtrl.position.maxScrollExtent - _scrollCtrl.offset;

    if (_firstLoad || distance < 120) {
      _scrollToBottom();
    }
    _firstLoad = false;
  }

  // -------------------- ACTIONS --------------------

  Future<void> _sendMessage() async {
    if (_textCtrl.text.trim().isEmpty) return;

    FirebaseFirestore.instance.collection('messages').add({
      'name': userName ?? 'Anonymous',
      'phone': userPhone,
      'country': userCountry,
      'message': _textCtrl.text.trim(),
      'deviceName': await getDeviceName(),
      'datetime': DateTime.now(),
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [],
    });

    _textCtrl.clear();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat.Hm().format(dt);
    }
    return DateFormat.yMd().format(dt);
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final prev = index > 0 ? _messages[index - 1] : null;
                final showName = prev == null || prev.name != msg.name;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showName)
                        Text(
                          msg.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: msg.name == userName
                              ? Colors.blue[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(msg.message),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type message...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
