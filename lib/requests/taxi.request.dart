import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/models/driver.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/tax_order_location.history.dart';
import 'package:chaskiy/models/vehicle.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/services/http.service.dart';

class TaxiRequest extends HttpService {
  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    int? vehicleTypeId,
  }) async {
    final result = await get(
      Api.nearbyTaxiDrivers,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        if (vehicleTypeId != null) 'vehicle_type_id': vehicleTypeId,
      },
      forceRefresh: true,
    );
    final response = ApiResponse.fromResponse(result);
    if (!response.allGood || response.body is! List) return const [];
    return (response.body as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  //
  Future<List<VehicleType>> getVehicleTypes() async {
    final apiResult = await get("${Api.vehicleTypes}", forceRefresh: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return parseVehicleTypes(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<List<VehicleType>> getVehicleTypePricing(
    DeliveryAddress pickup,
    DeliveryAddress dropoff, {
    String? countryCode,
    List<DeliveryAddress> stops = const [],
  }) async {
    //
    final apiResult = await get(
      "${Api.vehicleTypePricing}",
      forceRefresh: true,
      queryParameters: {
        "pickup": "${pickup.latitude},${pickup.longitude}",
        for (var i = 0; i < stops.length; i++) ...{
          'stops[$i][lat]': stops[i].latitude,
          'stops[$i][lng]': stops[i].longitude,
          'stops[$i][address]': stops[i].address,
        },
        "dropoff": "${dropoff.latitude},${dropoff.longitude}",
        if (countryCode != null && countryCode.trim().isNotEmpty)
          "country_code": countryCode.trim(),
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return parseVehicleTypes(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  /// Accept the list and the standard API resource envelope. A malformed
  /// response is an error, never evidence that no vehicles are available.
  static List<VehicleType> parseVehicleTypes(dynamic body) {
    final items = body is Map ? body['data'] : body;
    if (items is! List) {
      throw const FormatException('Respuesta de vehículos inválida');
    }
    final vehicles = <VehicleType>[];
    for (final item in items) {
      try {
        vehicles.add(VehicleType.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        // One malformed option must not hide the remaining valid vehicles.
      }
    }
    if (items.isNotEmpty && vehicles.isEmpty) {
      throw const FormatException('No se pudieron interpretar los vehículos');
    }
    return vehicles;
  }

  Future<ApiResponse> locationAvailable(
    double latitude,
    double longitude,
  ) async {
    final apiResult = await get(
      Api.taxiLocationAvailable,
      queryParameters: {"latitude": latitude, "longitude": longitude},
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> placeNeworder({Map<String, dynamic>? params}) async {
    final apiResult = await post("${Api.newTaxiBooking}", params);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<Order?> getOnGoingTrip() async {
    // el viaje en curso cambia en segundos: si se lee de caché, justo después
    // de pedir el viaje se recibe la respuesta vieja ("sin viaje") y la app
    // sale de la pantalla de búsqueda de conductor
    final apiResult = await get(
      "${Api.currentTaxiBooking}",
      queryParameters: {'role': 'customer'},
      forceRefresh: true,
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    //
    if (apiResponse.allGood) {
      //if there is order
      if (apiResponse.body["order"] != null) {
        return Order.fromJson(apiResponse.body["order"]);
      } else {
        return null;
      }
    }

    //
    throw apiResponse.body;
  }

  //
  Future<ApiResponse> cancelTrip(int id) async {
    final apiResult = await get("${Api.cancelTaxiBooking}/$id");
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateDestination(
    int orderId,
    DeliveryAddress destination,
  ) async {
    final apiResult =
        await patch('${Api.updateTaxiDestination}/$orderId/destination', {
          'address': destination.address,
          'latitude': destination.latitude,
          'longitude': destination.longitude,
        });
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<Driver> getDriverInfo(int id) async {
    //la asignación del conductor también es información en tiempo real
    final apiResult = await get(
      "${Api.taxiDriverInfo}/$id",
      forceRefresh: true,
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    final driver = Driver.fromJson(apiResponse.body["driver"]);
    driver.vehicle = Vehicle.fromJson(apiResponse.body["vehicle"]);
    return driver;
  }

  Future<ApiResponse> rateDriver(
    int orderId,
    int driverId,
    double newTripRating,
    String review,
  ) async {
    //
    final apiResult = await post("${Api.rating}", {
      //
      "driver_id": driverId,
      "order_id": orderId,
      "rating": newTripRating,
      "review": review,
    });
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<TaxiOrderLocationHistory>> locationHistory() async {
    final apiResult = await get(Api.taxiTripLocationHistory);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return (apiResponse.body as List)
        .map((e) => TaxiOrderLocationHistory.fromJson(e))
        .toList();
  }

  Future<Order?> getLastTripForRating() async {
    final apiResult = await get(Api.lastRatebleTaxiBooking, forceRefresh: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      if (apiResponse.body["order"] != null) {
        return Order.fromJson(apiResponse.body["order"]);
      } else {
        return null;
      }
    }
    throw apiResponse.body;
  }
}
