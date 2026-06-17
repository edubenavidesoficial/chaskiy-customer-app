import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/search_data.dart';
import 'package:chaskiy/models/service.dart';
import 'package:chaskiy/models/tag.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/services/search.service.dart';

class SearchRequest extends HttpService {
  //
  Future<List<Tag>> getTags() async {
    final apiResult = await get(Api.tags);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List).map((jsonObject) {
        return Tag.fromJson(jsonObject);
      }).toList();
    }
    throw apiResponse.message!;
  }

  Future<SearchData> getSearchFilterData({int? vendorTypeId}) async {
    final apiResult = await get(
      Api.searchData,
      queryParameters: {"vendor_type_id": vendorTypeId},
    );
    // print("result ==> $apiResult::$vendorTypeId");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return SearchData.fromJson(apiResponse.body);
    }
    throw apiResponse.message!;
  }

  //
  Future<List<dynamic>> searchRequest({
    String keyword = "",
    String? type,
    required Search search,
    int page = 1,
  }) async {
    //save the search keyword
    if (keyword.isNotEmpty) {
      await SearchService.saveSearchHistory(keyword);
    }
    //
    Map<String, dynamic> params = {
      "merge": "1",
      "page": page,
      "keyword": keyword,
      "category_id": search.category?.id,
      "subcategory_id": search.subcategory?.id,
      "vendor_type_id": search.vendorType?.id,
      "vendor_id": search.vendorId,
      "type": type ?? search.type,
      "min_price": search.minPrice,
      "max_price": search.maxPrice,
      "sort": search.sort,
      "tags": search.tags?.map((e) => e.id).toList(),
      "filter": search.productDataFetchType?.toString(),
    };

    //
    if (search.byLocation ?? true) {
      params = {
        ...params,
        "latitude": await LocationService.getFetchByLocationLat(),
        "longitude": await LocationService.getFetchByLocationLng(),
      };
    }

    // print("params ==> ${jsonEncode(params)}");
    final apiResult = await get(Api.search, queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      //
      List<dynamic> result = [];

      //
      type ??= search.type;

      //
      result =
          (apiResponse.data).map((jsonObject) {
            dynamic model;
            if (type == 'product') {
              model = Product.fromJson(jsonObject);
            } else if (type == "vendor") {
              model = Vendor.fromJson(jsonObject);
            } else if (type == "service") {
              model = Service.fromJson(jsonObject);
            } else {
              model = Product.fromJson(jsonObject);
            }
            return model;
          }).toList();
      return result;
    }

    throw apiResponse.message!;
  }

  //service search request
  Future<List<dynamic>> serviceSearchRequest({
    String keyword = "",
    String? type,
    required Search search,
    int page = 1,
  }) async {
    //save the search keyword
    if (keyword.isNotEmpty) {
      await SearchService.saveSearchHistory(keyword);
    }
    //
    Map<String, dynamic> params = {
      "merge": "1",
      "page": page,
      "keyword": keyword,
      "category_id":
          (search.subcategory == null && search.category != null)
              ? search.category?.id
              : null,
      "subcategory_id":
          search.subcategory != null ? search.subcategory?.id : '',
      "vendor_type_id": search.vendorType != null ? search.vendorType?.id : "",
      "vendor_id": search.vendorId != null ? search.vendorId : "",
      "type": type ?? search.type,
      "min_price": search.minPrice,
      "max_price": search.maxPrice,
      "sort": search.sort,
      "tags": search.tags?.map((e) => e.id).toList(),
      "filter": search.productDataFetchType?.toString(),
    };

    //
    if (search.byLocation ?? true) {
      params = {
        ...params,
        "latitude": await LocationService.getFetchByLocationLat(),
        "longitude": await LocationService.getFetchByLocationLng(),
      };
    }

    // print("params ==> ${jsonEncode(params)}");
    final apiResult = await get(Api.search, queryParameters: params);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      //
      List<dynamic> result = [];

      //
      type ??= search.type;

      //
      result =
          (apiResponse.data).map((jsonObject) {
            dynamic model;
            if (type == 'product') {
              model = Product.fromJson(jsonObject);
            } else if (type == "vendor") {
              model = Vendor.fromJson(jsonObject);
            } else if (type == "service") {
              model = Service.fromJson(jsonObject);
            } else {
              model = Product.fromJson(jsonObject);
            }
            return model;
          }).toList();
      return result;
    }

    throw apiResponse.message!;
  }
}
