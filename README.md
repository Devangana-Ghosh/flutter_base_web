# Base Project for every Flutter App using Firebase

This Flutter application provides a user profile management feature along with email, phone number and bio-metric authentication. It allows users to view and update their profile information and integrates Firebase Authentication for user sign-up, email verification, and phone number verification.

## Features

- User Profile Management: Users can view and update their profile information.
- Firebase Authentication: Includes email and phone number-based authentication.
- Email Verification: Sends verification emails to users during sign-up.
- Phone Number Verification: Verifies phone numbers using OTP.
- Bio-Metric Authentication: Users can LogIn using pre-registered biometrics
- Password Reset: Allows users to reset their passwords.
- 

## Getting Started

### Prerequisites

Ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- An IDE such as [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### Setup

1. Clone the Repository

    ```bash
    git clone https://github.com/Devangana-Ghosh/base_flutter_project.git
   ```

2. Install Dependencies

    Run the following command to install all required dependencies:

    ```bash
    flutter pub get
    ```

3. Configure Firebase

    - Follow the [Firebase setup guide](https://firebase.google.com/docs/flutter/setup) to configure your Firebase project.
    - Download the `google-services.json` file for Android or `GoogleService-Info.plist` for iOS and place it in the appropriate directory (`android/app` or `ios/Runner`).

 
4. Run the App

    ```bash
    flutter run
    ```

 

 

 
