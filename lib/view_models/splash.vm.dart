import 'dart:convert';
import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_theme.dart';
import 'package:chaskiy/requests/settings.request.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/firebase.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';
import 'package:chaskiy/services/websocket.service.dart';
import 'package:chaskiy/utils/utils.dart';
//import 'package:chaskiy/widgets/cards/language_selector.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'base.view_model.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  SettingsRequest settingsRequest = SettingsRequest();
  Timer? _retryTimer;

  //
  initialise() async {
    super.initialise();
    await loadAppSettings();
    if (await AuthServices.authenticated()) {
      await AuthServices.getCurrentUser(force: true);
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      //START: WEBSOCKET SETTINGS
      if (appSettingsObject.body["websocket"] != null) {
        await WebsocketService().saveWebsocketDetails(
          appSettingsObject.body["websocket"],
        );
      }
      //END: WEBSOCKET SETTINGS

      Map<String, dynamic> appGenSettings = appSettingsObject.body["strings"];
      //set the app name ffrom package to the app settings
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      appGenSettings["app_name"] = appName;
      //app settings
      await updateAppVariables(appGenSettings);
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);
      await AppCurrencySystemService().init(
        appSettingsObject.body["exchange_rates"],
      );
      _retryTimer?.cancel();
      loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
      if (_hasSavedSettings) {
        // La app puede iniciar con la última configuración válida. Las
        // siguientes lecturas intentarán red y usarán caché si sigue offline.
        loadNextPage();
      } else {
        // En la primera instalación todavía no existe contenido local. Se
        // reintenta silenciosamente sin encerrar al usuario en un diálogo.
        _retryTimer?.cancel();
        _retryTimer = Timer(const Duration(seconds: 8), loadAppSettings);
      }
    }
    setBusy(false);
  }

  bool get _hasSavedSettings {
    final saved = AppStrings.appSettingsObject;
    if (saved != null) return true;

    final raw = LocalStorageService.prefs?.getString(
      AppStrings.appRemoteSettings,
    );
    return raw != null && raw.isNotEmpty;
  }

  //
  updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    //
    if (AuthServices.firstTimeOnApp()) {
      await AuthServices.setLocale("es");
      await translator.setNewLanguage(
        viewContext,
        newLanguage: "es",
        remember: true,
      );
      await Utils.setJiffyLocale();
    }
    //
    if (AuthServices.firstTimeOnApp()) {
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.welcomeRoute,
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(viewContext).pushNamedAndRemoveUntil(
        AppRoutes.homeRoute,
        (Route<dynamic> route) => false,
      );
    }

    //
    RemoteMessage? initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      //
      FirebaseService().saveNewNotification(initialMessage);
      FirebaseService().notificationPayloadData = initialMessage.data;
      FirebaseService().selectNotification("");
    }
  }
}
