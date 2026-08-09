import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/constants/app_map_settings.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/address.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/coordinates.dart';
import 'package:chaskiy/services/http.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart';

export 'package:chaskiy/models/address.dart';
export 'package:chaskiy/models/coordinates.dart';

class GeocoderService extends HttpService {
//
  /// Factory method that reuse same instance automatically
  factory GeocoderService() => Singleton.lazy(() => GeocoderService._());

  /// Private constructor
  GeocoderService._() {}

  /// Radio en el que se priorizan los resultados alrededor del usuario.
  static const int searchRadiusInMeters = 30000;

  Future<List<Address>> findAddressesFromCoordinates(
    Coordinates coordinates, {
    int limit = 5,
  }) async {
    //use backend api
    if (!AppMapSettings.useGoogleOnApp) {
      final apiresult = await get(
        Api.geocoderForward,
        queryParameters: {
          "lat": coordinates.latitude,
          "lng": coordinates.longitude,
          "limit": limit,
        },
      );

      //
      final apiResponse = ApiResponse.fromResponse(apiresult);
      if (apiResponse.allGood) {
        return (apiResponse.data).map((e) {
          // return Address().fromServerMap(e);
          Address address;
          try {
            address = Address().fromMap(e);
          } catch (error) {
            address = Address().fromServerMap(e);
          }
          return address;
        }).toList();
      }

      return [];
    }
    //use in-app geocoding
    final apiKey = AppStrings.googleMapApiKey;
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '${coordinates.latitude},${coordinates.longitude}',
        'key': apiKey,
      },
    ).toString();

    final apiResult = await get(
      Api.externalRedirect,
      queryParameters: {"endpoint": url},
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    //
    if (apiResponse.allGood && apiResponse.body is Map) {
      final apiResponseData = apiResponse.body as Map;
      final results = apiResponseData["results"];
      if (results is! List) {
        return [];
      }
      return results.map((e) {
        try {
          return Address().fromMap(e);
        } catch (error) {
          return Address().fromServerMap(e);
        }
      }).toList();
    }
    return [];
  }

  Future<List<Address>> findAddressesFromQuery(String address) async {
    //use in-app geocoding
    String myLatLng = "";
    if (LocationService.currenctAddress != null) {
      myLatLng = "${LocationService.currenctAddress?.coordinates?.latitude},";
      myLatLng += "${LocationService.currenctAddress?.coordinates?.longitude}";
    }

    //get current device region
    String? region;
    try {
      region = await Utils.getCurrentCountryCode();
    } catch (error) {
      region = "";
    }

    //use backend api
    if (!AppMapSettings.useGoogleOnApp) {
      final apiresult = await get(
        Api.geocoderReserve,
        queryParameters: {
          "keyword": address,
          "location": myLatLng,
          "region": region,
        },
      );

      //
      final apiResponse = ApiResponse.fromResponse(apiresult);
      if (apiResponse.allGood) {
        return (apiResponse.data).map((e) {
          Address address;
          try {
            address = Address().fromMap(e);
          } catch (error) {
            address = Address().fromServerMap(e);
          }
          address.gMapPlaceId = e["place_id"] ?? "";
          return address;
        }).toList();
      }

      return [];
    }
    //use in-app geocoding
    final apiKey = AppStrings.googleMapApiKey;

    // Los parámetros iban separados por ";" en vez de "&", así que Google los
    // recibía como parte del texto buscado: la búsqueda nunca se limitaba a
    // la zona del usuario. El radio también era de apenas 200 m.
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      {
        'query': address,
        'key': apiKey,
        if (myLatLng.isNotEmpty) ...{
          'location': myLatLng,
          'radius': '$searchRadiusInMeters',
        },
        if (region.isNotEmpty) 'region': region,
      },
    ).toString();
    final result = await get(
      Api.externalRedirect,
      queryParameters: {"endpoint": url},
    );

    final apiResult = ApiResponse.fromResponse(result);

    //
    if (apiResult.allGood) {
      //
      Map<String, dynamic> apiResponse = apiResult.body;
      List<dynamic> queryResult = ((apiResponse["predictions"] ?? apiResponse["results"]) as List);
      return queryResult.map((e) {
        Address address;
        try {
          address = Address().fromMap(e);
        } catch (error) {
          address = Address().fromServerMap(e);
        }
        address.gMapPlaceId = e["place_id"];
        return address;
      }).toList();
    }
    return [];
  }

  Future<Address> fecthPlaceDetails(Address address) async {
    //use backend api
    if (!AppMapSettings.useGoogleOnApp) {
      final apiresult = await get(
        Api.geocoderPlaceDetails,
        queryParameters: {
          "place_id": address.gMapPlaceId,
          "plain": true,
        },
      );

      //
      final apiResponse = ApiResponse.fromResponse(apiresult);
      if (apiResponse.allGood) {
        return Address().fromPlaceDetailsMap(apiResponse.body as Map);
      }

      return address;
    }

    //use in-app geocoding
    final apiKey = AppStrings.googleMapApiKey;
    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?fields=address_component,formatted_address,name,geometry;place_id=${address.gMapPlaceId};key=$apiKey";
    final result = await get(
      Api.externalRedirect,
      queryParameters: {"endpoint": url},
    );
    final apiResult = ApiResponse.fromResponse(result);

    //
    if (apiResult.allGood) {
      Map<String, dynamic> apiResponse = apiResult.body;
      address = address.fromPlaceDetailsMap(apiResponse["result"]);
      return address;
    }
    throw "Failed".tr();
  }
}
