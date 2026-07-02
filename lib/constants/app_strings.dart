import 'dart:convert';

import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:supercharged/supercharged.dart';

class AppStrings {
  //
  static String get appName => env('app_name');
  static String get companyName => env('company_name');
  static String get googleMapApiKey => env('google_maps_key');
  static String get fcmApiKey => env('fcm_key');
  static String get currencySymbol => env('currency');
  static String get currencyCode => env('currency_code');
  static String get countryCode => env('country_code');
  static bool get enableOtp => boolEnv('enble_otp');
  static bool get enableOTPLogin => boolEnv('enableOTPLogin');

  //
  static String get currentCurrencySymbol =>
      AppCurrencySystemService().currentCurrencySymbol;

  //
  static bool get enableEmailLogin =>
      boolEnv('enableEmailLogin', fallback: true);
  static bool get enableProfileUpdate =>
      boolEnv('enableProfileUpdate', fallback: true);

  static bool get enableGoogleDistance => boolEnv('enableGoogleDistance');
  static bool get enableSingleVendor => boolEnv('enableSingleVendor');
  static bool get enableMultipleVendorOrder =>
      boolEnv('enableMultipleVendorOrder');
  static bool get enableReferSystem => boolEnv('enableReferSystem');
  static String get referAmount => env('referAmount');
  static bool get enableChat => boolEnv('enableChat', fallback: true);
  static bool get enableOrderTracking =>
      boolEnv('enableOrderTracking', fallback: true);
  static bool get enableFatchByLocation =>
      boolEnv('enableFatchByLocation', fallback: true);
  static bool get showVendorTypeImageOnly => boolEnv('showVendorTypeImageOnly');
  static bool get enableUploadPrescription =>
      boolEnv('enableUploadPrescription', fallback: true);
  static bool get enableParcelVendorByLocation =>
      boolEnv('enableParcelVendorByLocation');
  static bool get enableParcelMultipleStops =>
      boolEnv('enableParcelMultipleStops');
  static int get maxParcelStops =>
      env('maxParcelStops').toString().toInt() ?? 1;
  static String get what3wordsApiKey => env('what3wordsApiKey') ?? "";
  static bool get isWhat3wordsApiKey => what3wordsApiKey.isNotEmpty;
  //App download links
  static String get androidDownloadLink => env('androidDownloadLink') ?? "";
  static String get iOSDownloadLink => env('iosDownloadLink') ?? "";
  //
  static bool get isSingleVendorMode => boolEnv('isSingleVendorMode');
  static bool get canScheduleTaxiOrder =>
      boolValue(mapEnv('taxi')['canScheduleTaxiOrder']);
  static int get taxiMaxScheduleDays =>
      (mapEnv('taxi')['taxiMaxScheduleDays'].toString().toInt()) ?? 2;

  static Map<String, dynamic> get enabledVendorType =>
      mapEnv('enabledVendorType');
  static double get bannerHeight =>
      double.parse("${env('bannerHeight') ?? 150.00}");

  //
  static String get otpGateway => env('otpGateway') ?? "none";
  static bool get isFirebaseOtp => otpGateway.toLowerCase() == "firebase";
  static bool get isCustomOtp =>
      !["none", "firebase"].contains(otpGateway.toLowerCase());

  static String get emergencyContact => env('emergencyContact') ?? "911";

  //Social media logins
  static bool get googleLogin => boolValue(mapEnv('auth')['googleLogin']);
  static bool get appleLogin => boolValue(mapEnv('auth')['appleLogin']);
  static bool get facebbokLogin => boolValue(mapEnv('auth')['facebbokLogin']);
  static bool get qrcodeLogin => boolValue(mapEnv('auth')['qrcodeLogin']);

  //UI Configures
  static dynamic get uiConfig {
    return env('ui') ?? null;
  }

  static double get categoryImageWidth {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 40.00;
    }
    return double.parse((env('ui')['categorySize']["w"] ?? 40.00).toString());
  }

  static double get categoryImageHeight {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 40.00;
    }
    return double.parse((env('ui')['categorySize']["h"] ?? 40.00).toString());
  }

  static double get categoryTextSize {
    if (env('ui') == null || env('ui')["categorySize"] == null) {
      return 12.00;
    }
    return double.parse(
      (env('ui')['categorySize']["text"]['size'] ?? 12.00).toString(),
    );
  }

  static int get categoryPerRow {
    try {
      if (env('ui') == null || env('ui')["categorySize"] == null) {
        return 4;
      }
      return int.parse((env('ui')['categorySize']["row"] ?? 4).toString());
    } catch (e) {
      return 3;
    }
  }

  static bool get categoryStyleGrid {
    try {
      if (env('ui') == null || env('ui')["categoryStyle"] == null) {
        return true;
      }
      String style = env('ui')['categoryStyle'].toString().toLowerCase();
      return style == "grid";
    } catch (e) {
      return true;
    }
  }

  static bool get searchGoogleMapByCountry {
    if (env('ui') == null || env('ui')["google"] == null) {
      return false;
    }
    return env('ui')['google']["searchByCountry"] ?? false;
  }

  static String get searchGoogleMapByCountries {
    if (env('ui') == null || env('ui')["google"] == null) {
      return "";
    }
    return env('ui')['google']["searchByCountries"] ?? "";
  }

  static bool get useWebsocketAssignment {
    return boolEnv('useWebsocketAssignment');
  }

  //DONT'T TOUCH
  static const String notificationChannel = "high_importance_channel";

  //START DON'T TOUNCH
  //for app usage
  static String firstTimeOnApp = "first_time";
  static String authenticated = "authenticated";
  static String userAuthToken = "auth_token";
  static String userKey = "user";
  static String appLocale = "locale";
  static String notificationsKey = "notifications";
  static String appCurrency = "currency";
  static String appColors = "colors";
  static String appExchangeRates = "exchange_rates";
  static String appRemoteSettings = "appRemoteSettings";
  //END DON'T TOUNCH

  //
  //Change to your app store id
  static String appStoreId = "";

  //
  //saving
  static Future<bool> saveAppSettingsToLocalStorage(String stringMap) async {
    return await LocalStorageService.prefs!.setString(
      AppStrings.appRemoteSettings,
      stringMap,
    );
  }

  static dynamic appSettingsObject;
  static Future<void> getAppSettingsFromLocalStorage() async {
    appSettingsObject = LocalStorageService.prefs?.getString(
      AppStrings.appRemoteSettings,
    );
    if (appSettingsObject != null) {
      appSettingsObject = jsonDecode(appSettingsObject);
    }
  }

  static dynamic env(String ref) {
    //
    getAppSettingsFromLocalStorage();
    //
    return appSettingsObject != null ? appSettingsObject[ref] : "";
  }

  static Map<String, dynamic> mapEnv(String ref) {
    final value = env(ref);
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  static bool boolEnv(String ref, {bool fallback = false}) {
    return boolValue(env(ref), fallback: fallback);
  }

  static bool boolValue(dynamic value, {bool fallback = false}) {
    if (value == null) {
      return fallback;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value == 1;
    }
    final normalized = value.toString().trim().toLowerCase();
    if (["1", "true", "yes", "on"].contains(normalized)) {
      return true;
    }
    if (["0", "false", "no", "off", ""].contains(normalized)) {
      return false;
    }
    return fallback;
  }

  //
  static List<String> get orderCancellationReasons {
    return ["Long pickup time", "Vendor is too slow", "custom"];
  }

  //
  static List<String> get orderStatuses {
    return [
      'pending',
      'preparing',
      'ready',
      'enroute',
      'failed',
      'cancelled',
      'delivered',
    ];
  }
}
