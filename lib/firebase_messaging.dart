import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

class FirebaseInAppMessagingService {
  static final FirebaseInAppMessaging _fiamInstance = FirebaseInAppMessaging.instance;

  // Initialize Firebase In-App Messaging
  static Future<void> initialize() async {
    print("Initializing Firebase In-App Messaging...");

    // Enable automatic data collection
    await _fiamInstance.setAutomaticDataCollectionEnabled(true);
    print("Firebase In-App Messaging data collection enabled.");
  }

  
}
