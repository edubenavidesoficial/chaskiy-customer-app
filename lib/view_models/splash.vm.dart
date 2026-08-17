import 'dart:convert';

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
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';
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
  bool _loadingSettings = false;
  bool _hasNavigated = false;

  //
  initialise() async {
    super.initialise();
    if (await AuthServices.authenticated()) {
      await AuthServices.getCurrentUser(force: true);
    }
    await loadAppSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //

  //
  loadAppSettings() async {
    if (_loadingSettings || _hasNavigated) return;
    _loadingSettings = true;
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      if (!appSettingsObject.allGood) {
        throw appSettingsObject.message ??
            "No fue posible cargar la configuración de la aplicación";
      }

      final settings = _settingsMap(appSettingsObject.body);
      final appGenSettings = _settingsMap(settings?["strings"]);
      final colors = _settingsMap(settings?["colors"]);
      final exchangeRates = _settingsMap(settings?["exchange_rates"]);

      if (settings == null ||
          appGenSettings == null ||
          colors == null ||
          exchangeRates == null) {
        throw "La configuración recibida no está completa";
      }

      //set the app name ffrom package to the app settings
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      appGenSettings["app_name"] = appName;
      //app settings
      await updateAppVariables(appGenSettings);
      //colors
      await updateAppTheme(colors);
      await LocalStorageService.prefs?.setString(
        AppStrings.appExchangeRates,
        jsonEncode(exchangeRates),
      );
      await AppCurrencySystemService().init(exchangeRates);
      await loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
      if (_hasSavedSettings) {
        // La app puede iniciar con la última configuración válida. Las
        // siguientes lecturas intentarán red y usarán caché si sigue offline.
        await _restoreSavedSettings();
        await loadNextPage();
      } else {
        // En una instalación limpia mostramos un error recuperable. Un
        // reintento silencioso infinito deja al usuario atrapado en el splash.
      }
    } finally {
      _loadingSettings = false;
      setBusy(false);
    }
  }

  Map<String, dynamic>? _settingsMap(dynamic value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  bool get _hasSavedSettings {
    final saved = AppStrings.appSettingsObject;
    if (saved != null) return true;

    final raw = LocalStorageService.prefs?.getString(
      AppStrings.appRemoteSettings,
    );
    return raw != null && raw.isNotEmpty;
  }

  Future<void> _restoreSavedSettings() async {
    await AppStrings.getAppSettingsFromLocalStorage();
    await AppColor.getColorsFromLocalStorage();

    final rawExchangeRates = LocalStorageService.prefs?.getString(
      AppStrings.appExchangeRates,
    );
    if (rawExchangeRates == null || rawExchangeRates.isEmpty) return;

    try {
      final exchangeRates = _settingsMap(jsonDecode(rawExchangeRates));
      if (exchangeRates != null) {
        await AppCurrencySystemService().init(exchangeRates);
      }
    } catch (_) {
      // La moneda base de la app sigue disponible aunque este dato local sea
      // de una versión antigua o esté incompleto.
    }
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
    if (_hasNavigated) return;
    _hasNavigated = true;
    //
    await Utils.setJiffyLocale();
    //
    final isDriverSession =
        AuthServices.authenticated() && SessionService.isDriver;

    if (!isDriverSession && AuthServices.firstTimeOnApp()) {
      await AuthServices.setLocale("es");
      await translator.setNewLanguage(
        viewContext,
        newLanguage: "es",
        remember: true,
      );
      await Utils.setJiffyLocale();
    }
    //una sola navegación: antes se empujaba la pantalla del conductor y
    //enseguida la del cliente encima, así que el modo conductor nunca se veía
    final nextRoute =
        isDriverSession
            ? AppRoutes.driverHomeRoute
            : AuthServices.firstTimeOnApp()
            ? AppRoutes.welcomeRoute
            : AppRoutes.homeRoute;

    Navigator.of(
      viewContext,
    ).pushNamedAndRemoveUntil(nextRoute, (Route<dynamic> route) => false);

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
