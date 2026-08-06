import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/payment_method.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiPaymentItemView extends StatelessWidget {
  const TaxiPaymentItemView(
    this.paymentMethod, {
    this.selected = false,
    required this.onselected,
    Key? key,
  }) : super(key: key);

  final PaymentMethod paymentMethod;
  final bool selected;
  final Function onselected;

  @override
  Widget build(BuildContext context) {
    return HStack([
          //
          CustomImage(imageUrl: paymentMethod.photo, width: 30, height: 30),
          //
          UiSpacer.horizontalSpace(space: 10),
          //el nombre viene del servidor en inglés; si no hay traducción se
          //muestra tal cual
          "${paymentMethod.name}".tr().text.make(),
        ])
        .p4()
        .box
        .px8
        .roundedSM
        .border(
          color: selected ? AppColor.primaryColor : context.theme.dividerColor,
        )
        .make()
        .onInkTap(() => onselected(paymentMethod));
  }
}
