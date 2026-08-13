import 'dart:convert';
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
import 'package:chaskiy/models/api_response.dart';

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
        return status != null && status >= 200 && status < 500;
      },
      connectTimeout: 5.seconds,
      receiveTimeout: 20.seconds,
      sendTimeout: 20.seconds,
    );
    dio = new Dio(baseOptions);
    // Reject hosting error pages before the cache interceptor can store them.
    // If a previous valid response exists, the cache interceptor can still use
    // it as a fallback while the server is temporarily unavailable.
    dio!.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 503;
          final isApiRequest = response.requestOptions.uri.path.startsWith(
            '/api/',
          );

          if (!isApiRequest || statusCode == 204) {
            handler.next(response);
            return;
          }

          if (response.data is String) {
            try {
              final decoded = jsonDecode(response.data as String);
              if (decoded is Map || decoded is List) {
                response.data = decoded;
              }
            } catch (_) {
              // The response is not JSON (for example, a cPanel 500/509 page).
            }
          }

          if (response.data is Map || response.data is List) {
            handler.next(response);
            return;
          }

          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              message: ApiResponse.unavailableMessage,
            ),
          );
        },
      ),
    );
    dio!.interceptors.add(getCacheManager().interceptor);
  }

  DioCacheManager getCacheManager() {
    return DioCacheManager(
      CacheConfig(
        baseUrl: host,
        // Use a new namespace so releases do not reuse HTML error pages that
        // may have been cached by older versions of the app.
        databaseName: "ChaskiyApiCacheV2",
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
    bool forceRefresh = false,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";

    //preparing the post options if header is required
    final headers = includeHeaders ? await getHeaders() : null;
    final hasAuthenticatedUser =
        headers?[HttpHeaders.authorizationHeader]
            ?.replaceFirst('Bearer ', '')
            .isNotEmpty ??
        false;
    final requestOptions = Options(headers: headers);
    final mOptions =
        hasAuthenticatedUser
            ? requestOptions
            : buildCacheOptions(
              const Duration(minutes: 5),
              maxStale: const Duration(days: 30),
              forceRefresh: forceRefresh,
              options: requestOptions,
            );

    Response response;

    try {
      response = await dio!.get(
        uri,
        options: mOptions,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
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
    } on DioException catch (error) {
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
    } on DioException catch (error) {
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
    } on DioException catch (error) {
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
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }
    return response;
  }

  Response formatDioExecption(DioException ex) {
    final responseStatusCode = ex.response?.statusCode;
    final statusCode =
        responseStatusCode != null && responseStatusCode >= 400
            ? responseStatusCode
            : 503;
    String message;

    if (ex.type == DioExceptionType.connectionTimeout) {
      message =
          "Tiempo de conexión agotado. Revisa tu conexión a internet e inténtalo nuevamente";
    } else if (ex.type == DioExceptionType.sendTimeout ||
        ex.type == DioExceptionType.receiveTimeout) {
      message =
          "Tiempo de espera agotado. Revisa tu conexión a internet e inténtalo nuevamente";
    } else if (statusCode >= 500 || ex.type == DioExceptionType.badResponse) {
      message = ApiResponse.unavailableMessage;
    } else {
      message = "Revisa tu conexión a internet e inténtalo nuevamente";
    }

    return Response(
      requestOptions: ex.requestOptions,
      statusCode: statusCode,
      statusMessage: message,
      data: {"message": message},
    );
  }

  //NEUTRALS
  Future<Response> getExternal(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio!.get(url, queryParameters: queryParameters);
  }
}
