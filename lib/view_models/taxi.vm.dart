import 'dart:async';

import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/checkout.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/models/coupon.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/cart.request.dart';
import 'package:chaskiy/requests/payment_method.request.dart';
import 'package:chaskiy/requests/taxi.request.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/services/active_taxi_trip.service.dart';
import 'package:chaskiy/services/chat.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/services/trip.service.dart';
import 'package:chaskiy/services/taxi_trip_share.service.dart';
import 'package:chaskiy/view_models/trip_taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiViewModel extends TripTaxiViewModel {
  //
  TaxiViewModel(BuildContext context, this.vendorType, {Order? initialOrder}) {
    this.viewContext = context;
    if (initialOrder != null &&
        initialOrder.isTaxi &&
        initialOrder.isOngoing &&
        !initialOrder.isScheduled) {
      onGoingOrderTrip = initialOrder;
    }
  }

  //requests
  CartRequest cartRequest = CartRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
  //

  VendorType? vendorType;
  //coupons
  bool canApplyCoupon = false;
  bool canScheduleTaxiOrder = false;
  Coupon? coupon;
  TextEditingController couponTEC = TextEditingController();
  bool vehicleTypesLoadFailed = false;
  int _vehiclePricingRevision = 0;
  bool get loadingVehicleTypes => busy('vehicleTypePricing');
  String preferredVehicleKind = 'car';
  int? preferredVehicleTypeId;
  bool showAllVehicleOptions = false;
  List<VehicleType> configuredVehicleTypes = [];
  bool configuredVehicleTypesLoadFailed = false;
  Future<void>? _configuredVehicleTypesRequest;

  //
  CheckOut? checkout = CheckOut();
  double subTotal = 0.0;
  double total = 0.0;
  double tip = 0.0;

  //functions
  void initialise() async {
    unawaited(fetchConfiguredVehicleTypes());
    await fetchTaxiPaymentOptions();
    if (onGoingOrderTrip != null) {
      await ActiveTaxiTripService.save(onGoingOrderTrip);
      loadTripUIByOrderStatus(initial: true);
    } else {
      await restoreCachedOnGoingTrip();
    }
    await getOnGoingTrip();
    if (!onTrip) {
      await setupCurrentLocationAsPickuplocation();
    }
  }

  //
  bool currentStep(int step) {
    return step == currentOrderStep;
  }

  isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethod?.id;
  }

  couponCodeChange(String code) {
    canApplyCoupon = code.isNotBlank;
    notifyListeners();
  }

  toggleScheduleTaxiOrder(bool enabled) {
    if (!enabled) {
      checkout?.pickupDate = null;
      checkout?.pickupTime = null;
    }

    canScheduleTaxiOrder = enabled;
    notifyListeners();
  }

  //
  applyCoupon() async {
    //
    setBusyForObject("coupon", true);
    try {
      coupon = await cartRequest.fetchCoupon(
        couponTEC.text,
        vendorTypeId: vendorType?.id,
      );
      if (coupon == null) {
        throw "Coupon not found".tr();
      }
      //
      if (coupon!.useLeft <= 0) {
        coupon = null;
        throw "Coupon use limit exceeded".tr();
      } else if (coupon!.expired) {
        coupon = null;
        throw "Coupon has expired".tr();
      }
      clearErrors();

      //
      calculateTotalAmount();
    } catch (error) {
      print("error ==> $error");
      setErrorForObject("coupon", error);
    }
    setBusyForObject("coupon", false);
  }

  //after locations has been selected
  proceedToStep2() async {
    //validate user has selected both pickup and drop off location
    final validPickup =
        pickupLocation?.latitude != null && pickupLocation?.longitude != null;
    final validDropoff =
        dropoffLocation?.latitude != null && dropoffLocation?.longitude != null;
    if (!validPickup || !validDropoff) {
      toastError('Selecciona un punto de partida y un destino válidos'.tr());
    } else if (canScheduleTaxiOrder &&
        (checkout!.pickupDate == null || checkout!.pickupTime == null)) {
      toastError("Please select pickup date and pickup time".tr());
    } else {
      checkLocationAvailabilityForStep2();
    }
  }

  //checking if taxi booking is enabled in the given location
  checkLocationAvailabilityForStep2() async {
    setBusy(true);
    try {
      final apiResponse = await taxiRequest.locationAvailable(
        pickupLocation!.latitude!,
        pickupLocation!.longitude!,
      );
      if (apiResponse.allGood) {
        prepareStep2();
      } else if (apiResponse.code != null && apiResponse.code! < 500) {
        setCurrentStep(0);
      } else {
        toastError(apiResponse.message ?? 'No se pudo verificar la cobertura');
      }
    } catch (_) {
      toastError('No se pudo verificar la cobertura. Inténtalo nuevamente.');
    }
    setBusy(false);
  }

  //
  void prepareStep2() {
    setCurrentStep(2);
    drawTripPolyLines();
    fetchVehicleTypes();
  }

  //vehicle types
  fetchVehicleTypes() async {
    final revision = ++_vehiclePricingRevision;
    setBusyForObject('vehicleTypePricing', true);
    vehicleTypesLoadFailed = false;
    vehicleTypes = [];
    selectedVehicleType = null;
    try {
      final options = await taxiRequest.getVehicleTypePricing(
        pickupLocation!,
        dropoffLocation!,
        countryCode: LocationService.currenctAddress?.countryCode,
        stops: List.of(taxiStops),
      );

      if (revision != _vehiclePricingRevision) return;
      vehicleTypes = options;
      final preferredVehicle = _preferredVehicleFrom(vehicleTypes);
      if (preferredVehicle != null) {
        final exactPreferenceAvailable =
            preferredVehicleTypeId != null &&
            vehicleTypes.any((item) => item.id == preferredVehicleTypeId);
        showAllVehicleOptions =
            preferredVehicleTypeId != null && !exactPreferenceAvailable;
        changeSelectedVehicleType(preferredVehicle, rememberSelection: false);
      }
    } catch (error) {
      if (revision != _vehiclePricingRevision) return;
      print("Error getting vehicleTypes ==> $error");
      vehicleTypesLoadFailed = true;
    }
    setBusyForObject('vehicleTypePricing', false);
    notifyListeners();
  }

  Future<void> editTaxiStops() async {
    if (onTrip) return;
    var changed = false;
    void invalidateQuote() {
      changed = true;
      _vehiclePricingRevision++;
      selectedVehicleType = null;
      vehicleTypes = [];
      setBusyForObject('vehicleTypePricing', false);
      notifyListeners();
    }

    await showModalBottomSheet<void>(
      context: viewContext,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder: (context, update) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Paradas intermedias',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text(
                          'Se visitan en este orden, antes del destino final. La tarifa incluye todas las paradas.',
                        ),
                        for (var i = 0; i < taxiStops.length; i++)
                          ListTile(
                            title: Text('${i + 1}. ${taxiStops[i].address}'),
                            trailing: IconButton(
                              tooltip: 'Quitar parada',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                update(() => taxiStops.removeAt(i));
                                invalidateQuote();
                              },
                            ),
                          ),
                        if (taxiStops.length < 10)
                          TextButton.icon(
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text('Añadir parada'),
                            onPressed: () async {
                              final pickup = pickupLocation;
                              final dropoff = dropoffLocation;
                              final previousAddress = deliveryAddress;
                              final previousCheckout =
                                  checkout?.deliveryAddress;
                              final pickupText = pickupLocationTEC.text;
                              final dropoffText = dropoffLocationTEC.text;
                              deliveryAddress = null;
                              DeliveryAddress? stop;
                              try {
                                stop = await showDeliveryAddressPicker();
                              } finally {
                                pickupLocation = pickup;
                                dropoffLocation = dropoff;
                                deliveryAddress = previousAddress;
                                checkout?.deliveryAddress = previousCheckout;
                                pickupLocationTEC.text = pickupText;
                                dropoffLocationTEC.text = dropoffText;
                              }
                              if (!context.mounted ||
                                  stop.latitude == null ||
                                  stop.longitude == null ||
                                  (stop.address ?? '').isEmpty)
                                return;
                              update(() => taxiStops.add(stop!));
                              invalidateQuote();
                            },
                          ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Listo'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
    if (changed && pickupLocation != null && dropoffLocation != null) {
      unawaited(drawTripPolyLines());
      if (currentOrderStep == 2) await fetchVehicleTypes();
    }
  }

  Future<void> selectPreferredVehicleKind(String kind) async {
    preferredVehicleKind = kind;
    preferredVehicleTypeId = null;
    notifyListeners();
    await fetchConfiguredVehicleTypes();
  }

  Future<void> fetchConfiguredVehicleTypes({bool force = false}) async {
    if (configuredVehicleTypes.isNotEmpty && !force) return;
    if (_configuredVehicleTypesRequest != null && !force) {
      return _configuredVehicleTypesRequest;
    }
    final request = _loadConfiguredVehicleTypes();
    _configuredVehicleTypesRequest = request;
    try {
      await request;
    } finally {
      if (identical(_configuredVehicleTypesRequest, request)) {
        _configuredVehicleTypesRequest = null;
      }
    }
  }

  Future<void> _loadConfiguredVehicleTypes() async {
    setBusyForObject('configuredVehicleTypes', true);
    configuredVehicleTypesLoadFailed = false;
    try {
      configuredVehicleTypes = await taxiRequest.getVehicleTypes();
      configuredVehicleTypesLoadFailed = configuredVehicleTypes.isEmpty;
    } catch (_) {
      configuredVehicleTypesLoadFailed = true;
    }
    setBusyForObject('configuredVehicleTypes', false);
    notifyListeners();
  }

  List<VehicleType> configuredTypesFor(String kind) {
    return configuredVehicleTypes
        .where((vehicleType) => vehicleType.vehicleKind == kind)
        .toList();
  }

  void selectPreferredVehicleType(VehicleType vehicleType) {
    preferredVehicleKind = vehicleType.vehicleKind;
    preferredVehicleTypeId = vehicleType.id;
    showAllVehicleOptions = false;
    nearbyVehicleTypeId = vehicleType.id;
    unawaited(updateNearbyDriverIconDynamically(vehicleType));
    loadNearbyDrivers();
    notifyListeners();
  }

  VehicleType? _preferredVehicleFrom(List<VehicleType> availableTypes) {
    if (availableTypes.isEmpty) return null;

    if (preferredVehicleTypeId != null) {
      for (final vehicleType in availableTypes) {
        if (vehicleType.id == preferredVehicleTypeId) return vehicleType;
      }
    }

    for (final vehicleType in availableTypes) {
      if (vehicleType.vehicleKind == preferredVehicleKind) return vehicleType;
    }

    return availableTypes.first;
  }

  resortVehicleTypes() {
    vehicleTypes.removeWhere((e) => e.id == selectedVehicleType?.id);
    vehicleTypes.insert(0, selectedVehicleType!);
  }

  //
  bool get hasConfirmedVehicleChoice =>
      !showAllVehicleOptions &&
      preferredVehicleTypeId != null &&
      selectedVehicleType?.id == preferredVehicleTypeId;

  void revealVehicleOptions() {
    showAllVehicleOptions = true;
    notifyListeners();
  }

  changeSelectedVehicleType(
    VehicleType vehicleType, {
    bool rememberSelection = true,
  }) {
    selectedVehicleType = vehicleType;
    if (rememberSelection) {
      preferredVehicleKind = vehicleType.vehicleKind;
      preferredVehicleTypeId = vehicleType.id;
      showAllVehicleOptions = false;
    }
    nearbyVehicleTypeId = vehicleType.id;
    unawaited(updateNearbyDriverIconDynamically(vehicleType));
    loadNearbyDrivers();
    // resortVehicleTypes();
    calculateTotalAmount();
    //new feature
    generatePossibleDriverETA();
  }

  //
  calculateTotalAmount() {
    //
    subTotal = selectedVehicleType!.total;
    print("subTotal ==> ${subTotal}");
    //
    if (coupon != null) {
      if (coupon!.percentage == 1) {
        checkout!.discount = (coupon!.discount / 100) * subTotal;
      } else {
        checkout!.discount = coupon!.discount;
      }
    } else {
      checkout!.discount = 0;
    }
    print("discount ==> ${checkout!.discount}");
    subTotal = subTotal - (checkout?.discount ?? 0);
    subTotal = subTotal - selectedVehicleType!.tax;
    total = subTotal + (selectedVehicleType?.tax ?? 0);
    print("total ==> ${total}");
    notifyListeners();
  }

  //
  generatePossibleDriverETA() async {
    setBusy(true);
    try {
      possibleDriverETA = await TripService().generatePossibleDriverETA(
        lat: pickupLocation!.latitude!,
        lng: pickupLocation!.longitude!,
        vehicleTypeId: selectedVehicleType?.id,
      );
    } catch (error) {
      print("Error getting possibleDriverETA ==> $error");
    }
    setBusy(false);
  }

  //
  processNewOrder() async {
    //
    final params = {
      "payment_method_id": selectedPaymentMethod?.id,
      "vehicle_type_id": selectedVehicleType?.id,
      "pickup": {
        "lat": pickupLocation!.latitude,
        "lng": pickupLocation!.longitude,
        "address": pickupLocation!.address,
      },
      "dropoff": {
        "lat": dropoffLocation!.latitude,
        "lng": dropoffLocation!.longitude,
        "address": dropoffLocation!.address,
      },
      "stops": [
        for (final stop in taxiStops)
          {
            'lat': stop.latitude,
            'lng': stop.longitude,
            'address': stop.address,
          },
      ],
      "sub_total": subTotal,
      "tax": selectedVehicleType?.tax,
      "total": total,
      "discount": checkout!.discount,
      "tip": tip,
      "coupon_code": coupon?.code,
      "vehicle_type": selectedVehicleType?.encrypted,
      "pickup_date": checkout!.pickupDate,
      "pickup_time": checkout!.pickupTime,
    };

    setBusy(true);
    final apiResponse = await taxiRequest.placeNeworder(params: params);
    setBusy(false);

    //if there was an issue placing the order
    if (!apiResponse.allGood) {
      final existing =
          apiResponse.body is Map ? apiResponse.body['order'] : null;
      if (existing is Map) {
        onGoingOrderTrip = Order.fromJson(Map<String, dynamic>.from(existing));
        await ActiveTaxiTripService.save(onGoingOrderTrip);
        startHandlingOnGoingTrip();
        toastSuccessful(
          apiResponse.message ?? 'Retomamos tu viaje activo'.tr(),
        );
      } else if (apiResponse.code == 409) {
        await Future.delayed(const Duration(seconds: 2));
        Order? confirmedTrip;
        try {
          confirmedTrip = await taxiRequest.getOnGoingTrip();
        } catch (_) {
          confirmedTrip = await ActiveTaxiTripService.restore();
        }
        if (confirmedTrip != null) {
          onGoingOrderTrip = confirmedTrip;
          await ActiveTaxiTripService.save(confirmedTrip);
          startHandlingOnGoingTrip();
          toastSuccessful('Retomamos tu viaje activo'.tr());
        } else {
          AlertService.error(
            title: 'Estamos confirmando tu viaje'.tr(),
            text: apiResponse.message,
          );
        }
      } else {
        AlertService.error(
          title: "Order failed".tr(),
          text: apiResponse.message,
        );
      }
    } else {
      //
      onGoingOrderTrip = Order.fromJson(apiResponse.body["order"]);
      await ActiveTaxiTripService.save(onGoingOrderTrip);
      //payment
      String paymentLink = apiResponse.body["link"];
      final paymentSlug = (onGoingOrderTrip?.paymentMethod?.slug ??
              selectedPaymentMethod?.slug ?? '')
          .toLowerCase();
      final isBankTransfer = paymentSlug.contains('transfer') ||
          paymentSlug.contains('deposit') ||
          paymentSlug.contains('bank');
      // Taxi bank transfers are completed after the trip through the native
      // proof/driver-confirmation flow; never open the generic web checkout.
      if (paymentLink.isNotBlank && !isBankTransfer) {
        await openWebpageLink(paymentLink);
      }
      //
      if (checkout!.pickupDate == null || !canScheduleTaxiOrder) {
        startHandlingOnGoingTrip();
      } else {
        closeOrderSummary();
      }
    }
  }

  //
  openTripChat() {
    final trip = onGoingOrderTrip;
    final driver = trip?.driver;
    if (trip == null || driver == null) {
      toastError('Espera a que se asigne un conductor'.tr());
      return;
    }

    Map<String, PeerUser> peers = {
      '${trip.userId}': PeerUser(
        id: '${trip.userId}',
        name: trip.user.name,
        image: trip.user.photo,
      ),
      '${driver.id}': PeerUser(
        id: '${driver.id}',
        name: driver.name,
        image: driver.photo,
      ),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${trip.userId}']!,
      peers: peers,
      //don't translate this
      path: 'orders/${trip.code}/customerDriver/chats',
      title: "Chat with driver".tr(),
      supportMedia: AppUISettings.canCustomerChatSupportMedia,
    );
    //
    Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.chatRoute, arguments: chatEntity);
  }

  Future<void> shareTrip() async {
    final trip = onGoingOrderTrip;
    if (trip == null) return;
    try {
      await TaxiTripShareService.share(trip);
    } catch (error) {
      toastError(error.toString());
    }
  }

  Future<Order?> getLastTripForRating() async {
    try {
      final order = await taxiRequest.getLastTripForRating();
      if (order == null || order.driver == null) {
        setCurrentStep(1);
      }
      return order;
    } catch (error) {
      return null;
    }
  }
}
