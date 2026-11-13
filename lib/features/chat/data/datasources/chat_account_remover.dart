import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

/// «احذف حسابي» في الشات: يمسح كل بيانات المستخدم من Firestore ومن الموبايل.
///
/// بيمسح: حساب الشات (`chats/users/users/{phone}`)، كل رسايله (نص وصور)،
/// حالة الاتصال، ومؤشر الكتابة. وبعدها بيمسح بياناته المحفوظة محليًا عشان
/// التسجيل يتطلب تاني لو رجع.
class ChatAccountRemover {
  ChatAccountRemover({required this.firestore, required this.userBox});

  final FirebaseFirestore firestore;
  final Box<dynamic> userBox;

  /// حد Firestore لكل batch هو 500 عملية.
  static const int _batchSize = 400;

  Future<void> deleteAccount({required String phone, String? name}) async {
    final chats = firestore.collection('chats');

    final messages = chats.doc('messages').collection('messages');
    while (true) {
      final page = await messages
          .where('phone', isEqualTo: phone)
          .limit(_batchSize)
          .get();
      if (page.docs.isEmpty) break;
      final batch = firestore.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (page.docs.length < _batchSize) break;
    }

    final users = chats.doc('users').collection('users');
    final byPhone = await users.where('userPhone', isEqualTo: phone).get();
    final batch = firestore.batch()..delete(users.doc(phone));
    for (final doc in byPhone.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(
      chats.doc('users_presence').collection('users_presence').doc(phone),
    );
    if (name != null && name.isNotEmpty) {
      batch.delete(chats.doc('typing').collection('typing').doc(name));
    }
    await batch.commit();

    await userBox.deleteAll(const [
      'name',
      'phone',
      'country',
      'age',
      'chatDraft',
    ]);
    if (Hive.isBoxOpen('cachedMessages')) {
      await Hive.box<dynamic>('cachedMessages').clear();
    }
  }
}
