import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/my_app.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/services/deep_link.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';
import 'package:chaskiy/services/phone_util.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_languages.dart';

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      //setting up firebase notifications
      await Firebase.initializeApp();
      await PhoneUtilService.init();

      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      //
      await LocalStorageService.getPrefs();
      await CartServices.getCartItems();

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      //setting up crashlytics only for production
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Initialize deep link handling
      DeepLinkService().initialize();

      // Run app!
      runApp(LocalizedApp(child: MyApp()));
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
