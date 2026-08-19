import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/checkout.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/models/multi_delivery.dart';
import 'package:chaskiy/requests/checkout.request.dart';
import 'package:chaskiy/requests/delivery_address.request.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/requests/vendor.request.dart';
import 'package:chaskiy/requests/payment_method.request.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/view_models/payment.view_model.dart';
import 'package:chaskiy/widgets/bottomsheets/delivery_address_picker.bottomsheet.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class CheckoutBaseViewModel extends PaymentViewModel {
  //
  CheckoutRequest checkoutRequest = CheckoutRequest();
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();

  VendorRequest vendorRequest = VendorRequest();
  OrderRequest orderRequest = OrderRequest();
  TextEditingController driverTipTEC = TextEditingController();
  TextEditingController noteTEC = TextEditingController();

  /// Última propina con la que ya se recalculó el total, para no repetir la
  /// consulta cuando el monto no cambió.
  String syncedDriverTip = "";
  DeliveryAddress? deliveryAddress;
  bool isPickup = false;
  bool isScheduled = false;
  List<String> availableTimeSlots = [];
  bool delievryAddressOutOfRange = false;
  bool canSelectPaymentOption = true;
  Vendor? vendor;
  CheckOut? checkout;
  bool calculateTotal = true;

  //
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  //
  bool paymentTermsAgreed = false;

  void initialise() async {
    await fetchVendorDetails();
    prefetchDeliveryAddress();
    fetchPaymentOptions();
    updateTotalOrderSummary();
  }

  //
  fetchVendorDetails() async {
    //
    if (CartServices.productsInCart.isEmpty) {
      return;
    }
    vendor = CartServices.productsInCart[0].product?.vendor;

    //
    setBusy(true);
    try {
      vendor = await vendorRequest.vendorDetails(
        vendor!.id,
        params: {"type": "brief"},
      );
      setVendorRequirement();
    } catch (error) {
      print("Error Getting Vendor Details ==> $error");
    }
    setBusy(false);
  }

  setVendorRequirement() {
    if (vendor!.allowOnlyDelivery) {
      isPickup = false;
    } else if (vendor!.allowOnlyPickup) {
      isPickup = true;
    }
    checkout?.isPickup = isPickup;
  }

  //start of schedule related
  changeSelectedDeliveryDate(String string, int index) {
    checkout?.deliverySlotDate = string;
    availableTimeSlots = vendor!.deliverySlots[index].times;
    notifyListeners();
  }

  changeSelectedDeliveryTime(String time) {
    checkout?.deliverySlotTime = time;
    notifyListeners();
  }

  //end of schedule related
  //
  prefetchDeliveryAddress() async {
    setBusyForObject(deliveryAddress, true);
    //
    try {
      //
      checkout!.deliveryAddress =
          deliveryAddress = await preselectDeliveryAddress();

      if (checkout?.deliveryAddress != null) {
        //
        checkDeliveryRange();
        updateTotalOrderSummary();
      }
    } catch (error) {
      print("Error Fetching preselected Address ==> $error");
    }
    setBusyForObject(deliveryAddress, false);
  }

  /// Dirección con la que se abre el checkout.
  ///
  /// El backend solo devuelve la marcada como predeterminada y esa marca es
  /// opcional al guardar, así que quien nunca la activó llegaba al checkout
  /// sin dirección. Cuando no hay predeterminada se usa la primera de la
  /// lista, que el backend ordena por cercanía al vendedor.
  Future<DeliveryAddress?> preselectDeliveryAddress() async {
    final defaultAddress = await deliveryAddressRequest
        .preselectedDeliveryAddress(vendorId: vendor?.id);
    if (defaultAddress != null) return defaultAddress;

    final addresses = await deliveryAddressRequest.getDeliveryAddresses(
      vendorId: vendor?.id,
    );
    return addresses.isEmpty ? null : addresses.first;
  }

  //
  fetchPaymentOptions({int? vendorId}) async {
    setBusyForObject(paymentMethods, true);
    try {
      paymentMethods = await paymentOptionRequest.getPaymentOptions(
        vendorId: vendorId != null ? vendorId : vendor?.id,
        params: {"is_pickup": isPickup ? 1 : 0},
      );
      //
      updatePaymentOptionSelection();
      clearErrors();
    } catch (error) {
      print("Regular Error getting payment methods ==> $error");
    }
    setBusyForObject(paymentMethods, false);
  }

  //
  fetchTaxiPaymentOptions() async {
    setBusyForObject(paymentMethods, true);
    try {
      paymentMethods = await paymentOptionRequest.getTaxiPaymentOptions();
      //
      updatePaymentOptionSelection();
      clearErrors();
    } catch (error) {
      print("Taxi Error getting payment methods ==> $error");
    }
    setBusyForObject(paymentMethods, false);
  }

  updatePaymentOptionSelection() {
    if (checkout != null && checkout!.total <= 0.00) {
      canSelectPaymentOption = false;
    } else {
      canSelectPaymentOption = true;
    }
    //
    if (!canSelectPaymentOption) {
      final selectedPaymentMethod = paymentMethods.firstOrNullWhere(
        (e) => e.isCash == 1,
      );
      changeSelectedPaymentMethod(selectedPaymentMethod, callTotal: false);
    }
  }

  //
  Future<DeliveryAddress?> showDeliveryAddressPicker() async {
    //
    final mDeliveryAddress = await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DeliveryAddressPicker(
          onSelectDeliveryAddress: (deliveryAddress) {
            this.deliveryAddress = deliveryAddress;
            checkout?.deliveryAddress = deliveryAddress;
            if (checkout?.useMultiDelivery == true &&
                checkout!.deliveries.isNotEmpty) {
              final current = checkout!.deliveries.first;
              checkout!.deliveries[0] = MultiDelivery(
                deliveryAddress: deliveryAddress,
                quantities: Map<int, int>.from(current.quantities),
                recipientName: current.recipientName,
                recipientPhone: current.recipientPhone,
                note: current.note,
              );
            }
            //
            checkDeliveryRange();
            updateTotalOrderSummary();
            //
            notifyListeners();
            viewContext.pop(deliveryAddress);
          },
        );
      },
    );
    return mDeliveryAddress;
  }

  int get totalCartQuantity => CartServices.productsInCart.fold(
    0,
    (total, cart) => total + (cart.selectedQty ?? 0),
  );

  bool get canUseMultiDelivery =>
      vendor?.allowMultiDelivery == true && totalCartQuantity > 1 && !isPickup;

  void toggleMultiDelivery(bool enabled) {
    if (!enabled || !canUseMultiDelivery) {
      checkout?.useMultiDelivery = false;
      checkout?.deliveries = [];
      updateTotalOrderSummary();
      notifyListeners();
      return;
    }
    if (deliveryAddress == null) {
      AlertService.error(
        title: 'Dirección de entrega',
        text: 'Selecciona primero la dirección de la primera entrega.',
      );
      return;
    }

    checkout?.useMultiDelivery = true;
    checkout?.deliveries = [
      MultiDelivery(
        deliveryAddress: deliveryAddress!,
        quantities: {
          for (
            var index = 0;
            index < CartServices.productsInCart.length;
            index++
          )
            index: CartServices.productsInCart[index].selectedQty ?? 0,
        },
      ),
    ];
    notifyListeners();
  }

  Future<void> addMultiDeliveryAddress() async {
    final selected = await showModalBottomSheet<DeliveryAddress>(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DeliveryAddressPicker(
            onSelectDeliveryAddress:
                (address) => Navigator.pop(context, address),
          ),
    );
    if (selected == null) return;
    if (checkout!.deliveries.any(
      (item) => item.deliveryAddress.id == selected.id,
    )) {
      AlertService.error(
        title: 'Dirección repetida',
        text: 'Cada dirección debe aparecer una sola vez en la ruta.',
      );
      return;
    }
    checkout!.deliveries.add(MultiDelivery(deliveryAddress: selected));
    notifyListeners();
  }

  void removeMultiDelivery(int index) {
    if (index == 0) return;
    checkout!.deliveries.removeAt(index);
    if (multiDeliveryDistributionIsValid) updateTotalOrderSummary();
    notifyListeners();
  }

  int assignedQuantityForLine(int lineIndex, {int? excludingStop}) {
    var total = 0;
    for (var index = 0; index < (checkout?.deliveries.length ?? 0); index++) {
      if (index != excludingStop) {
        total += checkout!.deliveries[index].quantityFor(lineIndex);
      }
    }
    return total;
  }

  int maxQuantityForLine(int stopIndex, int lineIndex) {
    final purchased = CartServices.productsInCart[lineIndex].selectedQty ?? 0;
    return purchased -
        assignedQuantityForLine(lineIndex, excludingStop: stopIndex);
  }

  void changeDeliveryQuantity(int stopIndex, int lineIndex, int quantity) {
    if (quantity <= 0) {
      checkout!.deliveries[stopIndex].quantities.remove(lineIndex);
    } else {
      checkout!.deliveries[stopIndex].quantities[lineIndex] = quantity;
    }
    if (multiDeliveryDistributionIsValid) updateTotalOrderSummary();
    notifyListeners();
  }

  bool get multiDeliveryDistributionIsValid {
    if (checkout?.useMultiDelivery != true) return true;
    final deliveries = checkout!.deliveries;
    if (deliveries.length < 2 ||
        deliveries.any((item) => item.totalQuantity < 1)) {
      return false;
    }
    for (var index = 0; index < CartServices.productsInCart.length; index++) {
      final expected = CartServices.productsInCart[index].selectedQty ?? 0;
      if (assignedQuantityForLine(index) != expected) return false;
    }
    return true;
  }

  //
  togglePickupStatus(bool? value) {
    //
    if (vendor!.allowOnlyPickup) {
      value = true;
    } else if (vendor!.allowOnlyDelivery) {
      value = false;
    }
    isPickup = value ?? false;
    checkout?.isPickup = isPickup;
    if (isPickup && checkout?.useMultiDelivery == true) {
      checkout?.useMultiDelivery = false;
      checkout?.deliveries = [];
    }
    //remove delivery address if pickup
    if (isPickup) {
      checkout?.deliveryAddress = null;
    } else {
      checkout?.deliveryAddress = deliveryAddress;
    }

    updateTotalOrderSummary();
    notifyListeners();
    fetchPaymentOptions();
  }

  //
  toggleScheduledOrder(bool? value) async {
    isScheduled = value ?? false;
    checkout?.isScheduled = isScheduled;
    //remove delivery address if pickup
    checkout?.pickupDate = null;
    checkout?.deliverySlotDate = "";
    checkout?.pickupTime = null;
    checkout?.deliverySlotTime = "";

    await Jiffy.setLocale(translator.activeLocale.languageCode);

    notifyListeners();
  }

  //
  void checkDeliveryRange() {
    delievryAddressOutOfRange =
        vendor!.deliveryRange < (deliveryAddress!.distance ?? 0);
    if (deliveryAddress?.can_deliver != null) {
      delievryAddressOutOfRange =
          (deliveryAddress?.can_deliver ?? false) ==
          false; //if vendor has set delivery range
    }
    notifyListeners();
  }

  //
  isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethod?.id;
  }

  changeSelectedPaymentMethod(
    PaymentMethod? paymentMethod, {
    bool callTotal = true,
  }) {
    selectedPaymentMethod = paymentMethod;
    checkout?.paymentMethod = paymentMethod;
    if (callTotal) {
      updateTotalOrderSummary();
    }
    notifyListeners();
  }

  /// Cambia la propina del conductor y recalcula el total.
  ///
  /// El resumen mostraba la propina pero el total solo la sumaba si el
  /// cliente presionaba "listo" en el teclado, así que veía un monto y se le
  /// cobraba otro.
  void setDriverTip(String amount) {
    final tip = amount.trim();
    if (driverTipTEC.text != tip) {
      driverTipTEC.text = tip;
    }
    if (syncedDriverTip == tip) {
      notifyListeners();
      return;
    }
    updateTotalOrderSummary();
  }

  //update total/order amount summary
  updateTotalOrderSummary() async {
    syncedDriverTip = driverTipTEC.text.trim();
    //generate order summary
    Map<String, dynamic> payload = {
      "pickup": isPickup ? 1 : 0,
      "delievryAddressOutOfRange": delievryAddressOutOfRange ? 1 : 0,
      "tip": driverTipTEC.text,
      "delivery_address_id": deliveryAddress?.id ?? "null",
      "latlng": "${deliveryAddress?.latitude},${deliveryAddress?.longitude}",
      "coupon_code": checkout!.coupon?.code ?? "",
      "vendor_id": vendor!.id,
      "products":
          CartServices.productsInCart.map((e) => e.toCheckout()).toList(),
      "deliveries":
          checkout?.useMultiDelivery == true
              ? checkout!.deliveries
                  .map((e) => e.toPayload(CartServices.productsInCart))
                  .toList()
              : null,
    };

    setBusy(true);
    try {
      final mCheckout = await checkoutRequest.orderSummary(payload);
      checkout!.copyWith(
        subTotal: mCheckout.subTotal,
        discount: mCheckout.discount,
        deliveryFee: mCheckout.deliveryFee,
        tax: mCheckout.tax,
        tax_rate: mCheckout.tax_rate,
        total: mCheckout.total,
        totalWithTip: mCheckout.totalWithTip,
        token: mCheckout.token,
        fees: mCheckout.fees,
      );
    } catch (error) {
      print("Error getting order summary ==> $error");
      toastError("$error");
    }
    setBusy(false);
    //
    updatePaymentOptionSelection();
    notifyListeners();
  }

  //
  bool pickupOnlyProduct() {
    //
    final product = CartServices.productsInCart.firstOrNullWhere(
      (e) => !e.product?.canBeDelivered,
    );

    return product != null;
  }

  //
  placeOrder({bool ignore = false}) async {
    //
    if (isScheduled && checkout!.deliverySlotDate.isEmptyOrNull) {
      //
      AlertService.error(
        title: "Delivery Date".tr(),
        text: "Please select your desire order date".tr(),
      );
    } else if (isScheduled && checkout!.deliverySlotTime.isEmptyOrNull) {
      //
      AlertService.error(
        title: "Delivery Time".tr(),
        text: "Please select your desire order time".tr(),
      );
    } else if (!isPickup && pickupOnlyProduct()) {
      //
      AlertService.error(
        title: "Product".tr(),
        text:
            "There seems to be products that can not be delivered in your cart"
                .tr(),
      );
    } else if (!isPickup && deliveryAddress == null) {
      //
      AlertService.error(
        title: "Delivery address".tr(),
        text: "Please select delivery address".tr(),
      );
    } else if (!multiDeliveryDistributionIsValid) {
      AlertService.error(
        title: 'Distribución de entregas',
        text:
            'Asigna todas las unidades y deja al menos un producto en cada dirección.',
      );
    } else if (delievryAddressOutOfRange && !isPickup) {
      //
      AlertService.error(
        title: "Delivery address".tr(),
        text: "Delivery address is out of vendor delivery range".tr(),
      );
    } else if (selectedPaymentMethod == null) {
      AlertService.error(
        title: "Payment Methods".tr(),
        text: "Please select a payment method".tr(),
      );
    } else if (!ignore && !verifyVendorOrderAmountCheck()) {
      print("Failed");
    }
    //process the new order
    else {
      processOrderPlacement();
    }
  }

  //
  processOrderPlacement() async {
    //process the order placement
    setBusy(true);
    //set the total with discount as the new total
    checkout!.total = checkout!.totalWithTip;
    //
    final apiResponse = await checkoutRequest.newOrder(
      checkout!,
      tip: driverTipTEC.text,
      note: noteTEC.text,
    );

    //notify wallet view to update, just incase wallet was use for payment
    AppService().refreshWalletBalance.add(true);

    //not error
    if (apiResponse.allGood) {
      await CartServices.clearCart();

      //cash payment
      final paymentLink = apiResponse.body["link"].toString();
      if (!paymentLink.isEmptyOrNull) {
        //close pages
        await Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) {
            return route.isFirst;
          },
        );
        showOrdersTab(context: viewContext);
        dynamic result;
        // if (["offline", "razorpay"]
        if (["offline"].contains(checkout!.paymentMethod?.slug ?? "offline")) {
          result = await openExternalWebpageLink(paymentLink);
        } else {
          result = await openWebpageLink(paymentLink);
        }
        print("Result from payment ==> $result");
      }
      //cash payment
      else {
        AlertService.success(text: apiResponse.localizedMessage);
        await openNewOrderDetails();
      }
    } else {
      AlertService.error(
        title: "Checkout".tr(),
        text: apiResponse.localizedMessage,
      );
    }
    setBusy(false);
    CartServices.refreshState();
  }

  /// Saca al usuario del checkout apenas se crea el pedido.
  ///
  /// El aviso de éxito es un SnackBar y no bloquea, así que la salida no puede
  /// depender de que lo toquen: si no, la pantalla de confirmación queda
  /// activa y el pedido se puede enviar dos veces.
  ///
  /// `POST /orders` solo devuelve el mensaje, no el pedido, por eso primero se
  /// deja el checkout y recién después se consulta el último pedido para abrir
  /// su detalle. Si esa consulta falla, el usuario ya está en la pestaña de
  /// pedidos.
  Future<void> openNewOrderDetails() async {
    final navigator = Navigator.of(viewContext);
    showOrdersTab(context: viewContext);

    try {
      final orders = await orderRequest.getOrders(page: 1);
      if (orders.isEmpty) return;
      await navigator.pushNamed(
        AppRoutes.orderDetailsRoute,
        arguments: orders.first,
      );
    } catch (error) {
      print("No se pudo abrir el detalle del pedido ==> $error");
    }
  }

  //
  showOrdersTab({required BuildContext context}) {
    //clear cart items
    CartServices.clearCart();
    //switch tab to orders
    AppService().changeHomePageIndex(index: 1);
    //pop until home page
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil(
        (route) => route.settings.name == AppRoutes.homeRoute || route.isFirst,
      );
    }
  }

  //
  bool verifyVendorOrderAmountCheck() {
    //if vendor set min/max order
    final orderVendor = checkout?.cartItems?.first.product?.vendor ?? vendor;
    //if order is less than the min allowed order by this vendor
    //if vendor is currently open for accepting orders

    if (!vendor!.isOpen &&
        !(checkout!.isScheduled ?? false) &&
        !(checkout!.isPickup ?? false)) {
      //vendor is closed
      AlertService.error(
        title: "Vendor is not open".tr(),
        text:
            "Vendor is currently not open to accepting order at the moment"
                .tr(),
      );
      return false;
    } else if (orderVendor?.minOrder != null &&
        orderVendor!.minOrder! > checkout!.subTotal) {
      ///
      AlertService.error(
        title: "Minimum Order Value".tr(),
        text:
            "Order value/amount is less than vendor accepted minimum order"
                .tr() +
            "${AppStrings.currencySymbol} ${orderVendor.minOrder}"
                .currencyFormat(),
      );
      return false;
    }
    //if order is more than the max allowed order by this vendor
    else if (orderVendor?.maxOrder != null &&
        orderVendor!.maxOrder! < checkout!.subTotal) {
      //
      AlertService.error(
        title: "Maximum Order Value".tr(),
        text:
            "Order value/amount is more than vendor accepted maximum order"
                .tr() +
            "${AppStrings.currencySymbol} ${orderVendor.maxOrder}"
                .currencyFormat(),
      );
      return false;
    }
    return true;
  }
}
