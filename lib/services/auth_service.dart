import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==============================
  // สมัครสมาชิก
  // ==============================
  Future<User?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // สร้างบัญชีด้วย Email และ Password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // UID ของผู้ใช้ที่ Firebase สร้างให้
      String uid = userCredential.user!.uid;

      // บันทึกข้อมูลผู้ใช้ลง Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }

  // ==============================
  // เข้าสู่ระบบ
  // ==============================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }

  // ==============================
  // ออกจากระบบ
  // ==============================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==============================
  // ผู้ใช้ที่กำลัง Login อยู่
  // ==============================
  User? get currentUser => _auth.currentUser;

  // ==============================
  // ดึงข้อมูล Profile จาก Firestore
  // ==============================
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _firestore.collection('users').doc(user.uid).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  // ==============================
  // แก้ไขข้อมูล Profile
  // ==============================
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('กรุณาเข้าสู่ระบบก่อน');
    }

    final Map<String, dynamic> data = {
      'name': name.trim(),
      'phone': phone.trim(),
    };

    // ถ้ามีการส่งรูปเข้ามา ให้บันทึกด้วย
    if (profileImage != null) {
      data['profileImage'] = profileImage;
    }

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  // ==============================
  // แปลง Firebase Error เป็นภาษาไทย
  // ==============================
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว';

      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';

      case 'weak-password':
        return 'รหัสผ่านไม่ปลอดภัย ควรมีอย่างน้อย 6 ตัวอักษร';

      case 'user-not-found':
        return 'ไม่พบบัญชีผู้ใช้นี้';

      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';

      case 'invalid-credential':
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน';

      case 'too-many-requests':
        return 'มีการลองเข้าสู่ระบบหลายครั้ง กรุณารอสักครู่';

      default:
        return 'เกิดข้อผิดพลาด: $code';
    }
  }
}