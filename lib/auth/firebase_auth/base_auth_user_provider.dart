import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthUserProvider {
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String name, String phoneNumber);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserDetails(User user, {String? name, String? phoneNumber});
}
