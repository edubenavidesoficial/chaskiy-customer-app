import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/checkout.dart';
import 'package:chaskiy/models/coupon.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/cart.request.dart';
import 'package:chaskiy/requests/payment_method.request.dart';
import 'package:chaskiy/requests/taxi.request.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/services/chat.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/services/trip.service.dart';
import 'package:chaskiy/view_models/trip_taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiViewModel extends TripTaxiViewModel {
  //
  TaxiViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
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

  //
  CheckOut? checkout = CheckOut();
  double subTotal = 0.0;
  double total = 0.0;
  double tip = 0.0;

  //functions
  void initialise() async {
    await fetchTaxiPaymentOptions();
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
    if (dropoffLocation == null) {
      toastError("Please select pickup and drop-off location".tr());
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
    final apiResponse = await taxiRequest.locationAvailable(
      pickupLocation?.latitude ?? 0.00,
      pickupLocation?.longitude ?? 0.00,
    );
    if (apiResponse.allGood) {
      prepareStep2();
    } else {
      setCurrentStep(0);
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
    setBusyForObject(vehicleTypes, true);
    vehicleTypesLoadFailed = false;
    vehicleTypes = [];
    selectedVehicleType = null;
    try {
      vehicleTypes = await taxiRequest.getVehicleTypePricing(
        pickupLocation!,
        dropoffLocation!,
        countryCode: LocationService.currenctAddress?.countryCode,
      );
      vehicleTypesLoadFailed = vehicleTypes.isEmpty;
    } catch (error) {
      print("Error getting vehicleTypes ==> $error");
      vehicleTypesLoadFailed = true;
    }
    setBusyForObject(vehicleTypes, false);
    notifyListeners();
  }

  resortVehicleTypes() {
    vehicleTypes.removeWhere((e) => e.id == selectedVehicleType?.id);
    vehicleTypes.insert(0, selectedVehicleType!);
  }

  //
  changeSelectedVehicleType(VehicleType vehicleType) {
    selectedVehicleType = vehicleType;
    nearbyVehicleTypeId = vehicleType.id;
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
      AlertService.error(title: "Order failed".tr(), text: apiResponse.message);
    } else {
      //
      onGoingOrderTrip = Order.fromJson(apiResponse.body["order"]);
      //payment
      String paymentLink = apiResponse.body["link"];
      if (paymentLink.isNotBlank) {
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
