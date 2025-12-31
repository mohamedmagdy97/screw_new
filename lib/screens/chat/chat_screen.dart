import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/helpers/device_info.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _firstLoad = true;

  DocumentSnapshot? _lastDoc;
  StreamSubscription? _liveSub;
  StreamSubscription? _typingSub;

  List<ChatMessage> _messages = [];
  ChatMessage? _replyingTo;
  String? _editingId;

  late Box userBox;
  late Box cacheBox;

  String? userName;
  String? userPhone;
  String? userCountry;

  Set<String> _usersTyping = {};

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
    _listenTyping();

    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    _typingSub?.cancel();
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  String _daySeparator(DateTime dt) {
    final now = DateTime.now();
    final d = DateTime(dt.year, dt.month, dt.day);
    final diff = now.difference(d).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM').format(dt);
  }

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
          for (var change in snap.docChanges) {
            final msg = ChatMessage.fromFirestore(change.doc);
            if (change.type == DocumentChangeType.added) {
              if (!_messages.any((e) => e.id == msg.id)) {
                _messages.add(msg);
                _cacheMessages([msg]);
              }
            } else if (change.type == DocumentChangeType.modified) {
              final index = _messages.indexWhere((e) => e.id == msg.id);
              if (index >= 0) {
                _messages[index] = msg;
                _cacheMessages([msg]);
              }
            } else if (change.type == DocumentChangeType.removed) {
              _messages.removeWhere((e) => e.id == msg.id);
              cacheBox.delete(msg.id);
            }
          }

          setState(() {});
          _scrollToBottomIfNear();
        });
  }

  void _listenTyping() {
    _typingSub = FirebaseFirestore.instance
        .collection('typing')
        .snapshots()
        .listen((snap) {
          final typingUsers = <String>{};
          for (var doc in snap.docs) {
            if (doc.id != userName && doc['typing'] == true) {
              typingUsers.add(doc.id);
            }
          }
          setState(() {
            _usersTyping = typingUsers;
          });
        });
  }

  void _updateTyping(bool typing) {
    FirebaseFirestore.instance.collection('typing').doc(userName).set({
      'typing': typing,
    });
  }

  void _cacheMessages(List<ChatMessage> msgs) {
    for (final m in msgs) {
      cacheBox.put(m.id, m.toHive());
    }
  }

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

  Future<void> _sendMessage() async {
    if (_textCtrl.text.trim().isEmpty) return;

    final messageData = {
      'name': userName ?? 'Anonymous',
      'phone': userPhone,
      'country': userCountry,
      'message': _textCtrl.text.trim(),
      'deviceName': await getDeviceName(),
      'datetime': DateTime.now(),
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [],
      'replyTo': _replyingTo?.id,
    };

    if (_editingId != null) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(_editingId)
          .update(messageData);
      _editingId = null;
    } else {
      await FirebaseFirestore.instance.collection('messages').add(messageData);
    }

    _textCtrl.clear();
    _replyingTo = null;
    _scrollToBottom(force: true);

    _updateTyping(false);
  }

  Future<void> _deleteMessage(ChatMessage msg) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(msg.id)
          .delete();
      _messages.removeWhere((m) => m.id == msg.id);
      cacheBox.delete(msg.id);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete message: $e')));
    }
  }

  void _setReply(ChatMessage msg) {
    setState(() {
      _replyingTo = msg;
    });
  }

  void _setEdit(ChatMessage msg) {
    setState(() {
      _textCtrl.text = msg.message;
      _editingId = msg.id;
      _replyingTo = null;
    });
  }

  String _formatTime12h(DateTime dt) {
    final hour = DateFormat.jm().format(dt); // 12h format with AM/PM
    return hour;
  }

  void _showMessageOptions(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                _setReply(msg);
                Navigator.pop(context);
              },
            ),
            if (msg.name == userName)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  _setEdit(msg);
                  Navigator.pop(context);
                },
              ),
            if (msg.name == userName ||
                msg.phoneNumber == "01149504892" ||
                msg.phoneNumber == "01556464892")
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                        'Do you want to delete this message?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    _deleteMessage(msg);
                  }
                },
              ),
          ],
        );
      },
    );
  }

  void _addReaction(ChatMessage msg, String emoji) {
    FirebaseFirestore.instance.collection('messages').doc(msg.id).update({
      'reactions.$emoji': FieldValue.arrayUnion([userName]),
    });
  }

  // وظيفة جديدة لعرض قائمة أسماء الأشخاص الذين ضغطوا على Reaction معين
  void _showReactionUsers(ChatMessage msg, String emoji) {
    final users = List<String>.from(msg.reactions[emoji] ?? []);
    if (users.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reaction $emoji'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(users[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String maskPhoneNumbers(String text) {
    if (text == null || text.isEmpty) return "";
    final RegExp phoneRegex = RegExp(
      r'(?:\+2|002)?\s?(010|011|012|015)[-\s]?(?:[0-9][-\s]?){8}',
      caseSensitive: false,
    );

    return text.replaceAllMapped(phoneRegex, (match) {
      return '***********';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'الشات', fontSize: 22.sp),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Transform.flip(
              flipX: true,
              child: const Icon(
                Icons.arrow_back_ios_sharp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.bg,

      body: Column(
        children: [
          if (_usersTyping.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const _TypingDots(),
                  const SizedBox(width: 6),
                  Text(
                    '${_usersTyping.join(', ')} typing…',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final prev = index > 0 ? _messages[index - 1] : null;
                final showName = prev == null || prev.name != msg.name;

                // final reactions =
                // Map<String, dynamic>.from(_messages[index].reactions);

                final reactions = Map<String, dynamic>.from(
                  msg.reactions ?? {},
                );

                final showDay =
                    prev == null || prev.timestamp.day != msg.timestamp.day;

                return GestureDetector(
                  onLongPress: () => _showMessageOptions(msg),
                  onDoubleTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => Wrap(
                      children: ['❤️', '😂', '👍', '🔥']
                          .map(
                            (e) => IconButton(
                              icon: Text(
                                e,
                                style: const TextStyle(fontSize: 24),
                              ),
                              onPressed: () {
                                _addReaction(msg, e);
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  // onLongPress: () => _deleteMessage(msg),
                  // onDoubleTap: () => _setReply(msg),
                  // onTap: () => _setEdit(msg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: msg.name == userName
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showDay)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Colors.grey,
                                        thickness: 0.5,
                                        endIndent: 10,
                                      ),
                                    ),
                                    Text(
                                      _daySeparator(msg.timestamp),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Colors.grey,
                                        thickness: 0.5,
                                        indent: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        if (showName)
                          Text(
                            msg.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (msg.replyTo != null &&
                            msg.replyTo!.isNotEmpty &&
                            _messages
                                    .firstWhereOrNull(
                                      (m) => m.id == msg.replyTo,
                                    )
                                    ?.message !=
                                null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  // "↪ ${_messages.firstWhereOrNull((m) => m.id == msg.replyTo)?.message}",
                                  "↪ ${maskPhoneNumbers(_messages.firstWhereOrNull((m) => m.id == msg.replyTo)!.message!)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: msg.name == userName
                                ? Colors.blue[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(maskPhoneNumbers(msg.message)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _formatTime12h(msg.timestamp),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.grayy,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (msg.seenBy.isNotEmpty &&
                                          msg.name == userName)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.remove_red_eye,
                                              size: 12,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${msg.seenBy.length}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (reactions.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: reactions.entries.map((e) {
                              return GestureDetector(
                                onTap: () => _showReactionUsers(msg, e.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Colors.grey[300],
                                    // color: msg.name == userName
                                    //     ? Colors.blue[100]
                                    //     : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${e.key} ${e.value.length}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        //  Wrap(
                        //   children: reactions.entries
                        //       .map((e) => Text(
                        //       '${e.key} ${e.value.length}'))
                        //       .toList(),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_replyingTo != null)
            Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Replying to: ${maskPhoneNumbers(_replyingTo!.message)}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
              ),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: AppColors.bg,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (text) => _updateTyping(text.isNotEmpty),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== WIDGETS =====================

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final d = ((_c.value * 3).floor() % 3) + 1;
        return Text(
          '.' * d,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        );
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
