import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_auth_user_provider.dart';

class AuthManager implements BaseAuthUserProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phoneNumber, {
        int? age,
        String? gender,
      }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);

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
      throw e;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e;
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

      Map<String, dynamic> userData = {
        'name': name ?? '',
        'email': email ?? '',
        'phoneNumber': phoneNumber ?? '',
        'age': age,
        'gender': gender,
      };

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
    } catch (e) {
      throw e;
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
      throw e;
    }
  }

  @override
  Future<void> verifyPhoneNumber(
      String phoneNumber,
      void Function(String verificationId) codeSent,
      void Function(FirebaseAuthException error) verificationFailed) async {
    try {
      // Check if the phone number exists in the database
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      final List<DocumentSnapshot> documents = result.docs;

      if (documents.isEmpty) {
        // Phone number doesn't exist in the database
        throw FirebaseAuthException(
          code: 'phone-not-registered',
          message: 'Phone number is not registered. Please sign up first.',
        );
      }

      // If phone number exists, proceed with verification
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
      throw e;
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
      throw e;
    }
  }

  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> isEmailVerified(User user) async {
    try {
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      throw e;
    }
  }
}
