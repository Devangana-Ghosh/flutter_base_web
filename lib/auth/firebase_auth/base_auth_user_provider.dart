import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthUserProvider {
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String name, String phoneNumber, {int? age, String? gender});
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserDetails(User user, {String? name, String? email, String? phoneNumber, int? age, String? gender});
  Future<void> verifyPhoneNumber(String phoneNumber, void Function(String verificationId) codeSent, void Function(FirebaseAuthException error) verificationFailed);
  Future<UserCredential> signInWithPhoneNumber(String verificationId, String smsCode);
  Future<void> sendEmailVerification(User user);
  Future<bool> isEmailVerified(User user);
}
