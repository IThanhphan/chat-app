import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMTokenRepository {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static Future<void> saveToken(String token, String userId) async {
    final docRef = _firebaseFirestore.collection('Users').doc(userId);
    await docRef.set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> refreshAndSaveToken() async {
    try {
      final oldToken = await _messaging.getToken();
      if (oldToken != null) {
        await _messaging.deleteToken(); // xoá token cũ
      }
      final newToken = await _messaging.getToken();
      final userId = _firebaseAuth.currentUser?.uid;
      if (newToken != null && userId != null) {
        await FCMTokenRepository.saveToken(newToken, userId);
      }
    } catch (e) {
      print('Lỗi khi tạo lại FCM token: $e');
    }
  }

  static Future<void> removeFcmToken() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) {
      await _firebaseFirestore.collection('Users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
    }
  }

  static Future<void> deleteDeviceToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      print('Lỗi khi xóa token FCM: $e');
    }
  }
}
