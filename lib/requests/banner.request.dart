import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/banner.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/services/location.service.dart';

class BannerRequest extends HttpService {
  //
  Future<List<Banner>> banners({
    int? vendorTypeId,
    Map? params,
  }) async {
    final apiResult = await get(
      Api.banners,
      queryParameters: {
        "vendor_type_id": vendorTypeId,
        ...(params != null ? params : {}),
        "latitude": LocationService.cLat,
        "longitude": LocationService.cLng,
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Banner.fromJSON(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
