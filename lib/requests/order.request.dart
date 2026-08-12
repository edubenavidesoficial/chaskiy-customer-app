import 'dart:io';

import 'package:dio/dio.dart';
import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/models/driver_assignment.dart';

class OrderRequest extends HttpService {
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
    if (apiResponse.allGood) {
      List<Order> orders = [];
      List<dynamic> jsonArray =
          (apiResponse.body is List) ? apiResponse.body : apiResponse.data;
      for (var jsonObject in jsonArray) {
        try {
          orders.add(Order.fromJson(jsonObject));
        } catch (e) {
          print(e);
        }
      }

      return orders;
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<Order> getOrderDetails({required int id}) async {
    final apiResult = await get(Api.orders + "/$id");
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
