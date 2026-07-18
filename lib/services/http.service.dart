import 'dart:io';
// import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/services/location.service.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
// import 'package:chaskiy/services/app.service.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:supercharged/supercharged.dart';

import 'auth.service.dart';
import 'local_storage.service.dart';

class HttpService {
  String host = Api.baseUrl;
  BaseOptions? baseOptions;
  Dio? dio;
  SharedPreferences? prefs;
  static Future<PackageInfo>? _packageInfoFuture;

  static Future<PackageInfo> get _packageInfo {
    return _packageInfoFuture ??= PackageInfo.fromPlatform();
  }

  Future<Map<String, String>> getHeaders() async {
    final packageInfo = await _packageInfo;
    double? cLat;
    double? cLng;
    //
    try {
      /*
      if (LocationService.currenctAddress == null) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (serviceEnabled) {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.whileInUse) {
            if (LocationService.currenctAddress == null) {
              final cLoc = await Geolocator.getCurrentPosition(
                timeLimit: 100.milliseconds,
              );
              cLat = cLoc.latitude;
              cLng = cLoc.longitude;
            } else {
              cLat = LocationService.currenctAddress!.coordinates!.latitude;
              cLng = LocationService.currenctAddress!.coordinates!.longitude;
            }
          }
        }
      } else {
        cLat = LocationService.currenctAddress!.coordinates!.latitude;
        cLng = LocationService.currenctAddress!.coordinates!.longitude;
      }
      */

      //
      cLat = LocationService.currenctAddress?.coordinates?.latitude;
      cLng = LocationService.currenctAddress?.coordinates?.longitude;
    } catch (error) {
      print("Error ==> $error");
    }

    //
    final userToken = await AuthServices.getAuthBearerToken();
    return {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.userAgentHeader:
          "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 ChaskiyCustomer/${packageInfo.version}",
      HttpHeaders.authorizationHeader: "Bearer $userToken",
      "X-Requested-With": "XMLHttpRequest",
      "X-Mobile-App": "ChaskiyCustomer",
      "X-App-Platform": Platform.operatingSystem,
      "lang": translator.activeLocale.languageCode,
      //
      'App-Version': packageInfo.buildNumber,
      'App-Type': 'customer',
      'c-lat': "$cLat",
      'c-lng': "$cLng",
    };
  }

  HttpService() {
    LocalStorageService.getPrefs();

    baseOptions = new BaseOptions(
      baseUrl: host,
      validateStatus: (status) {
        return status != null && status <= 500;
      },
      connectTimeout: 5.seconds,
    );
    dio = new Dio(baseOptions);
    dio!.interceptors.add(getCacheManager().interceptor);
  }

  DioCacheManager getCacheManager() {
    return DioCacheManager(
      CacheConfig(
        baseUrl: host,
        defaultMaxAge: const Duration(minutes: 5),
        defaultMaxStale: const Duration(days: 30),
      ),
    );
  }

  //for get api calls
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final headers = includeHeaders ? await getHeaders() : null;
    final mOptions = buildCacheOptions(
      const Duration(minutes: 5),
      maxStale: const Duration(days: 30),
      options: Options(headers: headers),
    );

    Response response;

    try {
      response = await dio!.get(
        uri,
        options: mOptions,
        queryParameters: queryParameters,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for post api calls
  Future<Response> post(String url, body, {bool includeHeaders = true}) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final mOptions =
        !includeHeaders ? null : Options(headers: await getHeaders());

    Response response;
    try {
      response = await dio!.post(uri, data: body, options: mOptions);
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for post api calls with file upload
  Future<Response> postWithFiles(
    String url,
    body, {
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";
    //preparing the post options if header is required
    final mOptions =
        !includeHeaders ? null : Options(headers: await getHeaders());

    Response response;
    try {
      response = await dio!.post(
        uri,
        data: body is FormData ? body : FormData.fromMap(body),
        options: mOptions,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for patch api calls
  Future<Response> patch(String url, Map<String, dynamic> body) async {
    String uri = "$host$url";
    Response response;

    try {
      response = await dio!.patch(
        uri,
        data: body,
        options: Options(headers: await getHeaders()),
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for delete api calls
  Future<Response> delete(String url) async {
    String uri = "$host$url";

    Response response;
    try {
      response = await dio!.delete(
        uri,
        options: Options(headers: await getHeaders()),
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }
    return response;
  }

  Response formatDioExecption(DioError ex) {
    var response = Response(requestOptions: ex.requestOptions);
    print("type ==> ${ex.type}");
    response.statusCode = 400;
    String? msg = response.statusMessage;

    try {
      if (ex.type == DioErrorType.connectionTimeout) {
        msg =
            "Tiempo de conexión agotado. Revisa tu conexión a internet e inténtalo nuevamente"
                .tr();
      } else if (ex.type == DioErrorType.sendTimeout) {
        msg =
            "Tiempo de espera agotado. Revisa tu conexión a internet e inténtalo nuevamente"
                .tr();
      } else if (ex.type == DioErrorType.receiveTimeout) {
        msg =
            "Tiempo de espera agotado. Revisa tu conexión a internet e inténtalo nuevamente"
                .tr();
      } else if (ex.type == DioErrorType.connectionTimeout) {
        msg =
            "Tiempo de conexión agotado. Revisa tu conexión a internet e inténtalo nuevamente"
                .tr();
      } else {
        msg = "Revisa tu conexión a internet e inténtalo nuevamente".tr();
      }
      response.data = {"message": msg};
    } catch (error) {
      response.statusCode = 400;
      msg = "Revisa tu conexión a internet e inténtalo nuevamente".tr();
      response.data = {"message": msg};
    }

    throw msg;
  }

  //NEUTRALS
  Future<Response> getExternal(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio!.get(url, queryParameters: queryParameters);
  }
}
