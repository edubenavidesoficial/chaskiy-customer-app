import 'dart:async';
import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
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

      // Textos en español para todos los pull-to-refresh (easy_refresh)
      EasyRefresh.defaultHeaderBuilder = () => const ClassicHeader(
            dragText: 'Desliza para actualizar',
            armedText: 'Suelta para actualizar',
            readyText: 'Actualizando...',
            processingText: 'Actualizando...',
            processedText: 'Actualizado',
            noMoreText: 'No hay más resultados',
            failedText: 'No se pudo actualizar',
            messageText: 'Actualizado a las %T',
          );
      EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
            dragText: 'Desliza para cargar más',
            armedText: 'Suelta para cargar más',
            readyText: 'Cargando...',
            processingText: 'Cargando...',
            processedText: 'Listo',
            noMoreText: 'No hay más resultados',
            failedText: 'No se pudo cargar',
            messageText: 'Actualizado a las %T',
          );

      var firebaseReady = false;
      // Ninguna dependencia externa debe bloquear indefinidamente el primer
      // fotograma, especialmente durante una instalación limpia.
      try {
        await Firebase.initializeApp().timeout(const Duration(seconds: 8));
        firebaseReady = true;
      } catch (error) {
        debugPrint('Firebase startup deferred: $error');
      }
      await Future.wait([
        translator.init(
          localeType: LocalizationDefaultType.asDefined,
          language: "es",
          languagesList: AppLanguages.codes,
          assetsDirectory: 'assets/lang/',
        ),
        LocalStorageService.getPrefs(),
      ]);
      await CartServices.getCartItems();

      if (firebaseReady) {
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      }
      runApp(LocalizedApp(child: MyApp()));

      // Estos servicios no deben retrasar la primera pantalla.
      unawaited(PhoneUtilService.init());
      DeepLinkService().initialize();
    },
    (error, stackTrace) {
      debugPrint('Startup error: $error');
    },
  );
}
