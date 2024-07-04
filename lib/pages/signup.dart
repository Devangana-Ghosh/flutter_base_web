import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/firebase_auth/auth_manager.dart';
import '../components/textfield.dart';
import '../services/firebase_analytics.dart';
import 'home.dart';
import 'login.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthManager _authManager = AuthManager();

  void registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _authManager.createUserWithEmailAndPassword(
          mailController.text,
          passwordController.text,
          nameController.text,
          phoneController.text,
        );

        // Log the sign-up event
        await AnalyticsHandler.logEvent('sign_up', parameters: {
          'email': mailController.text,
          'name': nameController.text,
          'phone': phoneController.text,
        });

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

  @override
  Widget build(BuildContext context) {
    AnalyticsHandler.logScreenView('SignUp');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Let's create an account!",
                style: TextStyle(color: Color(0xFF273671), fontSize: 40.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      hintText: "Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    CustomTextField(
                      controller: mailController,
                      hintText: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    CustomTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () {
                        registration();
                        AnalyticsHandler.logButtonClick('SignUpButton');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF273671),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Color(0xFF8c8e98), fontSize: 18.0, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                      AnalyticsHandler.logButtonClick('LogInLink');
                    },
                    child: Text(
                      "LogIn",
                      style: TextStyle(color: Color(0xFF273671), fontSize: 20.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
