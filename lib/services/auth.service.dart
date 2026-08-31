import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/models/driver_vehicle.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/firebase.service.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/view_models/splash.vm.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import 'local_storage.service.dart';

class AuthServices {
  //
  //
  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static bool get isLoggedIn => authenticated();

  static Future<bool> isAuthenticated() async {
    await LocalStorageService.rxPrefs?.write(AppStrings.authenticated, true, (
      value,
    ) {
      return value;
    });
    return LocalStorageService.prefs!.setBool(AppStrings.authenticated, true);
  }

  // Token
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(token) async {
    return LocalStorageService.prefs!.setString(
      AppStrings.userAuthToken,
      token,
    );
  }

  //Locale
  static String getLocale() {
    return "es";
  }

  static Future<bool> setLocale(language) async {
    return LocalStorageService.prefs!.setString(AppStrings.appLocale, language);
  }

  static Stream<bool?> listenToAuthState() {
    return LocalStorageService.rxPrefs!.getBoolStream(AppStrings.authenticated);
  }

  //
  //
  static User? currentUser;
  static Future<User> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final userStringObject = await LocalStorageService.prefs?.getString(
        AppStrings.userKey,
      );
      final userObject = json.decode(userStringObject ?? "{}");
      currentUser = User.fromJson(userObject);
      await SessionService.setUser(currentUser!);
    }
    return currentUser!;
  }

  ///
  ///
  ///
  static Future<User?> saveUser(
    dynamic jsonObject, {
    bool reload = true,
  }) async {
    final parsedUser = User.fromJson(jsonObject);
    try {
      currentUser = parsedUser;
      await LocalStorageService.prefs?.setString(
        AppStrings.userKey,
        json.encode(parsedUser.toJson()),
      );
      await SessionService.setUser(parsedUser);

      //subscribe to firebase topic
      final audienceTopic =
          SessionService.isDriver ? "d_${parsedUser.id}" : "client";
      final roles = <String>{
        "all",
        "${parsedUser.id}",
        ...parsedUser.roleNames,
        audienceTopic,
      };

      for (var role in roles) {
        try {
          FirebaseService().firebaseMessaging.subscribeToTopic(role);
        } catch (error) {
          print("Unable to subscribe to:: $role");
        }
      }

      //log the new
      if (reload) {
        await SplashViewModel(
          AppService().navigatorKey.currentContext!,
        ).loadAppSettings();
      }

      return parsedUser;
    } catch (error) {
      return null;
    }
  }

  static DriverVehicle? currentDriverVehicle;

  static Future<DriverVehicle?> getDriverVehicle({bool force = false}) async {
    if (currentDriverVehicle == null || force) {
      final raw = LocalStorageService.prefs?.getString(
        AppStrings.driverVehicleKey,
      );
      if (raw == null || raw.isEmpty) return null;
      currentDriverVehicle = DriverVehicle.fromJson(json.decode(raw));
    }
    return currentDriverVehicle;
  }

  static Future<void> saveDriverVehicle(dynamic jsonObject) async {
    final vehicle = DriverVehicle.fromJson(
      Map<String, dynamic>.from(jsonObject),
    );
    currentDriverVehicle = vehicle;
    await LocalStorageService.prefs?.setString(
      AppStrings.driverVehicleKey,
      json.encode(vehicle.toJson()),
    );
  }

  ///
  ///
  //
  static Future<void> logout() async {
    final user = currentUser;
    final wasDriver = SessionService.isDriver;
    await HttpService().getCacheManager().clearAll();
    await LocalStorageService.prefs?.clear();
    await LocalStorageService.rxPrefs?.clear();

    //
    final roles = <String>{
      if (user != null) "${user.id}",
      if (user != null) user.role,
      "client",
      if (wasDriver && user != null) "d_${user.id}",
      "all",
    };
    for (var role in roles) {
      try {
        FirebaseService().firebaseMessaging.unsubscribeFromTopic(role);
      } catch (error) {
        print("Unable to unsubscribe to:: $role");
      }
    }
    currentUser = null;
    currentDriverVehicle = null;
    await SessionService.clear();
    await FirebaseAuth.instance.signOut();
  }
}
