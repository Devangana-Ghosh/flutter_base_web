import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthUserProvider {
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
}
