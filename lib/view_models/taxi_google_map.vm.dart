import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/services/geocoder.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/requests/taxi.request.dart';
import 'package:chaskiy/utils/map.utils.dart';
import 'package:chaskiy/view_models/checkout_base.vm.dart';
import 'package:chaskiy/views/pages/delivery_address/widgets/address_search.view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
// import 'package:geocoder/geocoder.dart';

class TaxiGoogleMapViewModel extends CheckoutBaseViewModel {
  //
  int currentOrderStep = 1;
  int currentAddressSelectionStep = 1;
  bool onTrip = false;
  bool ignoreMapInteraction = false;

  //MAp related variables
  // Nunca iniciar en (0, 0): mientras llega el GPS mostramos Ecuador.
  static const LatLng ecuadorFallback = LatLng(-0.180653, -78.467834);
  CameraPosition mapCameraPosition = const CameraPosition(
    target: ecuadorFallback,
    zoom: 12,
  );
  GoogleMapController? googleMapController;
  String? mapStyle;
  EdgeInsets googleMapPadding = EdgeInsets.all(10);
  StreamSubscription? currentLocationListener;
  // this will hold the generated polylines
  Set<Polyline> gMapPolylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  Set<Marker> gMapMarkers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  StreamSubscription? driverLocationStream;
  Timer? nearbyDriversTimer;
  bool _loadingNearbyDrivers = false;
  // for my custom icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? nearbyDriverIcon;
  int? nearbyVehicleTypeId;
  //END MAP RELATED VARIABLES

  //step 1
  TextEditingController placeSearchTEC = TextEditingController();
  TextEditingController pickupLocationTEC = TextEditingController();
  FocusNode pickupLocationFocusNode = FocusNode();
  DeliveryAddress? pickupLocation;
  TextEditingController dropoffLocationTEC = TextEditingController();
  FocusNode dropoffLocationFocusNode = FocusNode();
  DeliveryAddress? dropoffLocation;

  //
  dispose() {
    super.dispose();
    currentLocationListener?.cancel();
    nearbyDriversTimer?.cancel();
    pickupLocationFocusNode.dispose();
    dropoffLocationFocusNode.dispose();
  }

  void setCurrentStep(int step) {
    currentOrderStep = step;
    onTrip = false;
    notifyListeners();
  }

  //MAP RELATED FUNCTIONS
  void updateGoogleMapPadding({required double height}) {
    googleMapPadding = EdgeInsets.only(bottom: height - 20);
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    setGoogleMapStyle();
    //start listening to user current location
    startUserLocationListener();
    setSourceAndDestinationIcons();
    startNearbyDriversListener();
  }

  void startNearbyDriversListener() {
    nearbyDriversTimer?.cancel();
    loadNearbyDrivers();
    nearbyDriversTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => loadNearbyDrivers(),
    );
  }

  Future<void> loadNearbyDrivers() async {
    if (_loadingNearbyDrivers || onTrip || currentOrderStep > 2) return;
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return;
    _loadingNearbyDrivers = true;
    try {
      final drivers = await TaxiRequest().getNearbyDrivers(
        latitude: position.latitude,
        longitude: position.longitude,
        vehicleTypeId: nearbyVehicleTypeId,
      );
      gMapMarkers.removeWhere(
        (marker) => marker.markerId.value.startsWith('nearbyDriver_'),
      );
      for (final driver in drivers) {
        final lat = double.tryParse('${driver['latitude']}');
        final lng = double.tryParse('${driver['longitude']}');
        if (lat == null || lng == null) continue;
        gMapMarkers.add(
          Marker(
            markerId: MarkerId('nearbyDriver_${driver['id']}'),
            position: LatLng(lat, lng),
            icon:
                nearbyDriverIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
            flat: true,
          ),
        );
      }
      notifyListeners();
    } catch (_) {
      // La oferta visual es complementaria y no debe bloquear la reserva.
    } finally {
      _loadingNearbyDrivers = false;
    }
  }

  //
  void setGoogleMapStyle() async {
    if (mapStyle != null) return;
    try {
      mapStyle = await DefaultAssetBundle.of(
        viewContext,
      ).loadString('assets/json/google_map_style.json');
      notifyListeners();
    } catch (_) {
      // El mapa nativo sigue funcionando si el estilo no está disponible.
    }
  }

  //
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.pickupLocation,
    );
    //
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.dropoffLocation,
    );
    //
    driverIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.driverCar,
    );
    nearbyDriverIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      AppImages.driverCar,
      width: 38,
      height: 38,
    );
  }

  //
  updateDriverIconDynamically(VehicleType vehicleType) async {
    Uint8List? iconByteData = await MapUtils.imageToUint8List(
      base64String: vehicleType.iconBase64,
      url: vehicleType.icon,
      targetWidth: 72,
    );
    if (iconByteData != null) {
      driverIcon = await BitmapDescriptor.fromBytes(iconByteData);
    }
  }

  //
  void startUserLocationListener() async {
    await LocationService.prepareLocationListener();
    await zoomToCurrentLocation();
    await currentLocationListener?.cancel();
    currentLocationListener = LocationService.currenctAddressSubject.listen((
      currentAddress,
    ) {
      if (!onTrip) {
        final latitude = currentAddress.coordinates?.latitude;
        final longitude = currentAddress.coordinates?.longitude;
        if (latitude == null ||
            longitude == null ||
            (latitude == 0 && longitude == 0)) {
          return;
        }
        zoomToLocation(LatLng(latitude, longitude));
      }
    });
  }

  //zoom to provided location
  void zoomToLocation(LatLng target, {double zoom = 16}) {
    if (target.latitude == 0 && target.longitude == 0) return;
    mapCameraPosition = CameraPosition(target: target, zoom: zoom);
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(mapCameraPosition),
    );
  }

  openLocationSelector(int step, {bool showpicker = true}) async {
    //open address picker
    if (showpicker) {
      await openLocationPicker();
    }
    // currentAddressSelectionStep = step;
    //
    if (currentAddressSelectionStep == 1) {
      pickupLocation = checkout?.deliveryAddress;
      pickupLocationTEC.text = checkout?.deliveryAddress?.address ?? "";
    } else {
      dropoffLocation = checkout?.deliveryAddress;
      dropoffLocationTEC.text = checkout?.deliveryAddress?.address ?? "";
    }

    //
    notifyListeners();
  }

  //
  openLocationPicker() async {
    //
    deliveryAddress = DeliveryAddress();
    checkout?.deliveryAddress = null;
    //
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return AddressSearchView(
          this,
          addressSelected: (dynamic prediction) async {
            if (prediction is Prediction) {
              deliveryAddress?.address = prediction.description;
              deliveryAddress?.latitude = prediction.lat?.toDoubleOrNull();
              deliveryAddress?.longitude = prediction.lng?.toDoubleOrNull();
              //
              checkout!.deliveryAddress = deliveryAddress;
              //
              setBusy(true);
              await getLocationCityName(deliveryAddress!);
              setBusy(false);
            } else if (prediction is Address) {
              deliveryAddress?.address = prediction.addressLine;
              deliveryAddress?.latitude = prediction.coordinates?.latitude;
              deliveryAddress?.longitude = prediction.coordinates?.longitude;
              deliveryAddress?.city = prediction.locality;
              deliveryAddress?.state = prediction.adminArea;
              deliveryAddress?.country = prediction.countryName;
              checkout!.deliveryAddress = deliveryAddress;
            }
          },
          selectOnMap: this.showDeliveryAddressPicker,
        );
      },
    );
  }

  //
  Future<DeliveryAddress> showDeliveryAddressPicker() async {
    //
    dynamic result = await newPlacePicker();

    if (result is PickResult) {
      PickResult locationResult = result;
      deliveryAddress = DeliveryAddress();
      deliveryAddress!.address = locationResult.formattedAddress;
      deliveryAddress!.latitude = locationResult.geometry?.location.lat;
      deliveryAddress!.longitude = locationResult.geometry?.location.lng;
      checkout!.deliveryAddress = deliveryAddress;

      if (locationResult.addressComponents != null &&
          locationResult.addressComponents!.isNotEmpty) {
        //fetch city, state and country from address components
        locationResult.addressComponents!.forEach((addressComponent) {
          if (addressComponent.types.contains("locality")) {
            deliveryAddress!.city = addressComponent.longName;
          }
          if (addressComponent.types.contains("administrative_area_level_1")) {
            deliveryAddress!.state = addressComponent.longName;
          }
          if (addressComponent.types.contains("country")) {
            deliveryAddress!.country = addressComponent.longName;
          }
        });
      } else {
        // From coordinates
        setBusy(true);
        deliveryAddress = await getLocationCityName(deliveryAddress!);
        setBusy(false);
      }
      openLocationSelector(currentAddressSelectionStep, showpicker: false);
    } else if (result is Address) {
      Address locationResult = result;
      deliveryAddress = DeliveryAddress();
      deliveryAddress?.address = locationResult.addressLine;
      deliveryAddress?.latitude = locationResult.coordinates?.latitude;
      deliveryAddress?.longitude = locationResult.coordinates?.longitude;
      deliveryAddress?.city = locationResult.locality;
      deliveryAddress?.state = locationResult.adminArea;
      deliveryAddress?.country = locationResult.countryName;
      checkout!.deliveryAddress = deliveryAddress;
      //
      openLocationSelector(currentAddressSelectionStep, showpicker: false);
    }
    //

    return deliveryAddress ?? DeliveryAddress();
  }

  //setupCurrentLocationAsPickuplocation()
  Future<void> setupCurrentLocationAsPickuplocation() async {
    final cachedAddress = LocationService.currenctAddress;
    final cachedLatitude = cachedAddress?.coordinates?.latitude;
    final cachedLongitude = cachedAddress?.coordinates?.longitude;
    if (_validCoordinates(cachedLatitude, cachedLongitude)) {
      _setPickupLocation(
        latitude: cachedLatitude!,
        longitude: cachedLongitude!,
        address: cachedAddress?.addressLine,
        name: cachedAddress?.featureName,
      );
      return;
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await _restorePickupLocation();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _restorePickupLocation();
        return;
      }

      Position currentLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      // Preserve the valid GPS position even when reverse geocoding fails.
      _setPickupLocation(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );

      try {
        final addresses = await GeocoderService().findAddressesFromCoordinates(
          Coordinates(currentLocation.latitude, currentLocation.longitude),
        );
        if (addresses.isNotEmpty) {
          final address = addresses.first;
          _setPickupLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            address: address.addressLine,
            name: address.featureName,
          );
        }
      } catch (_) {
        // The coordinates already provide a valid pickup point.
      }
    } catch (_) {
      await _restorePickupLocation();
    }
  }

  bool _validCoordinates(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        !(latitude == 0 && longitude == 0);
  }

  void _setPickupLocation({
    required double latitude,
    required double longitude,
    String? address,
    String? name,
  }) {
    final label = address?.trim();
    pickupLocation = DeliveryAddress(
      name: name?.trim().isNotEmpty == true ? name : 'Ubicación actual',
      address: label?.isNotEmpty == true ? label : 'Ubicación actual',
      latitude: latitude,
      longitude: longitude,
    );
    pickupLocationTEC.text = pickupLocation!.address!;
    notifyListeners();
  }

  Future<void> _restorePickupLocation() async {
    final saved = await LocationService.restoreSelectedAddress();
    if (_validCoordinates(saved?.latitude, saved?.longitude)) {
      _setPickupLocation(
        latitude: saved!.latitude!,
        longitude: saved.longitude!,
        address: saved.address,
        name: saved.name,
      );
    }
  }

  //plylines
  drawTripPolyLines() async {
    if (pickupLocation == null || dropoffLocation == null) {
      return;
    }

    //
    if (pickupLocation!.latitude == null || pickupLocation!.longitude == null) {
      return;
    }
    // source pin
    gMapMarkers = {};
    gMapMarkers.add(
      Marker(
        markerId: MarkerId('sourcePin'),
        position: LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        icon:
            sourceIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: Offset(0.5, 0.5),
      ),
    );

    //
    if (dropoffLocation!.latitude == null ||
        dropoffLocation!.longitude == null) {
      return;
    }
    // destination pin
    gMapMarkers.add(
      Marker(
        markerId: MarkerId('destPin'),
        position: LatLng(
          dropoffLocation!.latitude!,
          dropoffLocation!.longitude!,
        ),
        icon:
            destinationIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: Offset(0.5, 0.5),
      ),
    );
    //load the ploylines
    polylineCoordinates.clear();
    PolylineResult? polylineResult;
    try {
      polylineResult = await polylinePoints.getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        PointLatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
      );
    } catch (_) {
      polylineResult = null;
    }
    //get the points from the result
    List<PointLatLng> result = polylineResult?.points ?? const [];
    if (result.isEmpty) {
      result = await _getRoutePointsFromRoutesApi();
    }
    //
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      // La Directions API heredada puede estar deshabilitada. Nunca dejamos
      // el viaje sin representación visual: mostramos origen y destino unidos.
      polylineCoordinates.addAll([
        LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        LatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
      ]);
    }

    // with an id, an RGB color and the list of LatLng pairs
    Polyline polyline = Polyline(
      polylineId: PolylineId("poly"),
      color: AppColor.primaryColor,
      points: polylineCoordinates,
      width: 3,
    );
    //
    gMapPolylines = {};
    gMapPolylines.add(polyline);

    //
    //zoom to latbound
    final pickupLocationLatLng = LatLng(
      pickupLocation!.latitude!,
      pickupLocation!.longitude!,
    );
    final dropoffLocationLatLng = LatLng(
      dropoffLocation!.latitude!,
      dropoffLocation!.longitude!,
    );

    await updateCameraLocation(
      pickupLocationLatLng,
      dropoffLocationLatLng,
      googleMapController,
    );
    //
    notifyListeners();
  }

  Future<List<PointLatLng>> _getRoutePointsFromRoutesApi() async {
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
                    'latitude': pickupLocation!.latitude,
                    'longitude': pickupLocation!.longitude,
                  },
                },
              },
              'destination': {
                'location': {
                  'latLng': {
                    'latitude': dropoffLocation!.latitude,
                    'longitude': dropoffLocation!.longitude,
                  },
                },
              },
              'travelMode': 'DRIVE',
              'routingPreference': 'TRAFFIC_AWARE',
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = body['routes'];
      if (routes is! List || routes.isEmpty) return const [];
      final polyline = routes.first['polyline'];
      if (polyline is! Map) return const [];
      final encoded = polyline['encodedPolyline']?.toString();
      if (encoded == null || encoded.isEmpty) return const [];
      return polylinePoints.decodePolyline(encoded);
    } catch (_) {
      return const [];
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
    CameraUpdate cameraUpdate,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) {
      return;
    }
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  Future<void> zoomToCurrentLocation() async {
    try {
      Position? currentLocation = await Geolocator.getLastKnownPosition();
      currentLocation ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      zoomToLocation(
        LatLng(currentLocation.latitude, currentLocation.longitude),
      );
    } catch (_) {
      zoomToLocation(ecuadorFallback, zoom: 12);
    }
  }

  //
  clearMapData() {
    gMapMarkers.clear();
    gMapMarkers = {};
    polylineCoordinates.clear();
    gMapPolylines.clear();
    pickupLocationTEC.clear();
    dropoffLocationTEC.clear();
    notifyListeners();
    driverLocationStream?.cancel();
    //
    setupCurrentLocationAsPickuplocation();
  }
}
