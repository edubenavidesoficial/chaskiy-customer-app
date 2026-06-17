import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/option.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OptionDetailsBottomSheet extends StatelessWidget {
  const OptionDetailsBottomSheet(this.option, {Key? key}) : super(key: key);

  final Option option;
  @override
  Widget build(BuildContext context) {
    return VStack([
      Visibility(
        visible: option.photo.isNotDefaultImage,
        child: CustomImage(
          imageUrl: option.photo,
          width: context.percentWidth * 100,
          height: context.percentWidth * 60,
          canZoom: true,
        ),
      ),
      UiSpacer.vSpace(),
      //name
      option.name.text.xl.semiBold.make(),
      UiSpacer.vSpace(10),
      //price
      Visibility(
        visible: option.price > 0,
        child: CurrencyHStack([
          AppStrings.currentCurrencySymbol.text.sm.bold
              .color(context.primaryColor)
              .make(),
          option.price.convertCurrency
              .currencyValueFormat()
              .text
              .xl
              .bold
              .color(context.primaryColor)
              .make(),
        ], crossAlignment: CrossAxisAlignment.end),
      ),
      UiSpacer.vSpace(15),
      //description
      Visibility(
        visible: "${option.description}".isNotEmpty,
        child: "${option.description}".text.sm.make(),
      ),
    ]).p20();
  }
}
