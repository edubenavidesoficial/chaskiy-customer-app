import 'package:chaskiy/view_models/taxi_google_map.vm.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExistingDirections extends PolylinePoints {
  bool called = false;
  @override
  Future<PolylineResult> getRouteBetweenCoordinates(
    String key,
    PointLatLng origin,
    PointLatLng destination, {
    TravelMode travelMode = TravelMode.driving,
    List<PolylineWayPoint> wayPoints = const [],
    bool avoidHighways = false,
    bool avoidTolls = false,
    bool avoidFerries = true,
    bool optimizeWaypoints = false,
  }) async {
    called = true;
    return PolylineResult(
      points: [origin, const PointLatLng(0, 1), destination],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('trip map keeps the street geometry from existing Directions', () async {
    final directions = ExistingDirections();
    final vm = TaxiGoogleMapViewModel()..polylinePoints = directions;
    final points = await vm.getDrivingRoutePoints(
      const LatLng(0, 0),
      const LatLng(1, 1),
    );
    expect(directions.called, isTrue);
    expect(points.length, 3);
    expect(points[1].latitude, 0);
    expect(points[1].longitude, 1);
  });
}
