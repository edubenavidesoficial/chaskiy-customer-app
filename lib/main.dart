import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/my_app.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/services/deep_link.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';
import 'package:chaskiy/services/phone_util.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_languages.dart';

class DevHttpOverrides extends HttpOverrides {
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
      if (kDebugMode) {
        HttpOverrides.global = DevHttpOverrides();
      }

      // Solo bloquean el primer fotograma los servicios imprescindibles.
      await Future.wait([
        Firebase.initializeApp(),
        translator.init(
          localeType: LocalizationDefaultType.asDefined,
          language: "es",
          languagesList: AppLanguages.codes,
          assetsDirectory: 'assets/lang/',
        ),
        LocalStorageService.getPrefs(),
      ]);
      await CartServices.getCartItems();

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      runApp(LocalizedApp(child: MyApp()));

      // Estos servicios no deben retrasar la primera pantalla.
      unawaited(PhoneUtilService.init());
      DeepLinkService().initialize();
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
