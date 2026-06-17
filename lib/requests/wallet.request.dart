import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/wallet.dart';
import 'package:chaskiy/models/wallet_transaction.dart';
import 'package:chaskiy/services/http.service.dart';

class WalletRequest extends HttpService {
  //
  Future<Wallet> walletBalance() async {
    final apiResult = await get(Api.walletBalance);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Wallet.fromJson(apiResponse.body);
    }

    throw apiResponse.message!;
  }

  Future<dynamic> walletTopup(String amount, {int? paymentMethodId}) async {
    Map<String, dynamic> params = {
      "amount": amount,
    };

    if (paymentMethodId != null) {
      params.addAll({
        "payment_method_id": paymentMethodId,
      });
    }

    final apiResult = await post(
      Api.walletTopUp,
      params,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      //
      if (paymentMethodId != null) {
        return apiResponse;
      }
      //
      return apiResponse.body["link"];
    }

    throw apiResponse.message!;
  }

  Future<List<WalletTransaction>> walletTransactions({int page = 1}) async {
    final apiResult =
        await get(Api.walletTransactions, queryParameters: {"page": page});

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body["data"] as List)
          .map((e) => WalletTransaction.fromJson(e))
          .toList();
    }

    throw "${apiResponse.message}";
  }

  Future<ApiResponse> myWalletAddress() async {
    final apiResult = await get(Api.myWalletAddress);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> getWalletAddress(String keyword) async {
    final apiResult = await get(
      Api.walletAddressesSearch,
      queryParameters: {
        "keyword": keyword,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> transferWallet(
    String amount,
    String walletAddress,
    String password,
  ) async {
    final apiResult = await post(
      Api.walletTransfer,
      {
        "wallet_address": walletAddress,
        "amount": amount,
        "password": password,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
