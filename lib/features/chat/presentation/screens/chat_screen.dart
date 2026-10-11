import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/helpers/date_formatter.dart';
import 'package:screw_calculator/core/helpers/device_info.dart';
import 'package:screw_calculator/core/helpers/phone_mask_helper.dart';
import 'package:screw_calculator/core/state/generic_cubit/generic_cubit.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/chat/data/datasources/chat_moderation_store.dart';
import 'package:screw_calculator/features/chat/data/datasources/user_presence_manager.dart';
import 'package:screw_calculator/features/chat/data/models/chat_msg_model.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/build_floating_date_header.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/build_reactions__users.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/chat_message_actions.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/input_bar.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/message_bubble.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/new_msg_indicator.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/online_users_list.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/pinned_message.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _firstLoad = true;
  bool _isOnline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  DocumentSnapshot<Object?>? _lastDoc;
  StreamSubscription<Object?>? _liveSub;
  StreamSubscription<Object?>? _typingSub;

  final List<ChatMessage> _messages = [];

  /// المستخدمون المحظورون (هاتف → اسم): رسائلهم مخفية على هذا الجهاز.
  Map<String, String> _blocked = {};

  Future<void> _loadBlocked() async {
    final map = await sl<ChatModerationStore>().blockedUsers();
    if (mounted) setState(() => _blocked = map);
  }

  ChatMessage? _replyingTo;
  String? _editingId;

  late Box<dynamic> userBox;
  late Box<dynamic> cacheBox;

  String? userName;
  String? userPhone;
  int? userAge;
  String? userCountry;
  Set<String> _usersTyping = {};

  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<int> _searchResults = [];
  int _currentSearchIndex = 0;

  final Map<String, GlobalKey> _messageKeys = {};
  GenericCubit<String?> highlightedMessageIdCubit = GenericCubit<String?>();

  @override
  void initState() {
    super.initState();
    _loadBlocked();
    userBox = Hive.box('userBox');
    cacheBox = Hive.box('cachedMessages');
    userName = userBox.get('name')?.toString() ?? 'Anonymous';
    userPhone = userBox.get('phone')?.toString() ?? '';
    userCountry = userBox.get('country')?.toString();
    userAge = int.parse((userBox.get('age') ?? '0').toString());

    _loadCachedMessages();
    _fetchInitialMessages();
    _listenRealtime();
    _listenTyping();
    _markSeen();

    _scrollCtrl.addListener(_onScroll);

    _monitorConnection();

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

    if (_textCtrl.text.isNotEmpty) {
      userBox.put('chatDraft', _textCtrl.text);
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userName == null || userPhone == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        UserPresenceManager().startTracking(
          userName: userName!,
          userPhone: userPhone!,
        );
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        UserPresenceManager().stopTracking();
        break;
      default:
        break;
    }
  }

  void _monitorConnection() {
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
        if (mounted) {
          Utilities().showCustomSnack(
            context,
            txt: 'الصورة كبيرة جداً، يرجى اختيار صورة أصغر',
          );
        }
        return;
      }

      final String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance
          .collection('chats')
          .doc('messages')
          .collection('messages')
          .add({
            'name': userName,
            'phone': userPhone,
            'age': userAge,
            'country': userCountry,
            'message': base64Image,
            'type': 'image',
            'seenBy': <String>[],
            'datetime': DateTime.now(),
            'timestamp': FieldValue.serverTimestamp(),
            'replyTo': _replyingTo?.id,
            'reactions': <String, dynamic>{},
            'isDeleted': false,
            'deviceName': await getDeviceName(),
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
            .map(
              (e) => ChatMessage.fromMap(
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
              ),
            )
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
        .where((m) => m.name != userName && !m.seenBy.contains(userName))
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
      'age': userAge,
      'country': userCountry,
      'message': _textCtrl.text.trim(),
      'datetime': DateTime.now(),
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': <String>[],
      'replyTo': _replyingTo?.id,
      'reactions': <String, dynamic>{},
      'isDeleted': false,
      'deviceName': await getDeviceName(),
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
        (data['reactions'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{},
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
      appBar: ChatAppBar(
        isSearching: _isSearching,
        searchController: _searchCtrl,
        onToggleSearch: _toggleSearch,
        onSearchChanged: _onSearchChanged,
        onPrevResult: _prevSearchResult,
        onNextResult: _nextSearchResult,
        onBackPressed: () => Navigator.pop(context),
        userName: userName ?? '',
        searchResults: _searchResults,
      ),
      body: Column(
        children: [
          OnlineUsersList(currentUserName: userName),

          PinnedMessage(
            userName: userName,
            userPhone: userPhone,
            messageKeys: _messageKeys,
            highlightedMessageIdCubit: highlightedMessageIdCubit,
          ),
          if (_usersTyping.isNotEmpty)
            TypingIndicator(usersTyping: _usersTyping),

          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollCtrl,
                  cacheExtent: 1000,
                  addAutomaticKeepAlives: false,
                  itemCount: _messages.length,
                  itemBuilder: (c, i) {
                    _messageKeys.putIfAbsent(_messages[i].id, GlobalKey.new);

                    return BlocBuilder<
                      GenericCubit<String?>,
                      GenericState<String?>
                    >(
                      bloc: highlightedMessageIdCubit,
                      builder: (context, stateHighLightMsg) {
                        return _buildMessage(_messages[i], i);
                      },
                    );
                  },
                ),

                if (_showNewMsgIndicator)
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: NewMsgIndicator(
                      showNewMsgIndicator: _showNewMsgIndicator,
                      unreadNewMessages: _unreadNewMessages,
                      unreadNewMessagesText: _unreadNewMessagesText,
                      jumpToLatest: _jumpToLatest,
                    ),
                  ),
              ],
            ),
          ),
          if (_replyingTo != null) _replyBar(),
          InputBar(
            textCtrl: _textCtrl,
            pickAndSendImage: _pickAndSendImage,
            sendMessage: _sendMessage,
            updateTyping: _updateTyping,
          ),
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
    highlightedMessageIdCubit.update(data: replyToMessageId);

    try {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        alignment: 0.5,
      );
    } catch (e) {
      debugPrint('Scroll error: $e');
    }

    Future.delayed(const Duration(seconds: 2), () {
      highlightedMessageIdCubit.update(data: null);
    });
  }

  Widget _buildMessage(ChatMessage msg, int index) {
    final msg = _messages[index];
    if (_blocked.containsKey(msg.phoneNumber)) return const SizedBox.shrink();
    final isMe = msg.name == userName;
    final prev = index > 0 ? _messages[index - 1] : null;

    final showName = (prev == null || prev.name != msg.name) && !isMe;

    final isHighlighted =
        (_searchResults.contains(index) &&
            _searchResults[_currentSearchIndex] == index) ||
        highlightedMessageIdCubit.state.data == msg.id;
    final bool isFirstInGroup =
        index == 0 ||
        DateFormatter.daySeparatorMain(_messages[index - 1].timestamp) !=
            DateFormatter.daySeparatorMain(msg.timestamp);

    final messageKey = GlobalKey();
    _messageKeys[msg.id] = messageKey;

    final Widget messageBubble = MessageBubble(
      bubbleKey: messageKey,
      msg: msg,
      isMe: isMe,
      showName: showName,
      isHighlighted: isHighlighted,
      userName: userName,
      replyPreview: msg.replyTo != null ? _replyPreview(msg) : null,
      reactionRow: _reactionRow(msg),
      onSwipeReply: () => setState(() => _replyingTo = msg),
      onLongPress: () => _showOptions(msg),
      onDoubleTap: () => _showReactions(msg),
    );

    if (isFirstInGroup) {
      return StickyHeader(
        header: BuildFloatingDateHeader(
          dateText: DateFormatter.daySeparatorMain(msg.timestamp),
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
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              )
            : CustomText(
                text: r.isDeleted
                    ? 'تم الرد على رسالة محذوفة'
                    : r.name == userName
                    ? r.message
                    : PhoneMaskHelper.maskPhoneNumbers(r.message),
                maxLines: 2,
                fontSize: 12,
                color: AppColors.grayy,
              ),
      ),
    );
  }

  Widget _replyBar() {
    return Container(
      color: context.palette.surfaceElevated,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _replyingTo = null),
          ),
          Expanded(
            child: CustomText(
              text: _replyingTo!.message.length > 1000
                  ? 'رد على صورة'
                  : _replyingTo!.name == userName
                  ? _replyingTo!.message
                  : PhoneMaskHelper.maskPhoneNumbers(_replyingTo!.message),
              fontSize: 14.sp,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MODERATION / OPTIONS ----------------
  Future<void> _reportMessage(ChatMessage msg) =>
      reportChatMessage(context, msg, reporterPhone: userPhone ?? '');

  Future<void> _blockUser(ChatMessage msg) async {
    if (await confirmBlockChatUser(context, msg)) await _loadBlocked();
  }

  void _showOptions(ChatMessage msg) {
    showChatMessageOptions(
      context,
      msg: msg,
      userName: userName,
      userPhone: userPhone,
      onEdit: () => _setEdit(msg),
      onReply: () => setState(() => _replyingTo = msg),
      onDelete: () => _softDelete(msg),
      onReport: () => _reportMessage(msg),
      onBlock: () => _blockUser(msg),
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
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
    showModalBottomSheet<void>(
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
                          ? Colors.blue.withValues(alpha: 0.2)
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
        .map((e) => e.value.toString().split('|').first)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BuildReactionsUsers(
        reactingDetails: reactingDetails,
        userName: userName,
        emoji: emoji,
      ),
    );
  }
}
