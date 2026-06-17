import 'package:flutter/material.dart';
import 'package:chaskiy/models/checkout.dart';
import 'package:chaskiy/view_models/checkout_base.vm.dart';

class CheckoutViewModel extends CheckoutBaseViewModel {
  //

  //
  CheckoutViewModel(
    BuildContext context,
    CheckOut checkout,
  ) {
    this.viewContext = context;
    this.checkout = checkout;
  }
}
