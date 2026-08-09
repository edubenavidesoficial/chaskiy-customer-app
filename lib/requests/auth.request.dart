import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/services/firebase_token.service.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/enums/app_role.dart';

class AuthRequest extends HttpService {
  //
  Future<ApiResponse> loginRequest({
    required String email,
    required String password,
    String? role,
  }) async {
    final apiResult = await post(Api.login, {
      "email": email,
      "password": password,
      if (role != null) "role": role,
      "tokens": await FirebaseTokenService().getDeviceToken(),
    });

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> qrLoginRequest({
    required String code,
    String? role,
  }) async {
    final apiResult = await post(Api.qrlogin, {
      "code": code,
      if (role != null) "role": role,
      "tokens": await FirebaseTokenService().getDeviceToken(),
    });

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> resetPasswordRequest({
    required String phone,
    required String password,
    String? firebaseToken,
    String? customToken,
  }) async {
    final apiResult = await post(Api.forgotPassword, {
      "phone": phone,
      "password": password,
      "firebase_id_token": firebaseToken,
      "verification_token": customToken,
    });

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> registerRequest({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    String code = "",
    AppRole role = AppRole.customer,
  }) async {
    final isDriver = role == AppRole.driver;
    final apiResult = await post(isDriver ? Api.driverRegister : Api.register, {
      "name": name,
      "email": email,
      "phone": phone,
      "country_code": countryCode,
      "password": password,
      if (code.isNotEmpty) isDriver ? "referral_code" : "code": code,
      if (!isDriver) "role": "client",
      if (isDriver) "driver_type": "delivery",
      "tokens": await FirebaseTokenService().getDeviceToken(),
    });

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> applyForDriver({
    required String driverType,
    List<File> documents = const [],
  }) async {
    final formData = FormData.fromMap({'driver_type': driverType});
    for (final file in documents) {
      formData.files.add(
        MapEntry('documents[]', await MultipartFile.fromFile(file.path)),
      );
    }
    final result = await postWithFiles(Api.driverOnboarding, formData);
    return ApiResponse.fromResponse(result);
  }

  //
  Future<ApiResponse> logoutRequest() async {
    final apiResult = await get(Api.logout);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateOnlineStatus({required bool isOnline}) async {
    final apiResult = await post(Api.updateProfile, {
      "_method": "PUT",
      "is_online": isOnline ? 1 : 0,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<User> getMyDetails() async {
    final result = await get(Api.myProfile);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo actualizar';
    return User.fromJson(Map<String, dynamic>.from(response.body));
  }

  Future<ApiResponse> submitDriverDocuments({required List<File> files}) async {
    final formData = FormData.fromMap({});
    for (final file in files) {
      formData.files.add(
        MapEntry('documents[]', await MultipartFile.fromFile(file.path)),
      );
    }
    final result = await postWithFiles(Api.driverDocumentSubmission, formData);
    return ApiResponse.fromResponse(result);
  }

  //
  Future<ApiResponse> updateProfile({
    File? photo,
    String? name,
    String? email,
    String? phone,
    String? countryCode,
  }) async {
    final apiResult = await postWithFiles(Api.updateProfile, {
      "_method": "PUT",
      "name": name,
      "email": email,
      "phone": phone,
      "country_code": countryCode,
      "photo": photo != null ? await MultipartFile.fromFile(photo.path) : null,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updatePassword({
    String? password,
    String? new_password,
    String? new_password_confirmation,
  }) async {
    final apiResult = await post(Api.updatePassword, {
      "_method": "PUT",
      "password": password,
      "new_password": new_password,
      "new_password_confirmation": new_password_confirmation,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> verifyPhoneAccount(String phone) async {
    final apiResult = await get(
      Api.verifyPhoneAccount,
      queryParameters: {"phone": phone},
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendOTP(
    String phoneNumber, {
    bool isLogin = false,
  }) async {
    final apiResult = await post(Api.sendOtp, {
      "phone": phoneNumber,
      "is_login": isLogin,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  Future<ApiResponse> verifyOTP(
    String phoneNumber,
    String code, {
    bool isLogin = false,
  }) async {
    final apiResult = await post(Api.verifyOtp, {
      "phone": phoneNumber,
      "code": code,
      "is_login": isLogin,
      "tokens": await FirebaseTokenService().getDeviceToken(),
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  //
  Future<ApiResponse> verifyFirebaseToken(
    String phoneNumber,
    String firebaseVerificationId,
  ) async {
    //
    final apiResult = await post(Api.verifyFirebaseOtp, {
      "phone": phoneNumber,
      "firebase_id_token": firebaseVerificationId,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  //
  Future<ApiResponse?> socialLogin(
    String email,
    String? firebaseVerificationId,
    String provider, {
    String? nonce,
    String? uid,
  }) async {
    //
    final apiResult = await post(Api.socialLogin, {
      "provider": provider,
      "email": email,
      "firebase_id_token": firebaseVerificationId,
      "nonce": nonce,
      "uid": uid,
      "tokens": await FirebaseTokenService().getDeviceToken(),
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else if (apiResponse.code == 401) {
      return null;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<ApiResponse> deleteProfile({String? password, String? reason}) async {
    final apiResult = await post(Api.accountDelete, {
      "_method": "DELETE",
      "password": password,
      "reason": reason,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateDeviceToken(String token) async {
    late String deviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.manufacturer;
      deviceId += "-";
      deviceId += androidInfo.model;
      deviceId += "-";
      deviceId += androidInfo.id;
    }
    final apiResult = await post(Api.tokenSync, {
      "token": token,
      "deviceId": deviceId,
    });
    return ApiResponse.fromResponse(apiResult);
  }
}
