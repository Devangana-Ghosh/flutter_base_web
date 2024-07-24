import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../auth/biometric_auth/auth_service.dart';
import '../components/textfield.dart';
import '../services/firebase_analytics.dart';
import 'forgot_password.dart';
import 'login_phn.dart';
import 'signup.dart';
import '../constants/styles.dart';
import '../constants/string.dart';
import '../constants/errors.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    AnalyticsHandler.logScreenView('LogIn');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.letsGetYouIn,
                style: AppStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 70.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: mailController,
                      hintText: AppStrings.emailHint,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppErrors.emailEmpty;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    CustomTextField(
                      controller: passwordController,
                      hintText: AppStrings.passwordHint,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppErrors.passwordEmpty;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () {
                        _authService.userLogin(
                          context,
                          _formKey,
                          mailController.text,
                          passwordController.text,
                        );
                        AnalyticsHandler.logButtonClick('SignInButton');//log when signIn button is clicked
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 13.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF273671),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.signInButton,
                            style: AppStyles.buttonText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPassword()),
                        );
                        AnalyticsHandler.logButtonClick('ForgotPasswordLink');
                      },
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppStyles.linkText,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LogInWithPhone()),
                        );
                        AnalyticsHandler.logButtonClick('LogInWithPhoneLink');
                      },
                      child: Text(
                        AppStrings.logInWithPhone,
                        style: AppStyles.phoneLinkText,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: AppStyles.dontHaveAccountText,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUp()),
                            );
                            AnalyticsHandler.logButtonClick('SignUpLink');
                          },
                          child: Text(
                            AppStrings.signUp,
                            style: AppStyles.signUpText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
              ElevatedButton.icon(
                onPressed: () async {
                  await _authService.authenticate(context);
                  AnalyticsHandler.logButtonClick('FingerprintAuthentication');
                },
                icon: const Icon(Icons.fingerprint),
                label: Text(AppStrings.fingerprintAuth),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF273671), backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
