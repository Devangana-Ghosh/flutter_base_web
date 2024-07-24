import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/firebase_auth/auth_manager.dart';
import '../components/textfield.dart';
import '../constants/string.dart';
import '../constants/errors.dart';

import 'home.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthManager _authManager = AuthManager();
  bool otpSent = false;// Flag to check if OTP has been sent
  bool emailVerified = false;
  String verificationId = ''; // Stores the verification ID for phone authentication

  Future<void> createUserAndSendEmailVerification() async {
    try {
      UserCredential userCredential = await _authManager.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        nameController.text,
        phoneController.text,
      );

      User user = userCredential.user!;
      await _authManager.sendEmailVerification(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${AppStrings.emailVerificationSent} ${user.email}'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${AppErrors.emailVerificationFailed} $e'),
      ));
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      emailVerified = await _authManager.isEmailVerified(user);
      if (emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.emailVerified),
        ));
        verifyPhone();// Proceed to verify phone number if email is verified
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.emailNotVerified),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${AppErrors.emailVerificationCheckFailed} $e'),
      ));
    }
  }

  void verifyPhone() async {
    if (_formKey.currentState!.validate()) {
      await _authManager.verifyPhoneNumber(
        phoneController.text,
            (verId) {
          setState(() {
            otpSent = true;// Set OTP sent flag to true
            verificationId = verId;// Save Verification ID
          });
        },
            (error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(error.message ?? AppErrors.phoneVerificationFailed, style: const TextStyle(fontSize: 18.0)),
          ));
        },
      );
    }
  }

  void verifyOtp() async {
    if (otpController.text.isNotEmpty) {
      try {
        await _authManager.signInWithPhoneNumber(verificationId, otpController.text);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));//Navigate to home page if verified
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(e.message ?? AppErrors.phoneVerificationFailed, style: const TextStyle(fontSize: 18.0)),
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
              const Text(
                AppStrings.signUpTitle,
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: emailController,
                      hintText: AppStrings.emailHint,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppErrors.pleaseEnterEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    CustomTextField(
                      controller: passwordController,
                      hintText: AppStrings.passwordHint,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppErrors.pleaseEnterPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    CustomTextField(
                      controller: nameController,
                      hintText: AppStrings.nameHint,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppErrors.pleaseEnterName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    CustomTextField(
                      controller: phoneController,
                      hintText: AppStrings.phoneHint,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppErrors.pleaseEnterPhoneNumber;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    if (!otpSent) ...[
                      GestureDetector(
                        onTap: () async {
                          await createUserAndSendEmailVerification();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(AppStrings.emailVerification),
                                content: Text(AppStrings.emailVerificationDialogContent),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(AppStrings.okButton),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273671),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              AppStrings.signUpButton,
                              style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: checkEmailVerification,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF273671),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              AppStrings.checkEmailVerification,
                              style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
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
                            return AppErrors.pleaseEnterOtp;
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
                          child: const Center(
                            child: Text(
                              AppStrings.verifyOtp,
                              style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
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
