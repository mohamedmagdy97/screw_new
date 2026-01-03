import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;
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

  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<int> _searchResults = [];
  int _currentSearchIndex = 0;

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
    _markSeen();

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
            _markSeen();
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
          final now = DateTime.now();
          final typing = <String>{};
          for (var d in snap.docs) {
            if (d.id == userName) continue;

            final ts = (d['updatedAt'] as Timestamp?)?.toDate();
            if (d['typing'] == true &&
                ts != null &&
                now.difference(ts).inSeconds <= 5) {
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
        .set({'typing': v, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> _markSeen() async {
    // افحص فقط آخر 10 رسائل أو الرسائل التي لم يظهر اسمك في seenBy الخاص بها
    final unreadMessages = _messages
        .where(
          (m) => m.name != userName && !(m.seenBy ?? []).contains(userName),
        )
        .take(10); // تحديد العدد يحسن الأداء جداً

    if (unreadMessages.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final m in unreadMessages) {
      final ref = FirebaseFirestore.instance
          .collection('chats')
          .doc('messages')
          .collection('messages')
          .doc(m.id);
      batch.update(ref, {
        'seenBy': FieldValue.arrayUnion([userName]),
      });
    }
    await batch.commit();
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

  Future<void> toggleReaction(ChatMessage msg, String emoji) async {
    if (userPhone == null || userName == null) return;
    HapticFeedback.lightImpact();

    final docRef = FirebaseFirestore.instance
        .collection('chats')
        .doc('messages')
        .collection('messages')
        .doc(msg.id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;

      final data = snap.data()!;
      final Map<String, dynamic> reactions = Map<String, dynamic>.from(
        data['reactions'] ?? {},
      );
      String value = '$userName|$emoji';
      if (reactions[userPhone] == value) {
        reactions.remove(userPhone);
      } else {
        reactions[userPhone!] = value;
      }
      tx.update(docRef, {'reactions': reactions});
    });
  }

  String _daySeparator(DateTime dt) {
    final dateLocal = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      dateLocal.year,
      dateLocal.month,
      dateLocal.day,
    );
    final int diff = today.difference(messageDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    if (dateLocal.year == now.year) {
      return intl.DateFormat('d MMM').format(dateLocal);
    }
    return intl.DateFormat('d MMM y').format(dateLocal);
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

  // ---------------- SEARCH ----------------
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchCtrl.clear();
      _searchResults.clear();
      _currentSearchIndex = 0;
    });
  }

  void _onSearchChanged(String query) {
    _searchResults.clear();
    if (query.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].message.toLowerCase().contains(query.toLowerCase())) {
        _searchResults.add(i);
      }
    }

    if (_searchResults.isNotEmpty) {
      _currentSearchIndex = 0;
      _scrollToSearchResult();
    }

    setState(() {});
  }

  void _nextSearchResult() {
    if (_searchResults.isEmpty) return;

    _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
    _scrollToSearchResult();
  }

  void _prevSearchResult() {
    if (_searchResults.isEmpty) return;

    _currentSearchIndex =
        (_currentSearchIndex - 1 + _searchResults.length) %
        _searchResults.length;
    _scrollToSearchResult();
  }

  void _scrollToSearchResult() {
    final index = _searchResults[_currentSearchIndex];

    _scrollCtrl.animateTo(
      index * 72.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {});
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isSearching
              ? TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  cursorColor: AppColors.white,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: AppFonts.regular,
                  ),
                  decoration: InputDecoration(
                    hintText: 'بحث…',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFonts.regular,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                )
              : CustomText(text: 'الشات', fontSize: 22.sp),
        ),

        actions: [
          if (_isSearching && _searchResults.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, color: AppColors.white),
              onPressed: _prevSearchResult,
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.white,
              ),
              onPressed: _nextSearchResult,
            ),
          ],

          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.white,
            ),
            onPressed: _toggleSearch,
          ),
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
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const TypingDots(),
                  const SizedBox(width: 4),
                  CustomText(
                    text: ' يكتب الأن ${_usersTyping.join(', ')}',
                    textAlign: TextAlign.end,
                    fontSize: 12,
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
    final isMe = msg.name == userName;

    final prev = index > 0 ? _messages[index - 1] : null;

    final showName = (prev == null || prev.name != msg.name) && !isMe;

    final showDay = prev == null || prev.timestamp.day != msg.timestamp.day;

    final isHighlighted =
        _searchResults.contains(index) &&
        _searchResults[_currentSearchIndex] == index;

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
            child: CustomText(
              text: 'تم حذف هذه الرسالة',
              fontSize: 12,
              color: AppColors.grey,
              textAlign: msg.name == userName ? TextAlign.end : TextAlign.start,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.green[200]
                        : isMe
                        ? Colors.blue[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showName)
                        CustomText(
                          text: msg.name,
                          fontSize: 14.sp,
                          color: isMe
                              ? AppColors.mainColor
                              : AppColors.secondaryColor,
                          fontFamily: AppFonts.bold,
                        ),

                      if (msg.replyTo != null) _replyPreview(msg),

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
                                intl.DateFormat.jm().format(msg.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.grayy2,
                                ),
                              ),
                              if (msg.seenBy.isNotEmpty && msg.name == userName)
                                Row(
                                  children: [
                                    const SizedBox(width: 4),

                                    Text(
                                      '👁 ${msg.seenBy.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
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

  Widget _replyPreview(ChatMessage msg) {
    final r = _messages.firstWhere(
      (m) => m.id == msg.replyTo,
      orElse: () => msg,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        r.isDeleted
            ? 'تم الرد على رسالة محذوفة'
            : '${r.name == userName ? r.message : maskPhoneNumbers(r.message)}',
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
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك ...',
                  hintStyle: TextStyle(fontFamily: AppFonts.regular),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintTextDirection: TextDirection.rtl,
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
                minLines: 1,
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

  // ---------------- REACTION ----------------
  Widget _reactionRow(ChatMessage msg) {
    if (msg.reactions.isEmpty) return const SizedBox();
    final grouped = <String, int>{};
    for (var value in msg.reactions.values) {
      final emoji = value.toString().split('|').last;
      grouped[emoji] = (grouped[emoji] ?? 0) + 1;
    }

    final isMe = msg.name == userName;

    return Padding(
      padding: EdgeInsets.only(right: isMe ? 8 : 0, left: isMe ? 0 : 8, top: 4),
      child: Wrap(
        spacing: 4,
        children: grouped.entries.map((e) {
          return GestureDetector(
            onTap: () => _showReactionUsers(msg, e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${e.key} ${e.value}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showReactions(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final String? currentFullReaction = msg.reactions[userPhone];
        final String? currentEmoji = currentFullReaction?.split('|').last;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: ['❤️', '😂', '👍', '🔥', '😮', '😢']
                .map(
                  (e) => Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentEmoji == e
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: IconButton(
                      icon: Text(e, style: const TextStyle(fontSize: 30)),
                      onPressed: () {
                        toggleReaction(msg, e);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _showReactionUsers(ChatMessage msg, String emoji) {
    final reactingDetails = msg.reactions.entries
        .where((e) => e.value.toString().split('|').last == emoji)
        .map(
          (e) => e.value.toString().split('|').first,
        ) // نأخذ الجزء الأول وهو الاسم
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomText(
              text: 'المتفاعلون بـ $emojiـ',
              fontSize: 14.sp,
              fontFamily: AppFonts.bold,
              color: AppColors.black,
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reactingDetails.length,
              itemBuilder: (context, index) {
                final nName = reactingDetails[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: CustomText(
                    text: nName == userName
                        ? 'أنا (أنت)'
                        : reactingDetails[index],
                    fontSize: 16.sp,
                    color: AppColors.black,
                    textAlign: TextAlign.start,
                  ),
                  trailing: Text(emoji, style: TextStyle(fontSize: 16.sp)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String maskPhoneNumbers(String text) {
    final RegExp phoneRegex = RegExp(
      r'(?:\+2|002)?\s?(010|011|012|015)[-\s]?\d{4,8}',
      caseSensitive: false,
    );
    return text.replaceAllMapped(phoneRegex, (match) {
      String found = match.group(0)!;
      return '*' * found.length;
    });
  }
}
