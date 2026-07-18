import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EmptyDeliveryAddress extends StatelessWidget {
  const EmptyDeliveryAddress({
    Key? key,
    this.selection = false,
    this.isBooking = false,
  }) : super(key: key);

  final bool selection;
  final bool isBooking;
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imageUrl: AppImages.addressPin,
      title:
          selection
              ? (isBooking
                  ? "No Booking Address Selected".tr()
                  : "No Delivery Address Selected".tr())
              : (isBooking
                  ? "No Booking Address Found".tr()
                  : "No Delivery Address Found".tr()),
      description:
          selection
              ? (isBooking
                  ? "Please select a booking address".tr()
                  : "Please select a delivery address".tr())
              : (isBooking
                  ? "When you add booking addresses, they will appear here".tr()
                  : "When you add delivery addresses, they will appear here"
                      .tr()),
    );
  }
}
