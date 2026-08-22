import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/models/driver_assignment.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';

class OrderRequest extends HttpService {
  static const _ordersCacheVersion = 'v1';
  static const _ordersCacheMaxAge = Duration(hours: 24);

  Future<String> _ordersCacheKey(Map<String, dynamic>? params) async {
    var userId = params?['driver_id']?.toString();
    try {
      userId ??= (await AuthServices.getCurrentUser()).id.toString();
    } catch (_) {
      userId ??= 'anonymous';
    }
    final entries =
        (params ?? {}).entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final signature = entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'orders_cache_${_ordersCacheVersion}_${userId}_$signature';
  }

  List<Order> _parseOrders(List<dynamic> jsonArray) {
    final orders = <Order>[];
    Object? parseError;
    for (final jsonObject in jsonArray) {
      try {
        orders.add(Order.fromJson(jsonObject));
      } catch (error) {
        parseError ??= error;
        print('Error leyendo un pedido ==> $error');
      }
    }
    if (orders.isEmpty && jsonArray.isNotEmpty) {
      throw 'No se pudieron leer los pedidos: $parseError';
    }
    return orders;
  }

  Future<List<Order>> getCachedOrders({Map<String, dynamic>? params}) async {
    try {
      final prefs = await LocalStorageService.getPrefs();
      final value = prefs.getString(await _ordersCacheKey(params));
      if (value == null) return const [];
      final cached = jsonDecode(value);
      if (cached is! Map<String, dynamic>) return const [];
      final savedAt = DateTime.tryParse('${cached['saved_at']}');
      if (savedAt == null ||
          DateTime.now().difference(savedAt) > _ordersCacheMaxAge) {
        return const [];
      }
      final data = cached['data'];
      return data is List ? _parseOrders(data) : const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _cacheOrders(
    List<dynamic> jsonArray,
    Map<String, dynamic>? params,
  ) async {
    try {
      final prefs = await LocalStorageService.getPrefs();
      await prefs.setString(
        await _ordersCacheKey(params),
        jsonEncode({
          'saved_at': DateTime.now().toIso8601String(),
          'data': jsonArray,
        }),
      );
    } catch (_) {
      // La caché es una optimización; nunca debe bloquear la consulta real.
    }
  }

  Future<DriverAssignment?> getPendingDriverAssignment() async {
    // This endpoint is real-time state. Caching a previous null response makes
    // every five-second poll return "no assignment" for several minutes.
    final result = await get(Api.pendingDriverAssignment, forceRefresh: true);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) {
      throw response.message ?? 'No se pudo consultar la asignación';
    }
    if (response.body is! Map || response.body['assignment'] is! Map) {
      return null;
    }
    return DriverAssignment.fromJson(
      Map<String, dynamic>.from(response.body['assignment']),
    );
  }

  //
  Future<List<Order>> getOrders({
    int page = 1,
    Map<String, dynamic>? params,
  }) async {
    final apiResult = await get(
      Api.orders,
      queryParameters: {"page": page, ...(params != null ? params : {})},
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (!apiResponse.allGood) {
      throw apiResponse.message!;
    }

    List<dynamic> jsonArray =
        (apiResponse.body is List) ? apiResponse.body : apiResponse.data;
    final orders = _parseOrders(jsonArray);
    if (page == 1) await _cacheOrders(jsonArray, params);
    return orders;
  }

  //
  Future<Order> getOrderDetails({required int id}) async {
    final apiResult = await get(Api.orders + "/$id", forceRefresh: true);
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<String> updateOrder({int? id, String? status, String? reason}) async {
    final apiResult = await patch(Api.orders + "/$id", {
      "status": status,
      "reason": reason,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.message!;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<Order> updateDriverOrder({
    required int id,
    required String status,
  }) async {
    final result = await patch('${Api.orders}/$id', {'status': status});
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo actualizar';
    final source =
        response.body is Map && response.body['order'] != null
            ? response.body['order']
            : response.body;
    return Order.fromJson(source);
  }

  Future<Order> submitDriverProof({
    required int id,
    required File file,
    required String proofType,
  }) async {
    final result = await postWithFiles('${Api.orders}/$id', {
      '_method': 'PUT',
      'status': 'delivered',
      'proof_type': proofType,
      'signature': await MultipartFile.fromFile(file.path),
    });
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo completar';
    return Order.fromJson(response.body['order']);
  }

  Future<Order> verifyDeliveryStop({required int stopId}) async {
    final result = await post('/package/order/stop/verify/$stopId', {});
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) {
      throw response.message ?? 'No se pudo confirmar la entrega';
    }
    return Order.fromJson(response.body['order']);
  }

  Future<Order> acceptDriverAssignment({
    required int orderId,
    required int driverId,
  }) async {
    final result = await post(Api.acceptDriverAssignment, {
      'order_id': orderId,
      'driver_id': driverId,
      'status': 'preparing',
    });
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'Asignación no disponible';
    return Order.fromJson(response.body['order']);
  }

  Future<void> rejectDriverAssignment({
    required int orderId,
    required int driverId,
  }) async {
    final result = await post(Api.rejectDriverAssignment, {
      'order_id': orderId,
      'driver_id': driverId,
    });
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo rechazar';
  }

  //
  Future<Order> trackOrder(String code, {int? vendorTypeId}) async {
    //
    final apiResult = await post(Api.trackOrder, {
      "code": code,
      "vendor_type_id": vendorTypeId,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  Future<ApiResponse> updateOrderPaymentMethod({
    int? id,
    int? paymentMethodId,
    String? status,
  }) async {
    //
    final apiResult = await patch(Api.orders + "/$id", {
      "payment_method_id": paymentMethodId,
      "payment_status": status,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<String>> orderCancellationReasons({Order? order}) async {
    //
    final apiResult = await get(
      Api.cancellationReasons,
      queryParameters: {"type": (order?.isTaxi ?? false) ? "taxi" : "order"},
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List).map((e) {
        return e['reason'].toString();
      }).toList();
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<ApiResponse> syncDriverLocation(int orderId) async {
    //
    String url = Api.syncDriverLocation;
    url = url.replaceAll("{order}", "$orderId");
    final apiResult = await post(url, {});
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message!;
    }
  }
}
