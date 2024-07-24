import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_analytics.dart';
import 'password_reset.dart';
import '../constants/styles.dart';
import '../constants/string.dart';
import '../constants/errors.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedGender;
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadProfile();
  }

  Future<void> _loadProfile() async {//load user profile from firestore
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(_user?.uid).get();
      if (snapshot.exists) {
        setState(() {
          nameController.text = _user?.displayName ?? '';
          emailController.text = _user?.email ?? '';
          phoneController.text = snapshot.data()?['phoneNumber'] ?? '';
          ageController.text = snapshot.data()?['age']?.toString() ?? '';
          selectedGender = snapshot.data()?['gender'];
        });

        await AnalyticsHandler.logEvent('profile_loaded', parameters: {
          'user_id': _user?.uid ?? '',
          'email': _user?.email ?? '',
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppErrors.profileLoadFailed),
      ));
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _user?.updateDisplayName(nameController.text);
      await _user?.verifyBeforeUpdateEmail(emailController.text);
      await _firestore.collection('users').doc(_user?.uid).update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'gender': selectedGender,
      });

      await AnalyticsHandler.logEvent('profile_updated', parameters: {
        'user_id': _user?.uid ?? '',
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'age': ageController.text,
        'gender': selectedGender ?? '',
      });

      await AnalyticsHandler.logButtonClick('UpdateProfile');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.profileUpdateSucesfull),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppErrors.profileUpdateFailed),
      ));
    }
  }

  void _navigateToPasswordResetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordResetPage()),
    );
    AnalyticsHandler.logButtonClick('ResetPassword');//log when reset password button is clicked
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHandler.logScreenView('ProfileSettings');//log when Profile Settings button is clicked

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(AppStrings.profileSettings,
                style: AppStyles.appBarTitle)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.name,
                style: AppStyles.fieldLabel,
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: AppStrings.enterName,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.email,
                style: AppStyles.fieldLabel,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: AppStrings.enterEmail,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.phoneNumber,
                style: AppStyles.fieldLabel,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: AppStrings.enterPhoneNumber,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.age,
                style: AppStyles.fieldLabel,
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppStrings.enterAge,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.gender,
                style: AppStyles.fieldLabel,
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                decoration: InputDecoration(
                  hintText: AppStrings.selectGender,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _navigateToPasswordResetPage,
                child: Text(AppStrings.resetPassword),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text(AppStrings.updateProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
