import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_auth_user_provider.dart';

class AuthManager implements BaseAuthUserProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String name, String phoneNumber, {int? age, String? gender}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user!.updateDisplayName(name);

      // Store user details in Firestore
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'age': age,
        'gender': gender,
      };

      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e; // rethrow any other exceptions
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e; // rethrow any other exceptions
    }
  }

  @override
  Future<void> updateUserDetails(User user, {String? name, String? email, String? phoneNumber, int? age, String? gender}) async {
    try {
      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (email != null) {
        await user.updateEmail(email);
      }

      // Update user details in Firestore
      Map<String, dynamic> userData = {
        'name': name ?? '',
        'email': email ?? '',
        'phoneNumber': phoneNumber ?? '',
        'age': age,
        'gender': gender,
      };

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
    } catch (e) {
      throw e; // Or handle the error as needed
    }
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e; // rethrow any other exceptions
    }
  }

  @override
  Future<void> verifyPhoneNumber(String phoneNumber, void Function(String verificationId) codeSent, void Function(FirebaseAuthException error) verificationFailed) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: verificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e; // rethrow any other exceptions
    }
  }

  @override
  Future<UserCredential> signInWithPhoneNumber(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e; // rethrow any other exceptions
    }
  }
}
