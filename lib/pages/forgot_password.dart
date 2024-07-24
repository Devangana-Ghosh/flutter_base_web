import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample/pages/signup.dart';
import '../auth/firebase_auth/auth_manager.dart';
import '../components/textfield.dart';
import '../constants/styles.dart';
import '../constants/string.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController mailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthManager _authManager = AuthManager();

  resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authManager.sendPasswordResetEmail(mailController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.passwordResetEmailSent, style: AppStyles.snackBarText),
        ));
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.userNotFound, style: AppStyles.snackBarText),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 70.0),
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                AppStrings.passwordRecovery,
                style: AppStyles.headingWhite,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              AppStrings.enterEmail,
              style: AppStyles.subheadingWhite,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ListView(
                    children: [
                      CustomTextField(
                        controller: mailController,
                        hintText: AppStrings.emailHint,
                        prefixIcon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.emailRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40.0),
                      GestureDetector(
                        onTap: resetPassword,
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              AppStrings.sendEmail,
                              style: AppStyles.buttonText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: AppStyles.dontHaveAccountText,
                          ),
                          const SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                            },
                            child: Text(
                              AppStrings.create,
                              style: AppStyles.createText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
