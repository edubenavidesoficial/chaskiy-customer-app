import 'dart:io';

import 'package:dio/dio.dart';
import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/driver_vehicle.dart';
import 'package:chaskiy/services/http.service.dart';

class DriverVehicleRequest extends HttpService {
  Future<List<Map<String, dynamic>>> options(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    final result = await get(endpoint, queryParameters: query);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudieron cargar';
    final source = response.body is List ? response.body : response.data;
    return (source as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<ApiResponse> register({
    required Map<String, dynamic> values,
    List<File> documents = const [],
  }) async {
    final form = FormData.fromMap(values);
    for (final document in documents) {
      form.files.add(
        MapEntry('documents[]', await MultipartFile.fromFile(document.path)),
      );
    }
    final result = await postWithFiles(Api.driverVehicleRegister, form);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo registrar';
    return response;
  }
  Future<List<DriverVehicle>> vehicles() async {
    final result = await get(Api.driverVehicles);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudieron cargar';

    final source = response.body is List ? response.body : response.data;
    return (source as List)
        .map((json) => DriverVehicle.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<ApiResponse> activate(int id) async {
    final result = await post(
      Api.activateDriverVehicle.replaceAll('{id}', '$id'),
      const {},
    );
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo activar';
    return response;
  }
}
