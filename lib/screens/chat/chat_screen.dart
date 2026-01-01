import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/helpers/device_info.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';
import 'package:screw_calculator/screens/chat/widgets/typing_dots.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _firstLoad = true;

  DocumentSnapshot? _lastDoc;
  StreamSubscription? _liveSub;
  StreamSubscription? _typingSub;

  final List<ChatMessage> _messages = [];
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
    _updateTyping(false);
    super.dispose();
  }

  // ---------------- DATA ----------------

  void _loadCachedMessages() {
    final cached =
        cacheBox.values
            .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _messages.addAll(cached);
  }

  Future<void> _fetchInitialMessages() async {
    final q = FirebaseFirestore.instance
        .collection('chats')
        .doc('messages')
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    final snap = await q.get();
    if (snap.docs.isEmpty) return;

    _lastDoc = snap.docs.last;

    final fresh = snap.docs.map(ChatMessage.fromDoc).toList().reversed.toList();

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
        .collection('chats')
        .doc('messages')
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

    final older = snap.docs.map(ChatMessage.fromDoc).toList().reversed.toList();

    _messages.insertAll(0, older);
    _cacheMessages(older);

    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.jumpTo(beforeOffset + 240);
    });

    _isLoadingMore = false;
  }

  // ---------------- LISTEN ----------------

  void _listenRealtime() {
    _liveSub = FirebaseFirestore.instance
        .collection('chats')
        .doc('messages')
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
          for (final c in snap.docChanges) {
            final msg = ChatMessage.fromDoc(c.doc);

            if (c.type == DocumentChangeType.added &&
                !_messages.any((m) => m.id == msg.id)) {
              _messages.add(msg);
              _cacheMessages([msg]);
            }

            if (c.type == DocumentChangeType.modified) {
              final i = _messages.indexWhere((m) => m.id == msg.id);
              if (i != -1) _messages[i] = msg;
            }
          }

          setState(() {});
          _scrollToBottomIfNear();
        });
  }

  void _listenTyping() {
    _typingSub = FirebaseFirestore.instance
        .collection('chats')
        .doc('typing')
        .collection('typing')
        .snapshots()
        .listen((snap) {
          final typing = <String>{};
          for (var d in snap.docs) {
            if (d.id != userName && d['typing'] == true) {
              typing.add(d.id);
            }
          }
          setState(() => _usersTyping = typing);
        });
  }

  void _updateTyping(bool v) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc('typing')
        .collection('typing')
        .doc(userName)
        .set({'typing': v});
  }

  void _cacheMessages(List<ChatMessage> msgs) {
    for (final m in msgs) {
      cacheBox.put(m.id, m.toMap());
    }
  }

  // ---------------- ACTIONS ----------------

  Future<void> _sendMessage() async {
    if (_textCtrl.text.trim().isEmpty) return;

    final data = {
      'name': userName ?? 'Anonymous',
      'phone': userPhone,
      'country': userCountry,
      'message': _textCtrl.text.trim(),
      'deviceName': await getDeviceName(),
      'datetime': DateTime.now(),
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [],
      'replyTo': _replyingTo?.id,
      'reactions': {},
      'isDeleted': false,
    };

    if (_editingId != null) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('messages')
          .collection('messages')
          .doc(_editingId)
          .update(data);
      _editingId = null;
    } else {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('messages')
          .collection('messages')
          .add(data);
    }

    _textCtrl.clear();
    _replyingTo = null;
    _updateTyping(false);
  }

  Future<void> _softDelete(ChatMessage msg) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc('messages')
        .collection('messages')
        .doc(msg.id)
        .update({'isDeleted': true, 'message': '', 'reactions': {}});
  }

  void _setEdit(ChatMessage msg) {
    setState(() {
      _textCtrl.text = msg.message;
      _editingId = msg.id;
      _replyingTo = null;
    });
  }

  Future<void> _addReaction(ChatMessage msg, String emoji) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc('messages')
        .collection('messages')
        .doc(msg.id)
        .update({'reactions.$userName': emoji});
  }

  String _daySeparator(DateTime dt) {
    final now = DateTime.now();
    final d = DateTime(dt.year, dt.month, dt.day);
    final diff = now.difference(d).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM').format(dt);
  }

  // ---------------- MSG UI ----------------

  Widget _messageContent(ChatMessage msg, int index, bool isMe) {
    switch (msg.type) {
      case 'voice':
        return Text(msg.message);
      // return _voiceBubble(msg, isMe);
      default:
        return _buildMessage(msg, index);
      // return Text(msg.message);
    }
  }

  // ---------------- SCROLL ----------------

  void _onScroll() {
    if (_scrollCtrl.position.pixels < 60) _fetchOlderMessages();
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
    final d = _scrollCtrl.position.maxScrollExtent - _scrollCtrl.offset;
    if (_firstLoad || d < 120) _scrollToBottom();
    _firstLoad = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
      body: Column(
        children: [
          if (_usersTyping.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const TypingDots(),
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
              itemBuilder: (c, i) {
                return _messageContent(
                  _messages[i],
                  i,
                  _messages[i].name == userName,
                );
              },
            ),
          ),
          if (_replyingTo != null) _replyBar(),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, int index) {
    final msg = _messages[index];

    final prev = index > 0 ? _messages[index - 1] : null;

    final showName = prev == null || prev.name != msg.name;

    final showDay = prev == null || prev.timestamp.day != msg.timestamp.day;
    final isMe = msg.name == userName;

    if (msg.isDeleted) {
      return Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8, left: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grayy2),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                // Text(
                //   "تم حذف هذه الرسالة",
                //   maxLines: 2,
                //   overflow: TextOverflow.ellipsis,
                //   style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic,color: Colors.white),
                // ),
                CustomText(
                  text: 'تم حذف هذه الرسالة',
                  // 'This message was deleted',
                  fontSize: 12,
                  color: AppColors.grey,
                  textAlign: msg.name == userName
                      ? TextAlign.end
                      : TextAlign.start,
                ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: isMe
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
                      style: const TextStyle(color: Colors.grey),
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

        GestureDetector(
          onLongPress: () => _showOptions(msg),
          onDoubleTap: () => _showReactions(msg),
          child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 8, top: 4),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (msg.replyTo != null) _replyPreview(msg),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showName)
                        CustomText(
                          text: ('${msg.name}'),
                          fontSize: 14.sp,
                          color: isMe
                              ? AppColors.mainColor
                              : AppColors.secondaryColor,
                          fontFamily: AppFonts.bold,
                        ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CustomText(
                              text: isMe
                                  ? msg.message
                                  : maskPhoneNumbers(msg.message),
                              fontSize: 14.sp,
                              textAlign: TextAlign.start,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat.jm().format(msg.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.grayy2,
                                ),
                              ),

                              // if (isMe && msg.seenBy.isNotEmpty)
                              //   const Padding(
                              //     padding: EdgeInsets.only(left: 4),
                              //     child: Icon(
                              //       Icons.done_all,
                              //       size: 12,
                              //       color: Colors.green,
                              //     ),
                              //   ),
                              if (msg.seenBy.isNotEmpty && msg.name == userName)
                                Row(
                                  children: [
                                    const SizedBox(width: 4),

                                    const Icon(
                                      Icons.remove_red_eye,
                                      size: 12,
                                      color: AppColors.greenDark,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${msg.seenBy.length}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.greenDark,
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
              ],
            ),
          ),
        ),
        _reactionRow(msg),
      ],
    );
  }

  Widget _reactionRow(ChatMessage msg) {
    if (msg.reactions.isEmpty) return const SizedBox();
    final grouped = <String, int>{};
    msg.reactions.values.forEach((e) => grouped[e] = (grouped[e] ?? 0) + 1);

    return Wrap(
      children: grouped.entries
          .map(
            (e) => GestureDetector(
              onTap: () => _showReactionUsers(msg, e.key),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  padding: const EdgeInsets.all(4),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  label: Text('${e.key} ${e.value}'),
                  // color: WidgetStateProperty.all(Colors.transparent),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _replyPreview(ChatMessage msg) {
    final r = _messages.firstWhere(
      (m) => m.id == msg.replyTo,
      orElse: () => msg,
    );
    return Container(
      // padding: const EdgeInsets.all(6),
      // margin: const EdgeInsets.only(bottom: 4),
      // decoration: BoxDecoration(
      //   color: Colors.blueGrey[100],
      //   borderRadius: BorderRadius.circular(6),
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        r.isDeleted
            ? 'تم الرد على رسالة محذوفة' //'Replied to deleted message'
            : '↪ ${r.name == userName ? r.message : maskPhoneNumbers(r.message)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _replyBar() {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _replyingTo!.name == userName
                  ? _replyingTo!.message
                  : maskPhoneNumbers(_replyingTo!.message),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(6),
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

            /* const SizedBox(width: 6),
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressUp: _stopRecording,
              child: CircleAvatar(
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                child: Icon(_isRecording ? Icons.mic : Icons.mic_none),
              ),
            ),*/
            const SizedBox(width: 6),
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
    );
  }

  // ---------------- OPTIONS ----------------

  void _showOptions(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.name == userName)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                _setEdit(msg);
                Navigator.pop(context);
              },
            ),

          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              setState(() => _replyingTo = msg);
              Navigator.pop(context);
            },
          ),
          if (msg.name == userName ||
              msg.phoneNumber == '01149504892' ||
              msg.phoneNumber == '01556464892')
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.pop(context);

                final confirm = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Do you want to delete this message?'),
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
                  _softDelete(msg);
                }
              },
            ),
        ],
      ),
    );
  }

  void _showReactions(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: ['❤️', '😂', '👍', '🔥']
            .map(
              (e) => IconButton(
                icon: Text(e, style: const TextStyle(fontSize: 26)),
                onPressed: () {
                  _addReaction(msg, e);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _showReactionUsers(ChatMessage msg, String emoji) {
    final users = msg.reactions.entries
        .where((e) => e.value == emoji)
        .map((e) => e.key)
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: users
            .map(
              (u) => ListTile(
                leading: const Icon(Icons.person),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(u), Text(emoji)],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String maskPhoneNumbers(String text) {
    // التعبير النمطي المطور:
    // (?:\+2|002)?      <- كود الدولة (اختياري)
    // \s?               <- مسافة (اختياري)
    // (010|011|012|015) <- بداية رقم الموبايل المصري
    // [-\s]?            <- شرطة أو مسافة (اختياري)
    // \d{4,8}           <- يبحث عن حد أدنى 4 أرقام وحد أقصى 8 أرقام بعد الكود

    final RegExp phoneRegex = RegExp(
      r'(?:\+2|002)?\s?(010|011|012|015)[-\s]?\d{4,8}',
      caseSensitive: false,
    );

    // replaceAllMapped تبحث عن كل التطابقات وتستبدلها
    return text.replaceAllMapped(phoneRegex, (match) {
      String found = match.group(0)!;
      // استبدال طول الرقم المكتشف بالكامل بعلامات *
      return '*' * found.length;
    });
  }
}
