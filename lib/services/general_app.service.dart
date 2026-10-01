import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chaskiy/services/firebase.service.dart' as app_firebase;

class GeneralAppService {
  //

  //Hnadle background message
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Persist both notification-only and data messages. Notification-only
    // messages are displayed by the operating system, while data messages
    // are rendered by the app's local notification channel.
    app_firebase.FirebaseService().saveNewNotification(message);
    if (message.notification == null) {
      app_firebase.FirebaseService().showNotification(message);
    }
  }
}
