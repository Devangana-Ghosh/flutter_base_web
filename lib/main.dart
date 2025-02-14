import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:sample/constants.dart';
import 'package:sample/pages/splashscreen.dart';
import 'package:sample/services/notif_handler.dart';

import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file (Web requires specifying the correct path)
  await dotenv.load(fileName: "assets/.env");

  String apiKey = dotenv.env['API_KEY'] ?? "";

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: Constants.appId,
      messagingSenderId: Constants.messagingSenderId,
      projectId: Constants.projectId,
    ),
  );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NotificationHandler notificationHandler = NotificationHandler(navigatorKey: navigatorKey);
  notificationHandler.initialize();

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[observer],
      home: SplashScreen(),
    );
  }
}
