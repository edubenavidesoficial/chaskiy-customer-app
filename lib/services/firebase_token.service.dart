import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:singleton/singleton.dart';

import 'local_storage.service.dart';

class FirebaseTokenService {
  //
  /// Factory method that reuse same instance automatically
  factory FirebaseTokenService() =>
      Singleton.lazy(() => FirebaseTokenService._());

  /// Private constructor
  FirebaseTokenService._() {}

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static String DEVICE_TOKEN_STORE_KEY = "device_token";
  Future<void> handleDeviceTokenSync({bool force = false}) async {
    //get device token
    String? deviceToken = await firebaseMessaging.getToken();
    if (deviceToken != null) {
      await syncDeviceTokenWithServer(deviceToken, force: force);
    }
    firebaseMessaging.onTokenRefresh.listen((event) async {
      await syncDeviceTokenWithServer(event, force: true);
    });
  }

  Future<void> syncDeviceTokenWithServer(
    String? deviceToken, {
    bool force = false,
  }) async {
    try {
      if (deviceToken == null || deviceToken.isEmpty) return;
      // A token obtained before login cannot be associated with a user on the
      // API. Do not mark it as synced until there is an authenticated session.
      if (!AuthServices.authenticated()) return;
      final storagePref = await LocalStorageService.getPrefs();
      //check if saved token is same as current token
      String? savedToken = storagePref.getString(DEVICE_TOKEN_STORE_KEY);
      //if token is not saved or is different from current token
      if (!force && savedToken == deviceToken) {
        return;
      }
      final response = await AuthRequest().updateDeviceToken(deviceToken);
      if (!response.allGood) return;
      // Store the token only after the API accepted it. This lets the next
      // authenticated login retry if the previous sync failed.
      await storagePref.setString(DEVICE_TOKEN_STORE_KEY, deviceToken);
    } catch (error) {
      log("Error syncing device token with server: $error");
    }
  }

  Future<String?> getDeviceToken() async {
    String? deviceToken;
    try {
      final storagePref = await LocalStorageService.getPrefs();
      deviceToken = storagePref.getString(DEVICE_TOKEN_STORE_KEY);
      //
      if (deviceToken == null) {
        await handleDeviceTokenSync();
      }
      //last try
      deviceToken = storagePref.getString(DEVICE_TOKEN_STORE_KEY);
    } catch (error) {
      log("Error getting device token: $error");
    }
    return deviceToken;
  }
}
