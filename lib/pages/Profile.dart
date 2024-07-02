import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'password_reset.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

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
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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

        await analytics.logEvent(
          name: 'profile_loaded',
          parameters: {
            'user_id': _user?.uid ?? '',
            'email': _user?.email ?? '',
          },
        );
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {

      await _user?.updateDisplayName(nameController.text);
      await _user?.updateEmail(emailController.text);
      await _firestore.collection('users').doc(_user?.uid).update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'gender': selectedGender,
      });

      await analytics.logEvent(
        name: 'profile_updated',
        parameters: {
          'user_id': _user?.uid ?? '',
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'age': ageController.text,
          'gender': selectedGender ?? '',
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
        ),
      );
    }
  }

  void _navigateToPasswordResetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordResetPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Age',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  hintText: 'Select your gender',
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _navigateToPasswordResetPage,
                child: Text('Reset Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
