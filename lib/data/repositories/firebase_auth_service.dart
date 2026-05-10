import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  // SEND OTP
  Future<bool> sendOTP(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("OTP Failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // VERIFY OTP
  Future<User?> verifyOTP(String smsCode) async {
    try {
      if (_verificationId == null) return null;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      return result.user;
    } catch (e) {
      return null;
    }
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
