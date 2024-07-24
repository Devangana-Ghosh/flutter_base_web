import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../../pages/home.dart';
import '../firebase_auth/auth_manager.dart';

class AuthService {
  final AuthManager _authManager = AuthManager();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<void> authenticate(BuildContext context) async {
    bool isAuthenticated = false;

    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to access the app',
      );
    } catch (e) {
      print('Error during biometric authentication: $e');
    }

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      print('Biometric authentication failed');
    }
  }

  Future<void> userLogin(BuildContext context, GlobalKey<FormState> formKey, String email, String password) async {
    if (formKey.currentState!.validate()) {
      try {
        await _authManager.signInWithEmailAndPassword(email, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = "No User Found for that Email";
        } else if (e.code == 'wrong-password') {
          message = "Wrong Password Provided by User";
        } else {
          message = "An error occurred. Please try again.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(message, style: TextStyle(fontSize: 18.0)),
        ));
      }
    }
  }

  Future<void> registration(BuildContext context, GlobalKey<FormState> formKey, TextEditingController mailController, TextEditingController passwordController, TextEditingController nameController, TextEditingController phoneController) async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _authManager.createUserWithEmailAndPassword(
          mailController.text,
          passwordController.text,
          nameController.text,
          phoneController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registered Successfully", style: TextStyle(fontSize: 20.0)),
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = e.message ?? 'Error during registration';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(errorMessage, style: TextStyle(fontSize: 18.0)),
        ));
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to create user: $e', style: TextStyle(fontSize: 18.0)),
        ));
      }
    }
  }
}
