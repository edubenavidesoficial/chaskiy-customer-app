import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/driver_payment_account.dart';
import 'package:chaskiy/services/http.service.dart';

class DriverFinanceRequest extends HttpService {
  Future<Map<String, dynamic>> metrics() async {
    final result = await get(Api.driverMetrics);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo cargar';
    return Map<String, dynamic>.from(response.body);
  }

  Future<List<Map<String, dynamic>>> earnings({
    required DateTime start,
    required DateTime end,
    int page = 1,
  }) => _report(Api.driverEarningsReport, start, end, page);

  Future<List<Map<String, dynamic>>> payouts({
    required DateTime start,
    required DateTime end,
    int page = 1,
  }) => _report(Api.driverPayoutsReport, start, end, page);

  Future<double> availableEarning() async {
    final result = await get(Api.driverEarning);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo cargar';
    return double.tryParse('${response.body['earning']?['amount'] ?? 0}') ?? 0;
  }

  Future<List<DriverPaymentAccount>> paymentAccounts() async {
    final result = await get(
      Api.driverPaymentAccounts,
      queryParameters: const {'page': 0},
    );
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo cargar';
    final dynamic body = response.body;
    final source = body is Map && body['data'] is List
        ? body['data'] as List
        : body is List
            ? body
            : response.data;
    return source
        .map((item) => DriverPaymentAccount.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<DriverPaymentAccount> savePaymentAccount({
    int? id,
    required String name,
    required String number,
    required String instructions,
    required bool isActive,
  }) async {
    final payload = {
      'name': name,
      'number': number,
      'instructions': instructions,
      'is_active': isActive ? '1' : '0',
    };
    final result = id == null
        ? await post(Api.driverPaymentAccounts, payload)
        : await patch('${Api.driverPaymentAccounts}/$id', payload);
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo guardar';
    return DriverPaymentAccount.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  Future<void> requestPayout({
    required double amount,
    required int paymentAccountId,
  }) async {
    final result = await post(Api.driverPayoutRequest, {
      'amount': amount,
      'payment_account_id': paymentAccountId,
    });
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo solicitar';
  }

  Future<List<Map<String, dynamic>>> _report(
    String endpoint,
    DateTime start,
    DateTime end,
    int page,
  ) async {
    final result = await get(
      endpoint,
      queryParameters: {
        'page': page,
        'start_date': _date(start),
        'end_date': _date(end),
      },
    );
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) throw response.message ?? 'No se pudo cargar';
    final source = response.body is List ? response.body : response.data;
    return (source as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
