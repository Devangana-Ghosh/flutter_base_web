import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure this import is still needed in your project
import 'package:local_auth/local_auth.dart'; // Import for biometric authentication
import '../auth/firebase_auth/auth_manager.dart'; // Adjust paths as per your project structure
import '../components/textfield.dart'; // Adjust paths as per your project structure
import 'forgot_password.dart'; // Adjust paths as per your project structure
import 'home.dart'; // Adjust paths as per your project structure
import 'login_phn.dart'; // Adjust paths as per your project structure
import 'signup.dart'; // Adjust paths as per your project structure

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthManager _authManager = AuthManager();
  final LocalAuthentication _localAuthentication = LocalAuthentication(); // Initialize local authentication

  // Method to handle user login with email and password
  void userLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authManager.signInWithEmailAndPassword(
          mailController.text,
          passwordController.text,
        );
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

  // Method to handle biometric authentication
  Future<void> authenticate() async {
    bool isAuthenticated = false;

    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to access the app', // Reason shown to the user for authentication
        // Set other parameters here as needed (e.g., biometricOnly, useErrorDialogs, stickyAuth)
      );
    } catch (e) {
      print('Error during biometric authentication: $e');
    }

    if (isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      print('Biometric authentication failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Let's get you in!",
                style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 70.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: mailController,
                      hintText: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Email';
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
                          return 'Please Enter Password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          userLogin();
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 13.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF273671),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPassword()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF8c8e98),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInWithPhone()),
                        );
                      },
                      child: Text(
                        "LogIn with Phone",
                        style: TextStyle(
                          color: Color(0xFF273671),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF8c8e98),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: Text(
                            "SignUp",
                            style: TextStyle(
                              color: Color(0xFF273671),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              SizedBox(height: 40.0), // Spacing between existing UI and biometric button
              ElevatedButton.icon(
                onPressed: () async {
                  await authenticate(); // Call biometric authentication method
                },
                icon: Icon(Icons.fingerprint), // Use fingerprint icon
                label: Text('Authenticate with Fingerprint'), // Button label
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF273671), backgroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
