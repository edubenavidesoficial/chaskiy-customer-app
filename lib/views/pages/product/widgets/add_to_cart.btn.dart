import 'package:flutter/material.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AddToCartButton extends StatelessWidget {
  const AddToCartButton(this.model, {Key? key}) : super(key: key);

  final ProductDetailsViewModel model;

  //
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      loading: model.isBusy,
      child: "Add to cart"
          .tr()
          .text
          .color(Utils.textColorByTheme())
          .semiBold
          .make()
          .p12(),
      onPressed: model.addToCart,
    );
  }
}
