import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/firebase_auth/auth_manager.dart';
import '../components/textfield.dart';
import '../constants/string.dart';
import 'home.dart';
import '../constants/errors.dart';


class LogInWithPhone extends StatefulWidget {
  const LogInWithPhone({Key? key}) : super(key: key);

  @override
  State<LogInWithPhone> createState() => _LogInWithPhoneState();
}

class _LogInWithPhoneState extends State<LogInWithPhone> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthManager _authManager = AuthManager();
  bool otpSent = false;
  String verificationId = '';

  void verifyPhone() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authManager.verifyPhoneNumber(
          phoneController.text,
              (verId) {
            setState(() {
              otpSent = true;
              verificationId = verId;
            });
          },
              (error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(error.message ?? AppErrors.verificationFailed, style: const TextStyle(fontSize: 18.0)),
            ));
          },
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'phone-not-registered') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(AppErrors.phoneNotRegistered, style: const TextStyle(fontSize: 18.0)),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(e.message ?? AppErrors.verificationFailed, style: const TextStyle(fontSize: 18.0)),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: const Text('An unexpected error occurred', style: TextStyle(fontSize: 18.0)),
        ));
      }
    }
  }

  void verifyOtp() async {
    if (otpController.text.isNotEmpty) {//verify input field is not empty
      try {
        await _authManager.signInWithPhoneNumber(verificationId, otpController.text);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(e.message ?? AppErrors.verificationFailed, style: const TextStyle(fontSize: 18.0)),//display error message
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                otpSent ? AppStrings.enterOtp : AppStrings.enterPhoneNumber,
                style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!otpSent) ...[
                      CustomTextField(
                        controller: phoneController,
                        hintText: AppStrings.phoneNumberHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppErrors.phoneNumberEmpty;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: verifyPhone,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273671),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.sendOtpButton,
                              style: const TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      CustomTextField(
                        controller: otpController,
                        hintText: AppStrings.otpHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppErrors.otpEmpty;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: verifyOtp,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273671),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.verifyOtpButton,
                              style: const TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
