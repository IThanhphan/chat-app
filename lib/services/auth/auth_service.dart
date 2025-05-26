import 'package:chat_app/helper/utils/load_asset_image_as_base64.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
    return doc.data();
  }

  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    required String dob,
    required bool gender, // true: Nam, false: Nữ
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String base64Image = '';
    if (gender) {
      base64Image = await loadAssetImageAsBase64('assets/male_avatar.jpg');
    } else {
      base64Image = await loadAssetImageAsBase64('assets/female_avatar.jpg');
    }

    // Lưu thông tin bổ sung vào Firestore
    await _firestore.collection('Users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'username': username,
      'avatar': base64Image,
      'dob': dob,
      'gender': gender,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> updateAvatar(String base64Avatar) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update(
        {'avatar': base64Avatar},
      );
    }
  }
}
