import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chaskiy/services/firebase.service.dart' as app_firebase;

class GeneralAppService {
  //

//Hnadle background message
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    //if it has not data then it is a normal notification, so ignore it
    if (message.data.isEmpty) return;
    await Firebase.initializeApp();
    app_firebase.FirebaseService().saveNewNotification(message);
    //normal notifications
    app_firebase.FirebaseService().showNotification(message);
  }
}
