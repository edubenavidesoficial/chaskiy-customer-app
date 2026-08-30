import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/utils/map.utils.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';

class TaxiTripMapPreview extends StatefulWidget {
  TaxiTripMapPreview(this.order, {Key? key}) : super(key: key);

  final Order order;
  @override
  State<TaxiTripMapPreview> createState() => _TaxiTripMapPreviewState();
}

class _TaxiTripMapPreviewState extends State<TaxiTripMapPreview> {
  //
  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  //
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: context.screenWidth,
      child: AbsorbPointer(
        child: GoogleMap(
          zoomGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          padding: EdgeInsets.all(5),
          markers: Set.of(markers),
          polylines: polylines,
          initialCameraPosition: CameraPosition(
            target: widget.order.taxiOrder!.pickupLatLng,
            zoom: 16,
          ),
          cameraTargetBounds: CameraTargetBounds(
            MapUtils.targetBounds(
              widget.order.taxiOrder!.pickupLatLng,
              widget.order.taxiOrder!.dropoffLatLng,
            ),
          ),
          onMapCreated: setLocMarkers,
        ),
      ),
    );
  }

  setLocMarkers(GoogleMapController gMapController) async {
    await setGoogleMapStyle(gMapController);
    markers = [];
    markers = await getLocMakers();
    final route = await _getRoutePoints();
    final points =
        route.isNotEmpty
            ? route
            : [
              widget.order.taxiOrder!.pickupLatLng,
              widget.order.taxiOrder!.dropoffLatLng,
            ];
    //
    if (!mounted) return;
    setState(() {
      markers = markers;
      polylines = {
        Polyline(
          polylineId: const PolylineId('tripPreviewRoute'),
          points: points,
          color: AppColor.primaryColor,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      };
    });

    //zoom to bound
    gMapController.moveCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.targetBounds(
          widget.order.taxiOrder!.pickupLatLng,
          widget.order.taxiOrder!.dropoffLatLng,
        ),
        40,
      ),
    );
  }

  Future<List<LatLng>> _getRoutePoints() async {
    final pickup = widget.order.taxiOrder!.pickupLatLng;
    final dropoff = widget.order.taxiOrder!.dropoffLatLng;
    try {
      final legacy = await PolylinePoints().getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(pickup.latitude, pickup.longitude),
        PointLatLng(dropoff.latitude, dropoff.longitude),
      );
      if (legacy.points.isNotEmpty) {
        return legacy.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }
    } catch (_) {}

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://routes.googleapis.com/directions/v2:computeRoutes',
            ),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': AppStrings.googleMapApiKey,
              'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
            },
            body: jsonEncode({
              'origin': {
                'location': {
                  'latLng': {
                    'latitude': pickup.latitude,
                    'longitude': pickup.longitude,
                  },
                },
              },
              'destination': {
                'location': {
                  'latLng': {
                    'latitude': dropoff.latitude,
                    'longitude': dropoff.longitude,
                  },
                },
              },
              'travelMode': 'DRIVE',
              'routingPreference': 'TRAFFIC_AWARE',
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final body = jsonDecode(response.body);
      final routes = body is Map ? body['routes'] : null;
      if (routes is! List || routes.isEmpty) return [];
      final polyline = routes.first['polyline'];
      final encoded = polyline is Map ? polyline['encodedPolyline'] : null;
      if (encoded is! String || encoded.isEmpty) return [];
      return PolylinePoints()
          .decodePolyline(encoded)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> setGoogleMapStyle(gMapController) async {
    String value = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/json/google_map_style.json');
    //
    gMapController?.setMapStyle(value);
  }

  //
  Future<List<Marker>> getLocMakers() async {
    BitmapDescriptor sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.pickupLocation,
    );
    //
    BitmapDescriptor destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.dropoffLocation,
    );
    //
    //
    Marker pickupLocMarker = Marker(
      markerId: MarkerId(widget.order.taxiOrder!.pickupLatitude),
      position: widget.order.taxiOrder!.pickupLatLng,
      icon: sourceIcon,
    );
    //
    Marker dropoffLocMarker = Marker(
      markerId: MarkerId(widget.order.taxiOrder!.id.toString()),
      position: widget.order.taxiOrder!.dropoffLatLng,
      icon: destinationIcon,
    );
    //
    return [pickupLocMarker, dropoffLocMarker];
  }
}
