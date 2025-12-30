import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Box userBox = Hive.box('userBox');

  String? userName;
  String? userPhone;
  String? userCountry;

  final int _chunkSize = 20;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<DocumentSnapshot> _messages = [];
  bool _firstLoad = true;

  DateTime _currentCollectionDate = DateTime.now();

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

  String _getCollectionName(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  /// Fetch initial messages (today)
  void _fetchInitialMessages() async {
    final today = DateTime.now();
    _currentCollectionDate = today;
    final collectionName = _getCollectionName(today);

    Query query = FirebaseFirestore.instance
        .collection('messages')
        .doc(collectionName)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(_chunkSize);

    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _messages = snapshot.docs.reversed.toList();
      _lastDocument = snapshot.docs.last;
    } else {
      _hasMore = false;
    }

    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// Fetch older messages (pagination + previous days)
  void _fetchMoreMessages() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    final scrollOffsetBefore = _scrollController.offset;
    DateTime? dateToFetch = _currentCollectionDate;

    while (dateToFetch != null) {
      final collectionName = _getCollectionName(dateToFetch);

      Query query = FirebaseFirestore.instance
          .collection('messages')
          .doc(collectionName)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument ??= DocumentSnapshotFake())
          .limit(_chunkSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        setState(() {
          _messages.insertAll(0, snapshot.docs.reversed.toList());
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          double addedHeight = snapshot.docs.length * 60.0;
          _scrollController.jumpTo(scrollOffsetBefore + addedHeight);
        });

        _isLoadingMore = false;
        return;
      } else {
        dateToFetch = dateToFetch.subtract(Duration(days: 1));
        _lastDocument = null;
        _currentCollectionDate = dateToFetch;
      }
    }

    _hasMore = false;
    _isLoadingMore = false;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      _fetchMoreMessages();
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final now = DateTime.now();
    final collectionName = _getCollectionName(now);

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(collectionName)
        .collection('chats')
        .add({
          'name': userName,
          'phone': userPhone,
          'country': userCountry,
          'message': _controller.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'seenBy': [],
        });

    _controller.clear();
    _setTyping(false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTimestamp(Timestamp ts) {
    DateTime dt = ts.toDate();
    DateTime now = DateTime.now();

    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat.Hm().format(dt);
    } else if (dt.isAfter(now.subtract(Duration(days: 7)))) {
      return DateFormat.E().format(dt);
    } else {
      return DateFormat.yMd().format(dt);
    }
  }

  void _setTyping(bool typing) {
    if (userName == null) return;
    FirebaseFirestore.instance.collection('typing').doc(userName).set({
      'isTyping': typing,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _markAsSeen(DocumentSnapshot msg) {
    if (!_messages.contains(msg)) return;
    if ((msg['seenBy'] as List).contains(userName)) return;

    FirebaseFirestore.instance
        .collection('messages')
        .doc(_getCollectionName(msg['timestamp'].toDate()))
        .collection('chats')
        .doc(msg.id)
        .update({
          'seenBy': FieldValue.arrayUnion([userName]),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Chat')),
      body: Column(
        children: [
          // Typing indicator
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('typing').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              final typingUsers = snapshot.data!.docs
                  .where((d) => d['isTyping'] == true && d.id != userName)
                  .map((d) => d.id)
                  .toList();
              if (typingUsers.isEmpty) return SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '${typingUsers.join(', ')} typing...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(_getCollectionName(_currentCollectionDate))
                  .collection('chats')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final newMessages = snapshot.data!.docs;
                for (var doc in newMessages) {
                  if (!_messages.any((d) => d.id == doc.id)) _messages.add(doc);
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final distanceFromBottom =
                      _scrollController.position.maxScrollExtent -
                      _scrollController.offset;
                  if (_firstLoad || distanceFromBottom < 100) _scrollToBottom();
                  _firstLoad = false;
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    _markAsSeen(msg);

                    final prevMsg = index > 0 ? _messages[index - 1] : null;
                    final showName =
                        prevMsg == null || prevMsg['name'] != msg['name'];

                    final seenCount = (msg['seenBy'] as List).length;

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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            padding: EdgeInsets.symmetric(
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
                                SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTimestamp(
                                        msg['timestamp'] ?? Timestamp.now(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    if (seenCount > 0 &&
                                        msg['name'] == userName)
                                      Text(
                                        'Seen by $seenCount',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                  ],
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
          // Input field
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) => _setTyping(text.isNotEmpty),
                    decoration: InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fake DocumentSnapshot لتجنب null في startAfterDocument عند اليوم السابق
class DocumentSnapshotFake extends DocumentSnapshot {
  @override
  dynamic get(Object? field) => null;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
