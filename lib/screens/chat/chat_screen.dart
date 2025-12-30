import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Box userBox = Hive.box('userBox');

  String? userName;
  String? userPhone;
  String? userCountry;

  final int _limit = 20;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _messages = [];

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _scrollController.addListener(_scrollListener);
    _fetchInitialMessages();
  }

  void _loadUser() {
    userName = userBox.get('name')?.toString();
    userPhone = userBox.get('phone')?.toString();
    userCountry = userBox.get('country')?.toString();
  }

  /// تحميل الرسائل الأولى
  void _fetchInitialMessages() async {
    final Query query = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    final QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _messages = snapshot.docs.reversed.toList();
      _lastDocument = snapshot.docs.last;
    } else {
      _hasMore = false;
    }

    setState(() {});

    // Scroll تلقائي عند أول تحميل
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// تحميل الرسائل القديمة عند scroll لأعلى
  void _fetchMoreMessages() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;
    _isLoadingMore = true;

    final scrollOffsetBefore = _scrollController.offset;

    final Query query = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_limit);

    final QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;

      setState(() {
        _messages.insertAll(0, snapshot.docs.reversed.toList());
      });

      // حافظ على Scroll عند إضافة الرسائل القديمة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(
          scrollOffsetBefore + snapshot.docs.length * 60,
        );
      });
    } else {
      _hasMore = false;
    }

    _isLoadingMore = false;
  }

  /// الاستماع للـ scroll لأعلى
  void _scrollListener() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      _fetchMoreMessages();
    }
  }

  /// إرسال رسالة
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    FirebaseFirestore.instance.collection('messages').add({
      'name': userName,
      'phone': userPhone,
      'country': userCountry,
      'message': _controller.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    // Scroll تلقائي بعد إضافة الرسالة
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// Scroll لآخر رسالة
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Format الوقت
  String _formatTimestamp(Timestamp ts) {
    final DateTime dt = ts.toDate();
    final DateTime now = DateTime.now();

    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat.Hm().format(dt); // Hour:Minute
    } else if (dt.isAfter(now.subtract(const Duration(days: 7)))) {
      return DateFormat.E().format(dt); // Day of week
    } else {
      return DateFormat.yMd().format(dt); // Date
    }
  }

  @override
  Widget build(BuildContext context) {
    // for(int i =0; i <= 2;i++)
    // FirebaseFirestore.instance.collection('messages').add({
    //   'name': "Meg",
    //   'phone': "01149504892",
    //   'country': "DK",
    //   'message': "Hello bro",
    //   'timestamp': FieldValue.serverTimestamp(),
    //   'datetime': DateTime.now(),
    // });

    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final newMessages = snapshot.data!.docs;

                // أضف فقط الرسائل الجديدة بدون تكرار
                for (var doc in newMessages) {
                  if (!_messages.any((d) => d.id == doc.id)) {
                    _messages.add(doc);
                  }
                }

                // Scroll تلقائي إذا المستخدم قريب من الأسفل
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final distanceFromBottom =
                      _scrollController.position.maxScrollExtent -
                          _scrollController.offset;
                  if (_firstLoad || distanceFromBottom < 100) {
                    _scrollToBottom();
                  }
                  _firstLoad = false;
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final prevMsg = index > 0 ? _messages[index - 1] : null;
                    final showName =
                        prevMsg == null || prevMsg['name'] != msg['name'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showName)
                            Text(
                              msg['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: msg['name'] == userName
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(msg['message']),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTimestamp(
                                    msg['timestamp'] ?? Timestamp.now(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
