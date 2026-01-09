import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/helpers/date_formatter.dart';
import 'package:screw_calculator/helpers/device_info.dart';
import 'package:screw_calculator/helpers/image_helper.dart';
import 'package:screw_calculator/helpers/phone_mask_helper.dart';
import 'package:screw_calculator/screens/chat/models/chat_msg_model.dart';
import 'package:screw_calculator/screens/chat/presentation/widgets/typing_dots.dart';
import 'package:screw_calculator/screens/chat/track_status.dart';
import 'package:screw_calculator/screens/chat/widgets/online_users_list.dart';
import 'package:screw_calculator/screens/chat/widgets/users_status_bottom_sheet.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/utilities.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _firstLoad = true;
  bool _isOnline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

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

  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageId;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box('userBox');
    cacheBox = Hive.box('cachedMessages');
    userName = userBox.get('name')?.toString() ?? 'Anonymous';
    userPhone = userBox.get('phone')?.toString() ?? '';
    userCountry = userBox.get('country')?.toString();

    _loadCachedMessages();
    _fetchInitialMessages();
    _listenRealtime();
    _listenTyping();
    _markSeen();

    _scrollCtrl.addListener(_onScroll);

    _monitorConnection();

    // Restore draft
    final draft = userBox.get('chatDraft') as String?;
    if (draft != null && draft.isNotEmpty) {
      _textCtrl.text = draft;
      userBox.delete('chatDraft');
    }

    if (userName != null && userPhone != null) {
      UserPresenceManager().startTracking(
        userName: userName!,
        userPhone: userPhone!,
      );
    }

    // مراقبة حالة التطبيق (foreground/background)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    UserPresenceManager().stopTracking();
    WidgetsBinding.instance.removeObserver(this);

    _searchCtrl.dispose();
    _liveSub?.cancel();
    _typingSub?.cancel();
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    _updateTyping(false);
    _connectivitySubscription?.cancel();

    // Save draft before disposing
    if (_textCtrl.text.isNotEmpty) {
      userBox.put('chatDraft', _textCtrl.text);
    }

    super.dispose();
  }

  // التعامل مع حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userName == null || userPhone == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // المستخدم رجع للتطبيق
        UserPresenceManager().startTracking(
          userName: userName!,
          userPhone: userPhone!,
        );
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // المستخدم خرج من التطبيق
        UserPresenceManager().stopTracking();
        break;
      default:
        break;
    }
  }

  void _monitorConnection() {
    // Monitor device connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (mounted && wasOnline != _isOnline) {
        setState(() {});

        if (_isOnline) {
          Utilities().showCustomSnack(
            context,
            txt: 'تم استعادة الاتصال بالإنترنت ✓',
          );
          _fetchInitialMessages();
        } else {
          Utilities().showCustomSnack(context, txt: 'لا يوجد اتصال بالإنترنت');
        }
      }
    });

    // Check initial state
    Connectivity().checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
      if (mounted) setState(() {});
    });
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1024,
      );

      if (pickedFile == null) return;

      if (mounted) {
        Utilities().showCustomSnack(context, txt: 'جاري رفع الصورة...');
      }

      final Uint8List imageBytes = await pickedFile.readAsBytes();

      if (imageBytes.lengthInBytes > 1000000) {
        Utilities().showCustomSnack(
          context,
          txt: 'الصورة كبيرة جداً، يرجى اختيار صورة أصغر',
        );
        return;
      }

      String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance
          .collection('chats')
          .doc('messages')
          .collection('messages')
          .add({
            'name': userName,
            'phone': userPhone,
            'message': base64Image,
            'type': 'image',
            'timestamp': FieldValue.serverTimestamp(),
            'seenBy': [],

            'country': userCountry,
            'deviceName': await getDeviceName(),
            'datetime': DateTime.now(),
            'replyTo': _replyingTo?.id,
            'reactions': {},
            'isDeleted': false,
          });

      if (mounted) {
        Utilities().showCustomSnack(context, txt: 'تم إرسال الصورة بنجاح');
      }
    } catch (e) {
      if (mounted) {
        Utilities().showCustomSnack(
          context,
          txt: 'فشل إرسال الصورة، حاول مرة أخرى',
        );
      }
    }
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

    if (!mounted) return;
    setState(() {});
    _scrollToBottom(force: true);
  }

  void _clearOldMessageKeys() {
    final currentIds = _messages.map((m) => m.id).toSet();
    _messageKeys.removeWhere((key, value) => !currentIds.contains(key));
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
    _clearOldMessageKeys();
  }

  // ---------------- LISTEN ----------------
  void _listenRealtime() {
    _liveSub = FirebaseFirestore.instance
        .collection('chats')
        .doc('messages')
        .collection('messages')
        .where('timestamp', isGreaterThan: _lastDoc?.get('timestamp'))
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
          bool hasChanges = false;

          for (final c in snap.docChanges) {
            final msg = ChatMessage.fromDoc(c.doc);

            if (c.type == DocumentChangeType.added &&
                !_messages.any((m) => m.id == msg.id)) {
              _messages.add(msg);
              _cacheMessages([msg]);
              hasChanges = true;

              if (_isNearBottom) {
                _scrollToBottom();
              } else {
                _unreadNewMessages++;
                _unreadNewMessagesText = msg.message;
                _showNewMsgIndicator = true;
              }
            }

            if (c.type == DocumentChangeType.modified) {
              final i = _messages.indexWhere((m) => m.id == msg.id);
              if (i != -1) {
                _messages[i] = msg;
                hasChanges = true;
              }
            }
          }

          if (hasChanges) {
            if (!mounted) return;
            setState(() {});
            _scrollToBottomIfNear();
            _markSeen();
          }
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
    final toUpdate = _messages
        .where(
          (m) =>
              m.name != userName &&
              !(m.seenBy ?? []).contains(userName) &&
              m.id != null,
        )
        .take(10)
        .toList();

    if (toUpdate.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final m in toUpdate) {
      final ref = FirebaseFirestore.instance
          .collection('chats')
          .doc('messages')
          .collection('messages')
          .doc(m.id);
      batch.update(ref, {
        'seenBy': FieldValue.arrayUnion([userName]),
      });

      m.seenBy.add(userName!);
    }

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Error updating seen status: $e');
    }
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
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc('messages')
            .collection('messages')
            .add(data);
      } catch (e) {
        if (mounted) {
          Utilities().showCustomSnack(
            context,
            txt: 'فشل إرسال الرسالة، حاول مرة أخرى',
          );
        }
      }
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
      final String value = '$userName|$emoji';
      if (reactions[userPhone] == value) {
        reactions.remove(userPhone);
      } else {
        reactions[userPhone!] = value;
      }
      tx.update(docRef, {'reactions': reactions});
    });
  }

  // ---------------- MSG UI ----------------
  Widget _messageContent(ChatMessage msg, int index, bool isMe) {
    switch (msg.type) {
      case 'voice':
        return Text(msg.message);
      // case 'image':
      //   return GestureDetector(
      //     onTap: () => _showFullImage(msg.message),
      //     child: ClipRRect(
      //       borderRadius: BorderRadius.circular(8),
      //       child: Image.memory(
      //         base64Decode(msg.message),
      //         width: 200,
      //         height: 200,
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //   );
      // return _voiceBubble(msg, isMe);
      default:
        return _buildMessage(msg, index);
      // return Text(msg.message);
    }
  }

  // ---------------- SCROLL ----------------
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    final max = _scrollCtrl.position.maxScrollExtent;
    final offset = _scrollCtrl.offset;

    const threshold = 120.0;

    final nearBottom = (max - offset) < threshold;

    if (nearBottom != _isNearBottom) {
      setState(() {
        _isNearBottom = nearBottom;

        if (_isNearBottom) {
          _unreadNewMessages = 0;
          _showNewMsgIndicator = false;
        }
      });
    }

    if (offset <= 60 && !_isLoadingMore && _hasMore && _lastDoc != null) {
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
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentSearchIndex = 0;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    _searchResults = List.generate(_messages.length, (i) => i)
        .where((i) => _messages[i].message.toLowerCase().contains(lowerQuery))
        .toList();

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

  bool _isNearBottom = true;
  int _unreadNewMessages = 0;
  String _unreadNewMessagesText = '';
  bool _showNewMsgIndicator = false;

  Widget _newMessageIndicator() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      scale: _showNewMsgIndicator ? 1 : 0,
      child: GestureDetector(
        onTap: _jumpToLatest,
        child: Container(
          width: 0.85.sw,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_downward, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: 'ـ$_unreadNewMessages رسالة جديـدة ',
                      fontFamily: AppFonts.bold,
                      maxLines: 1,
                      fontSize: 15.sp,
                    ),

                    CustomText(
                      text: _unreadNewMessagesText.length > 1000
                          ? 'صورة جديدة'
                          : PhoneMaskHelper.maskPhoneNumbers(
                              _unreadNewMessagesText,
                            ),
                      maxLines: 2,
                      fontSize: 14.sp,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _jumpToLatest() {
    _scrollToBottom();

    setState(() {
      _unreadNewMessages = 0;
      _showNewMsgIndicator = false;
      _isNearBottom = true;
    });
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
        leading: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc('users_presence')
              .collection('users_presence')
              .where('isOnline', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            final onlineCount = snapshot.hasData
                ? snapshot.data!.docs
                      .where((doc) => (doc.data() as Map)['name'] != userName)
                      .length
                : 0;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.people, color: AppColors.white),
                  onPressed: () {
                    UsersStatusBottomSheet.show(
                      context,
                      currentUserName: userName,
                    );
                  },
                ),
                if (onlineCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$onlineCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
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
          OnlineUsersList(currentUserName: userName),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc('pinned')
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData || !snap.data!.exists) return const SizedBox();
              var data = snap.data!;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                color: AppColors.mainColor,
                child: Row(
                  children: [
                    const Icon(Icons.push_pin, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text: data['text'],
                        fontSize: 16.sp,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                      ),

                      // Column(
                      //                         crossAxisAlignment: CrossAxisAlignment.start,
                      //                         children: [
                      //                           Text("رسالة مثبتة من ${data['sender']}",
                      //                               style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      //                           Text(data['text'],
                      //                               maxLines: 1, overflow: TextOverflow.ellipsis,
                      //                               style: const TextStyle(fontSize: 13)),
                      //                         ],
                      //                       ),
                    ),
                    if (userName == 'الآدمن' ||
                        userPhone == '01149504892' ||
                        userPhone == '01556464892') // خيار الإلغاء للآدمن فقط
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => data.reference.delete(),
                      ),
                  ],
                ),
              );
            },
          ),
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
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollCtrl,
                  cacheExtent: 1000,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemCount: _messages.length,
                  itemBuilder: (c, i) {
                    _messageKeys.putIfAbsent(_messages[i].id, GlobalKey.new);

                    return _messageContent(
                      _messages[i],
                      i,
                      _messages[i].name == userName,
                    );
                  },
                ),

                if (_showNewMsgIndicator)
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: _newMessageIndicator(),
                  ),
              ],
            ),
          ),
          if (_replyingTo != null) _replyBar(),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _buildStatusIcons(ChatMessage msg, bool isMe) {
    if (!isMe) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.status == 'sending')
            const Icon(Icons.access_time, size: 12, color: Colors.grey)
          else if (msg.seenBy.isNotEmpty)
            const Icon(Icons.done_all, size: 14, color: Colors.blue)
          else
            const Icon(Icons.done_all, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  void _onReplyTap(String replyToMessageId) async {
    final key = _messageKeys[replyToMessageId];

    if (key == null || key.currentContext == null) {
      Utilities().showCustomSnack(
        context,
        txt: 'الرسالة قديمة جداً، يرجى التمرير للأعلى للوصول إليها ',
      );

      return;
    }
    setState(() {
      _highlightedMessageId = replyToMessageId;
    });

    try {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        alignment: 0.5, // وضع الرسالة في منتصف الشاشة بالضبط
      );
    } catch (e) {
      debugPrint('Scroll error: $e');
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _highlightedMessageId = null);
      }
    });
  }

  Widget _buildFloatingDateHeader(String dateText) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.grayy.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          dateText,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
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
        (_searchResults.contains(index) &&
            _searchResults[_currentSearchIndex] == index) ||
        _highlightedMessageId == msg.id;
    final bool isFirstInGroup =
        index == 0 ||
        DateFormatter.daySeparatorMain(_messages[index - 1].timestamp) !=
            DateFormatter.daySeparatorMain(msg.timestamp);

    final messageKey = GlobalKey();
    _messageKeys[msg.id] = messageKey;

    final Widget messageBubble = Container(
      key: messageKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            children: [
              if (msg.isDeleted)
                Column(
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
                        textAlign: msg.name == userName
                            ? TextAlign.end
                            : TextAlign.start,
                      ),
                    ),
                  ],
                ),

              Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // if (showDay)
                  //   Center(
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(vertical: 8),
                  //       child: IntrinsicHeight(
                  //         child: Row(
                  //           children: [
                  //             const Expanded(
                  //               child: Divider(
                  //                 color: Colors.grey,
                  //                 thickness: 0.5,
                  //                 endIndent: 10,
                  //               ),
                  //             ),
                  //             Text(
                  //               DateFormatter.daySeparatorMain(msg.timestamp),
                  //               style: const TextStyle(color: Colors.grey),
                  //             ),
                  //             const Expanded(
                  //               child: Divider(
                  //                 color: Colors.grey,
                  //                 thickness: 0.5,
                  //                 indent: 10,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  if (!msg.isDeleted)
                    IntrinsicWidth(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),

                        child: SwipeTo(
                          iconColor: AppColors.white,
                          onRightSwipe: (details) {
                            setState(() {
                              _replyingTo = msg;
                            });
                            HapticFeedback.mediumImpact();
                          },
                          child: GestureDetector(
                            onLongPress: () => _showOptions(msg),
                            onDoubleTap: () => _showReactions(msg),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                left: 8,
                                top: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    // width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? Colors.green[200]
                                          : isMe
                                          ? Colors.blue[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12),
                                        topRight: const Radius.circular(12),
                                        bottomLeft: Radius.circular(
                                          isMe ? 12 : 0,
                                        ),
                                        bottomRight: Radius.circular(
                                          isMe ? 0 : 12,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showName)
                                          Row(
                                            children: [
                                              // Container(
                                              //   height: 8,
                                              //   width: 8,
                                              //   decoration: BoxDecoration(
                                              //     color: _isOnline
                                              //         ? AppColors.green
                                              //         : AppColors.red,
                                              //     shape: BoxShape.circle,
                                              //   ),
                                              // ),
                                              // const SizedBox(width: 4),
                                              CustomText(
                                                text: msg.name,
                                                fontSize: 14.sp,
                                                color: isMe
                                                    ? AppColors.mainColor
                                                    : AppColors.secondaryColor,
                                                fontFamily: AppFonts.bold,
                                              ),
                                            ],
                                          ),
                                        if (msg.replyTo != null)
                                          _replyPreview(msg),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (msg.type != 'image')
                                              Flexible(
                                                child: CustomText(
                                                  text: isMe
                                                      ? msg.message
                                                      : PhoneMaskHelper.maskPhoneNumbers(
                                                          msg.message,
                                                        ),
                                                  fontSize: 14.sp,
                                                  textAlign: TextAlign.start,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            if (msg.type == 'image')
                                              GestureDetector(
                                                onTap: () =>
                                                    ImageHelper.showFullImage(
                                                      context,
                                                      msg.message,
                                                    ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    base64Decode(msg.message),
                                                    width: 0.2.sw,
                                                    height: 0.2.sh,
                                                    fit: BoxFit.cover,
                                                    cacheWidth: 400,
                                                    // cacheHeight: 400,
                                                    gaplessPlayback: true,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  intl.DateFormat.jm().format(
                                                    msg.timestamp,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.grayy2,
                                                  ),
                                                ),

                                                _buildStatusIcons(msg, isMe),
                                                if (msg.seenBy.isNotEmpty &&
                                                    msg.name == userName)
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 4),

                                                      Text(
                                                        '👁 ${msg.seenBy.length}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .greenDark,
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
                        ),
                      ),
                    ),
                  _reactionRow(msg),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isFirstInGroup) {
      return StickyHeader(
        header: _buildFloatingDateHeader(
          DateFormatter.daySeparatorMain(msg.timestamp),
        ),
        content: messageBubble,
      );
    }

    return messageBubble;
  }

  Widget _replyPreview(ChatMessage msg) {
    final r = _messages.firstWhere(
      (m) => m.id == msg.replyTo,
      orElse: () => msg,
    );
    return GestureDetector(
      onTap: () => _onReplyTap(msg.replyTo!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(5),
        ),
        child: r.message.length > 1000
            ? Image.memory(
                base64Decode(r.message),
                width: 0.2.sw,
                height: 0.1.sh,
                fit: BoxFit.cover,
                cacheWidth: 400,
                // cacheHeight: 400,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              )
            : Text(
                r.isDeleted
                    ? 'تم الرد على رسالة محذوفة'
                    : '${r.name == userName ? r.message : PhoneMaskHelper.maskPhoneNumbers(r.message)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
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
              _replyingTo!.message.length > 1000
                  ? 'رد على صورة'
                  : _replyingTo!.name == userName
                  ? _replyingTo!.message
                  : PhoneMaskHelper.maskPhoneNumbers(_replyingTo!.message),
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
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.mainColor,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
                onPressed: _pickAndSendImage,
              ),
            ),

            const SizedBox(width: 6),
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
              backgroundColor: AppColors.mainColor,
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
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: CustomText(
              text: 'تثبيت الرسالة',
              fontSize: 14.sp,
              color: AppColors.black,
              textAlign: TextAlign.start,
            ),
            onTap: () {
              FirebaseFirestore.instance.collection('chats').doc('pinned').set({
                'text': msg.message,
                'sender': msg.name,
                'phone': msg.phoneNumber,
                'id': msg.id,
              });
              Navigator.pop(context);
            },
          ),
          if (msg.name == userName)
            ListTile(
              leading: const Icon(Icons.edit),
              title: CustomText(
                text: 'تعديل الرسالة',
                fontSize: 14.sp,
                color: AppColors.black,
                textAlign: TextAlign.start,
              ),
              onTap: () {
                _setEdit(msg);
                Navigator.pop(context);
              },
            ),

          ListTile(
            leading: const Icon(Icons.reply),
            title: CustomText(
              text: 'الرد على الرسالة',
              fontSize: 14.sp,
              color: AppColors.black,
              textAlign: TextAlign.start,
            ),
            onTap: () {
              setState(() => _replyingTo = msg);
              Navigator.pop(context);
            },
          ),
          if (msg.phoneNumber == userPhone ||
              userPhone == '01149504892' ||
              userPhone == '01556464892')
            ListTile(
              leading: const Icon(Icons.delete),
              title: CustomText(
                text: 'حذف الرسالة',
                fontSize: 14.sp,
                color: AppColors.black,
                textAlign: TextAlign.start,
              ),
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
                        child: CustomText(
                          text: 'إلغاء',
                          fontSize: 15.sp,
                          color: AppColors.black,
                          fontFamily: AppFonts.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: CustomText(
                          text: 'حذف',
                          fontSize: 15.sp,
                          color: AppColors.red,
                        ),
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
        final dynamic currentFullReaction = msg.reactions[userPhone];
        final dynamic currentEmoji = currentFullReaction?.split('|').last;

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
}
