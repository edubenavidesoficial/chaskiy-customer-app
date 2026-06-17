import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/services/http.service.dart';

class PaymentMethodRequest extends HttpService {
  //
  Future<List<PaymentMethod>> getPaymentOptions({
    int? vendorId,
    Map<String, dynamic>? params,
  }) async {
    //
    Map<String, dynamic> queryParameters = {
      ...(params != null ? params : {}),
      "vendor_id": vendorId,
    };

    print("queryParameters ==> $queryParameters");
    final apiResult = await get(
      Api.paymentMethods,
      queryParameters: queryParameters,
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return PaymentMethod.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<PaymentMethod>> getTaxiPaymentOptions() async {
    final apiResult = await get(
      Api.paymentMethods,
      queryParameters: {"use_taxi": 1},
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return PaymentMethod.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
