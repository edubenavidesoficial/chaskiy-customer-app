import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/driver_location.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderTrackingViewModel extends MyBaseViewModel {
  //
  Order order;
  GoogleMapController? controller;
  Set<Marker>? mapMarkers;
  LatLng? pickupLatLng;
  LatLng? destinationLatLng;
  LatLng? driverLatLng;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  //
  Timer? driverLocationPollingTimer;

  //
  OrderTrackingViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  LatLng get initialCameraTarget {
    final destination =
        order.isPackageDelivery ? order.dropoffLocation : order.deliveryAddress;
    final destinationLat = destination?.latitude;
    final destinationLng = destination?.longitude;
    if (destinationLat != null && destinationLng != null) {
      return LatLng(destinationLat, destinationLng);
    }

    if (order.isPackageDelivery && order.pickupLocation != null) {
      return LatLng(
        order.pickupLocation!.latitude ?? 0,
        order.pickupLocation!.longitude ?? 0,
      );
    }

    return LatLng(
      double.tryParse(order.vendor?.latitude ?? '') ?? 0,
      double.tryParse(order.vendor?.longitude ?? '') ?? 0,
    );
  }

  //
  void setMapController(GoogleMapController mController) {
    controller = mController;
    notifyListeners();

    //zoom map camera to bound
    zoomToLatLngBound();
  }

  //
  initialise() async {
    //vendor location marker
    mapMarkers = new Set<Marker>();

    //pickup address
    final vendorIcon = await markerIcon(
      order.isPackageDelivery ? AppImages.addressPin : AppImages.vendor,
    );
    mapMarkers!.add(
      Marker(
        markerId: MarkerId("pickup"),
        position:
            pickupLatLng = LatLng(
              order.isPackageDelivery
                  ? order.pickupLocation!.latitude!
                  : double.parse(order.vendor!.latitude),
              order.isPackageDelivery
                  ? order.pickupLocation!.longitude!
                  : double.parse(order.vendor!.longitude),
            ),
        infoWindow: InfoWindow(
          title:
              order.isPackageDelivery
                  ? order.pickupLocation?.name
                  : order.vendor?.name,
        ),
        icon: vendorIcon,
      ),
    );

    //delivery address
    final deliveryAddressIcon = await markerIcon(AppImages.deliveryParcel);
    mapMarkers!.add(
      Marker(
        markerId: MarkerId("destination"),
        position:
            destinationLatLng = LatLng(
              order.isPackageDelivery
                  ? order.dropoffLocation!.latitude!
                  : order.deliveryAddress!.latitude!,
              order.isPackageDelivery
                  ? order.dropoffLocation!.longitude!
                  : order.deliveryAddress!.longitude!,
            ),
        infoWindow: InfoWindow(
          title:
              order.isPackageDelivery
                  ? order.dropoffLocation?.name
                  : order.deliveryAddress?.name,
        ),
        icon: deliveryAddressIcon,
      ),
    );

    //
    notifyListeners();
    zoomToLatLngBound();
    getPolyline();
    listenToDriverLocation();
  }

  dispose() {
    super.dispose();
    driverLocationPollingTimer?.cancel();
  }

  //
  zoomToLatLngBound() {
    if (driverLatLng == null || destinationLatLng == null) {
      return;
    }
    LatLngBounds bound = boundsFromLatLngList([
      driverLatLng!,
      destinationLatLng!,
    ]);

    //
    controller?.animateCamera(CameraUpdate.newLatLngBounds(bound, 80));
  }

  //
  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0;
    double? x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0.00)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0.00)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? 0.00)) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1 ?? 0.00, y1 ?? 0.00),
      southwest: LatLng(x0 ?? 0.00, y0 ?? 0.00),
    );
  }

  //
  void getPolyline() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      AppStrings.googleMapApiKey,
      PointLatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
      PointLatLng(destinationLatLng!.latitude, destinationLatLng!.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    //
    addPolyLine(polylineCoordinates);
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      color: AppColor.primaryColor,
      polylineId: id,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    notifyListeners();
  }

  // Poll the Laravel API because MySQL is the source of truth for driver
  // locations on shared hosting. This mirrors the stable taxi flow.
  void listenToDriverLocation() {
    if (order.driverId == null) return;
    driverLocationPollingTimer?.cancel();
    _refreshDriverLocation();
    driverLocationPollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshDriverLocation(),
    );
  }

  Future<void> _refreshDriverLocation() async {
    try {
      final response = await OrderRequest().syncDriverLocation(order.id);
      if (response.body is! Map || response.body['location'] is! Map) return;
      final location = DriverLocation.fromJson(response.body['location']);
      if (!location.isValid) return;

      driverLatLng = LatLng(location.latitude, location.longitude);
      var driverMarker = mapMarkers!.firstOrNullWhere(
        (marker) => marker.markerId.value == 'driverLocation',
      );
      if (driverMarker == null) {
        driverMarker = Marker(
          markerId: const MarkerId('driverLocation'),
          position: driverLatLng!,
          infoWindow: InfoWindow.noText,
          rotation: location.rotation,
          icon: await markerIcon(AppImages.deliveryBoy),
        );
      } else {
        mapMarkers!.remove(driverMarker);
        driverMarker = driverMarker.copyWith(
          positionParam: driverLatLng,
          rotationParam: location.rotation,
        );
      }
      mapMarkers!.add(driverMarker);
      notifyListeners();
      zoomToLatLngBound();
    } catch (_) {
      // The driver may not have sent the first location yet. Keep polling.
    }
  }

  //
  Future<BitmapDescriptor> markerIcon(String assetPath) async {
    return await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1.1, size: Size(24, 24)),
      assetPath,
    );
  }

  void callDriver() {
    launchUrlString("tel:${order.driver?.phone}");
  }
}
