import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screw_calculator/models/screenshoot_model.dart';

abstract class ScreenshotDataSource {
  Stream<List<ScreenShootModel>> getScreenshots({required int limit});

  Future<List<ScreenShootModel>> loadMoreScreenshots({
    required String lastDocumentId,
    required int limit,
  });

  Future<bool> deleteScreenshot(String screenshotId);
}

class ScreenshotDataSourceImpl implements ScreenshotDataSource {
  final FirebaseFirestore _firestore;

  ScreenshotDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ScreenShootModel>> getScreenshots({required int limit}) {
    return _firestore
        .collection('user_screenshoot_sharing')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScreenShootModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<ScreenShootModel>> loadMoreScreenshots({
    required String lastDocumentId,
    required int limit,
  }) async {
    final lastDoc = await _firestore
        .collection('user_screenshoot_sharing')
        .doc(lastDocumentId)
        .get();

    if (!lastDoc.exists) {
      return [];
    }

    final snapshot = await _firestore
        .collection('user_screenshoot_sharing')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return ScreenShootModel.fromJson(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<bool> deleteScreenshot(String screenshotId) async {
    try {
      await _firestore
          .collection('user_screenshoot_sharing')
          .doc(screenshotId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

