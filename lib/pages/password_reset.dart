import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/errors.dart';
import '../constants/styles.dart';
import '../constants/string.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resetPassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.currentPassword, style: AppStyles.fieldLabel),
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: AppStrings.enterCurrentPassword,
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.newPassword, style: AppStyles.fieldLabel),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: AppStrings.enterNewPassword,
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.confirmPassword, style: AppStyles.fieldLabel),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: AppStrings.enterConfirmPassword,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _resetPassword();
              },
              child: const Text(AppStrings.resetPasswordButton),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (newPasswordController.text == confirmPasswordController.text) {
        // Re-authenticate user with current password
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.passwordReset),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppErrors.passwordMismatch),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppErrors.passwordResetFailure),
        ),
      );
    }
  }
}
