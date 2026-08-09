import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/services/http.service.dart';

class DriverRequest extends HttpService {
  Future<void> syncLocation({
    required double latitude,
    required double longitude,
    required double heading,
  }) async {
    final result = await post(Api.driverLocationSync, {
      'lat': latitude,
      'lng': longitude,
      'rotation': heading,
    });
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood) {
      throw response.message ?? 'No se pudo sincronizar la ubicación';
    }
  }
}
