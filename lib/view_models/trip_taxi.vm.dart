import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/requests/payment_method.request.dart';
import 'package:chaskiy/requests/taxi.request.dart';
import 'package:chaskiy/view_models/taxi_google_map.vm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class TripTaxiViewModel extends TaxiGoogleMapViewModel {
  //requests
  TaxiRequest taxiRequest = TaxiRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
  //
  Order? onGoingOrderTrip;
  //código del último viaje del que ya se avisó que terminó, para no repetir
  String? notifiedEndedTripCode;
  double newTripRating = 3.0;
  TextEditingController tripReviewTEC = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? tripUpdateStream;
  Timer? tripPollingTimer;
  Timer? driverLocationPollingTimer;
  Timer? _driverMarkerAnimationTimer;
  bool _refreshingTrip = false;
  bool _refreshingDriverLocation = false;
  bool _driverCameraInitialized = false;

  LatLng? driverPosition;
  double driverPositionRotation = 0;

  //
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;

  //vheicle types
  List<VehicleType> vehicleTypes = [];
  VehicleType? selectedVehicleType;
  int? possibleDriverETA;

  @override
  dispose() {
    tripUpdateStream?.cancel();
    tripPollingTimer?.cancel();
    driverLocationPollingTimer?.cancel();
    _driverMarkerAnimationTimer?.cancel();
    driverLocationStream?.cancel();
    super.dispose();
  }

  //get current on going trip
  getOnGoingTrip() async {
    //
    setBusyForObject(onGoingOrderTrip, true);
    try {
      onGoingOrderTrip = await taxiRequest.getOnGoingTrip();
      loadTripUIByOrderStatus(initial: true);
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  //cancel trip
  void cancelTrip() async {
    final trip = onGoingOrderTrip;
    if (trip == null) {
      await _synchronizeTripAfterCancellation();
      return;
    }

    setBusyForObject(trip, true);
    try {
      final apiResponse = await taxiRequest.cancelTrip(trip.id);
      final tripEnded =
          apiResponse.body is Map && apiResponse.body['trip_ended'] == true;

      if (apiResponse.allGood || tripEnded) {
        notifiedEndedTripCode = trip.code;
        _clearFinishedTrip();
        toastSuccessful(
          apiResponse.message ?? "Viaje cancelado correctamente".tr(),
        );
      } else {
        final stillActive = await _synchronizeTripAfterCancellation();
        if (stillActive) {
          toastError(
            apiResponse.message ?? "No se pudo cancelar el viaje".tr(),
          );
        }
      }
    } catch (error) {
      print("trip ongoing error ==> $error");
      final stillActive = await _synchronizeTripAfterCancellation();
      if (stillActive) {
        toastError("No se pudo cancelar el viaje".tr());
      }
    } finally {
      setBusyForObject(trip, false);
    }
  }

  Future<bool> _synchronizeTripAfterCancellation() async {
    try {
      final serverTrip = await taxiRequest.getOnGoingTrip();
      if (serverTrip == null || !serverTrip.isOngoing) {
        _clearFinishedTrip();
        return false;
      }

      onGoingOrderTrip = serverTrip;
      loadTripUIByOrderStatus();
      notifyListeners();
      return true;
    } catch (_) {
      // Conservatively keep the trip visible when the server cannot be
      // reached. The normal polling loop will reconcile it on the next pass.
      return onGoingOrderTrip?.isOngoing ?? false;
    }
  }

  void _clearFinishedTrip() {
    onGoingOrderTrip = null;
    setCurrentStep(1);
    clearMapData();
    stopAllListeners();
    closeOrderSummary();
    notifyListeners();
  }

  Future<void> changeTripDestination() async {
    final trip = onGoingOrderTrip;
    final previousDestination = dropoffLocation;
    if (trip == null || previousDestination == null) return;

    final destination = await showDeliveryAddressPicker();
    if (destination.latitude == null ||
        destination.longitude == null ||
        (destination.address ?? '').trim().isEmpty) {
      dropoffLocation = previousDestination;
      checkout?.deliveryAddress = previousDestination;
      return;
    }

    final confirmed = await showDialog<bool>(
      context: viewContext,
      builder:
          (context) => AlertDialog(
            title: Text('Cambiar destino'.tr()),
            content: Text(
              '${destination.address}\n\nLa ruta y la tarifa se recalcularán antes de continuar.'
                  .tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Volver'.tr()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Confirmar destino'.tr()),
              ),
            ],
          ),
    );
    if (confirmed != true) {
      dropoffLocation = previousDestination;
      checkout?.deliveryAddress = previousDestination;
      return;
    }

    setBusyForObject(trip, true);
    try {
      final response = await taxiRequest.updateDestination(
        trip.id,
        destination,
      );
      if (!response.allGood || response.body is! Map) {
        throw response.message ?? 'No se pudo cambiar el destino'.tr();
      }
      final source = response.body['order'];
      if (source is! Map) {
        throw 'El servidor no devolvió el viaje actualizado'.tr();
      }
      onGoingOrderTrip = Order.fromJson(Map<String, dynamic>.from(source));
      dropoffLocation = DeliveryAddress(
        address: onGoingOrderTrip?.taxiOrder?.dropoffAddress,
        latitude: onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull(),
      );
      checkout?.deliveryAddress = dropoffLocation;
      await drawTripPolyLines();
      toastSuccessful(
        response.message ??
            'Destino actualizado. La ruta y la tarifa fueron recalculadas.'
                .tr(),
      );
      notifyListeners();
    } catch (error) {
      dropoffLocation = previousDestination;
      checkout?.deliveryAddress = previousDestination;
      toastError(error.toString());
    } finally {
      setBusyForObject(trip, false);
    }
  }

  //
  loadTripUIByOrderStatus({bool initial = false}) {
    //
    //
    if ((initial)) {
      //
      pickupLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.pickupLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.pickupLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.pickupAddress,
      );
      //
      dropoffLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.dropoffAddress,
      );
      //set the pickup and drop off locations
      drawTripPolyLines();
      startHandlingOnGoingTrip();
    } else if (onGoingOrderTrip != null) {
      switch (onGoingOrderTrip?.status) {
        case "pending":
          setCurrentStep(3);
          break;
        case "preparing":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "ready":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "enroute":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "delivered":
          setCurrentStep(1);
          clearMapData();
          zoomToLocation(
            LatLng(
              onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull() ??
                  0.0,
              onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull() ??
                  0.0,
            ),
          );
          stopAllListeners();
          //check for last trip that requires rating
          setCurrentStep(6);
          break;
        case "failed":
          //antes el viaje se cerraba sin decir nada y parecía que la app falló
          notifyTripEnded("failed");
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
        case "cancelled":
          notifyTripEnded("cancelled");
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
        default:
      }
    }

    //
    if (onGoingOrderTrip == null) {
      setCurrentStep(1);
      clearMapData();
      stopAllListeners();
      closeOrderSummary();
      //check for last trip that requires rating
      setCurrentStep(6);
    }
  }

  //avisa una sola vez que el viaje terminó sin llegar a completarse
  void notifyTripEnded(String status) {
    final tripCode = onGoingOrderTrip?.code;
    if (tripCode == null || notifiedEndedTripCode == tripCode) {
      return;
    }
    notifiedEndedTripCode = tripCode;
    toastError(
      status == "cancelled"
          ? "El viaje fue cancelado".tr()
          : "No se pudo completar el viaje".tr(),
    );
  }

  //
  void startHandlingOnGoingTrip() async {
    //
    if (onGoingOrderTrip == null || onGoingOrderTrip!.isScheduled) {
      setCurrentStep(1);
      return;
    }
    //clear current UI step
    setCurrentStep(3);
    //foudz
    loadTripUIByOrderStatus();
    _startTripPolling();
    if (onGoingOrderTrip?.driverId != null) {
      startDriverDetailsListener();
    }

    //
    tripUpdateStream = firebaseFirestore
        .collection("orders")
        .doc("${onGoingOrderTrip?.code}")
        .snapshots()
        .listen((event) async {
          //once driver is assigned

          final driverId =
              event.data() != null ? event.data()!["driver_id"] ?? null : null;
          if (driverId != null && onGoingOrderTrip?.driverId == null) {
            onGoingOrderTrip?.driverId = event.data()!["driver_id"];
            onGoingOrderTrip?.driver = event.data()!["driver"] ?? null;
          }

          //
          if (onGoingOrderTrip?.driver == null) {
            await loadDriverDetails();
          }
          startDriverDetailsListener();

          //update the rest onGoingTrip details
          if (event.exists) {
            onGoingOrderTrip?.status = event.data()?["status"] ?? "failed";
          }
          //
          notifyListeners();
          loadTripUIByOrderStatus();
        });
    //start order details listening stream
  }

  void _startTripPolling() {
    tripPollingTimer?.cancel();
    _refreshTripFromApi();
    tripPollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshTripFromApi(),
    );
  }

  Future<void> _refreshTripFromApi() async {
    if (_refreshingTrip || onGoingOrderTrip == null) return;
    _refreshingTrip = true;
    try {
      final previousDriverId = onGoingOrderTrip?.driverId;
      final previousStatus = onGoingOrderTrip?.status;
      final refreshedTrip = await taxiRequest.getOnGoingTrip();
      if (refreshedTrip == null) {
        // El endpoint de viaje activo deja de devolver la orden apenas el
        // conductor la completa. Esa respuesta es una transición real, no un
        // error: debe abrir la calificación en lugar de dejar la vista vieja.
        onGoingOrderTrip = null;
        loadTripUIByOrderStatus();
        return;
      }
      onGoingOrderTrip = refreshedTrip;
      final driverAssigned =
          previousDriverId == null && refreshedTrip.driverId != null;
      final statusChanged = previousStatus != refreshedTrip.status;
      if (driverAssigned) startDriverDetailsListener();
      if (driverAssigned || statusChanged) {
        loadTripUIByOrderStatus();
      }
      notifyListeners();
    } catch (_) {
      // The next interval retries. Firestore remains an optional fast hint.
    } finally {
      _refreshingTrip = false;
    }
  }

  //DRIVER SECTION
  loadDriverDetails() async {
    try {
      final mDriverId = onGoingOrderTrip?.driverId;
      //aún no hay conductor asignado: no hay detalles que cargar
      if (mDriverId == null) {
        return;
      }
      final refreshedTrip = await taxiRequest.getOnGoingTrip();
      //si el servidor todavía no devuelve el viaje, se conserva el que ya
      //teníamos; dejarlo en null cerraba la búsqueda de conductor sin avisar
      if (refreshedTrip != null) {
        onGoingOrderTrip = refreshedTrip;
      }
      //loop until driver data is gotten
      if (onGoingOrderTrip?.driver == null) {
        onGoingOrderTrip?.driver = await taxiRequest.getDriverInfo(mDriverId);
        if (onGoingOrderTrip?.driver == null) {
          await Future.delayed(Duration(seconds: 5));
          loadDriverDetails();
        }
      }
      notifyListeners();
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
  }

  //Start listening to driver location changes
  void startDriverDetailsListener() async {
    //sin conductor asignado no hay ubicación que seguir
    if (onGoingOrderTrip?.driverId == null) {
      return;
    }
    driverLocationPollingTimer?.cancel();
    _refreshDriverLocationFromApi();
    driverLocationPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _refreshDriverLocationFromApi(),
    );
  }

  Future<void> _refreshDriverLocationFromApi() async {
    final orderId = onGoingOrderTrip?.id;
    if (orderId == null || _refreshingDriverLocation) return;
    _refreshingDriverLocation = true;
    try {
      final response = await OrderRequest().syncDriverLocation(orderId);
      if (response.body is! Map) return;
      final location = response.body['location'];
      if (location is! Map) return;
      final lat = double.tryParse('${location['lat']}');
      final lng = double.tryParse('${location['lng']}');
      if (lat == null || lng == null) return;
      final nextPosition = LatLng(lat, lng);
      final nextRotation = double.tryParse('${location['rotation']}') ?? 0;
      await _animateDriverMarker(nextPosition, nextRotation);
      if (!_driverCameraInitialized) {
        _driverCameraInitialized = true;
        await startZoomFocusDriver();
      }
    } catch (_) {
      // The driver may not have published the first location yet.
    } finally {
      _refreshingDriverLocation = false;
    }
  }

  Future<void> _animateDriverMarker(
    LatLng nextPosition,
    double nextRotation,
  ) async {
    final previous = driverPosition;
    _driverMarkerAnimationTimer?.cancel();
    if (previous == null) {
      driverPosition = nextPosition;
      driverPositionRotation = nextRotation;
      updateDriverMarkerPosition();
      return;
    }

    const steps = 12;
    var step = 0;
    final startRotation = driverPositionRotation;
    _driverMarkerAnimationTimer = Timer.periodic(
      const Duration(milliseconds: 80),
      (timer) {
        step++;
        final progress = step / steps;
        driverPosition = LatLng(
          previous.latitude +
              (nextPosition.latitude - previous.latitude) * progress,
          previous.longitude +
              (nextPosition.longitude - previous.longitude) * progress,
        );
        driverPositionRotation =
            startRotation + (nextRotation - startRotation) * progress;
        updateDriverMarkerPosition();
        if (step >= steps) timer.cancel();
      },
    );
  }

  stopDriverListener() async {
    driverLocationStream?.cancel();
    driverLocationPollingTimer?.cancel();
    _driverMarkerAnimationTimer?.cancel();
    driverLocationPollingTimer = null;
    driverLocationStream = null;
    notifyListeners();
  }

  //
  updateDriverMarkerPosition() {
    //
    Marker? driverMarker = gMapMarkers.firstOrNullWhere(
      (e) => e.markerId.value == "driverMarker",
    );
    //
    if (driverMarker == null) {
      driverMarker = Marker(
        markerId: MarkerId('driverMarker'),
        position: driverPosition!,
        rotation: driverPositionRotation,
        icon: driverIcon!,
        anchor: Offset(0.5, 0.5),
      );
      gMapMarkers.add(driverMarker);
    } else {
      driverMarker = driverMarker.copyWith(
        positionParam: driverPosition,
        rotationParam: driverPositionRotation,
        iconParam: driverIcon!,
      );
      gMapMarkers.removeWhere((e) => e.markerId.value == "driverMarker");
      gMapMarkers.add(driverMarker);
    }

    notifyListeners();
  }

  //
  startZoomFocusDriver() async {
    //create bond between driver and
    if (driverPosition == null) {
      return;
    }

    if (onGoingOrderTrip == null) {
      return;
    }

    //check status to determine the latlng bound
    if (onGoingOrderTrip!.canZoomOnPickupLocation) {
      //zoom to driver and pickup latbound
      updateCameraLocation(
        driverPosition!,
        LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        googleMapController,
      );
    } else if (onGoingOrderTrip!.canZoomOnDropoffLocation) {
      //zoom to driver and dropoff latbound
      updateCameraLocation(
        driverPosition!,
        LatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
        googleMapController,
      );
    }

    //
    await updateDriverIconDynamically(onGoingOrderTrip!.taxiOrder!.vehicleType);
    updateDriverMarkerPosition();
  }

  /// El botón del mapa sigue al vehículo durante un viaje; fuera del viaje
  /// conserva el comportamiento habitual de volver a la ubicación del usuario.
  Future<void> focusMapSubject() async {
    if (onGoingOrderTrip != null && driverPosition != null) {
      await startZoomFocusDriver();
      return;
    }
    await zoomToCurrentLocation();
  }

  //
  stopAllListeners() async {
    tripUpdateStream?.cancel();
    tripPollingTimer?.cancel();
    tripPollingTimer = null;
    driverLocationPollingTimer?.cancel();
    _driverMarkerAnimationTimer?.cancel();
    driverLocationPollingTimer = null;
    _driverCameraInitialized = false;
    driverLocationStream?.cancel();

    //when trip is ended
    selectedVehicleType = null;
    selectedPaymentMethod = paymentMethods.firstOrNull;
    possibleDriverETA = null;

    notifyListeners();
  }

  //when trip is ended
  dismissTripRating() async {
    tripReviewTEC.clear();
    setCurrentStep(1);
    zoomToCurrentLocation();
  }

  submitTripRating(Order order) async {
    //
    setBusyForObject(newTripRating, true);
    //
    final apiResponse = await taxiRequest.rateDriver(
      order.id,
      order.driverId!,
      newTripRating,
      tripReviewTEC.text,
    );
    //
    if (apiResponse.allGood) {
      toastSuccessful(
        apiResponse.message ?? "Viaje calificado correctamente".tr(),
      );
      dismissTripRating();
    } else {
      toastError(apiResponse.message ?? "No se pudo calificar el viaje".tr());
    }
    setBusyForObject(newTripRating, false);
  }

  closeOrderSummary({bool clear = true}) {
    if (clear) {
      pickupLocation = null;
      dropoffLocation = null;
      pickupLocationTEC.clear();
      dropoffLocationTEC.clear();
      selectedVehicleType = null;
      selectedPaymentMethod = paymentMethods.firstOrNull;
      possibleDriverETA = null;
      notifyListeners();
    }
    //
    selectedVehicleType = null;
    clearMapData();
    setCurrentStep(1);
  }
}
