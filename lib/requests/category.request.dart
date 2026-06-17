import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/services/http.service.dart';

class CategoryRequest extends HttpService {
  //
  Future<List<Category>> categories({
    int? vendorTypeId,
    int? page,
    int? perPage,
    Map<String, dynamic>? customParams,
  }) async {
    Map<String, dynamic> params = {
      "vendor_type_id": vendorTypeId,
      "page": page,
      "per_page": perPage,
      "full": page == null ? 1 : 0,
    };

    if (customParams != null) {
      params.addAll(customParams);
    }
    final apiResult = await get(Api.categories, queryParameters: params);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Category>> subcategories({
    int? categoryId,
    int? page,
    bool mini = false,
  }) async {
    Map<String, dynamic> params = {
      "category_id": categoryId,
      "page": page,
      "type": "sub",
    };
    if (mini) {
      params["mini"] = 1;
    }

    final apiResult = await get(Api.categories, queryParameters: params);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
