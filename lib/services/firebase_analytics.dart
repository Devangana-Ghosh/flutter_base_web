import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHandler {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;


  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
  static Future<void> logButtonClick(String buttonName) async {
    print('Logging button click: $buttonName'); // Debug log
    await logEvent('button_click', parameters: {'button_name': buttonName});
  }
}
