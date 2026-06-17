import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/service.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceListItem extends StatelessWidget {
  const ServiceListItem({
    required this.service,
    required this.onPressed,
    required this.imgW,
    required this.height,
    Key? key,
  }) : super(key: key);

  final Function(Service) onPressed;
  final Service service;
  final double? imgW;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return HStack([
          //service image
          if (service.photos.isNotEmpty)
            Hero(
              tag: service.heroTag ?? service.id,
              child:
                  CustomImage(
                    imageUrl: service.photos.first,
                    boxFit: BoxFit.cover,
                    width: imgW ?? (height != null ? (height! * 2.2) : 75),
                    height: height ?? 70,
                  ).box.clip(Clip.antiAlias).make(),
            ).h(height ?? 70),

          // "${service.photos}".text.make(),
          VStack([
            //name/title
            service.name.text.base.make(),
            //description
            CustomVisibilty(
              visible: service.description.isNotEmpty,
              child:
                  service.description.text.gray600.sm.thin
                      .maxLines(1)
                      .overflow(TextOverflow.ellipsis)
                      .make(),
            ),
            //price
            FittedBox(
              child: HStack([
                "${service.hasOptions ? "From".tr() : ""} ".text.sm.make(),
                CurrencyHStack([
                  "${AppStrings.currentCurrencySymbol}".text.base.light
                      .color(AppColor.primaryColor)
                      .make(),
                  UiSpacer.horizontalSpace(space: 5),
                  service.sellPrice.convertCurrency
                      .currencyValueFormat()
                      .text
                      .semiBold
                      .color(AppColor.primaryColor)
                      .xl
                      .make(),
                ]),
                " ${service.durationText}".text.medium.xs.make(),
                //
                UiSpacer.horizontalSpace(),
                //dsicount
                Visibility(
                  visible: service.showDiscount,
                  child: "- ${service.discountPercentage}%".text.red500.make(),
                ),
              ]),
            ),
          ]).py4().px12().expand(),
        ]).box
        .withRounded(value: 10)
        .color(context.cardColor)
        .outerShadowSm
        .clip(Clip.antiAlias)
        .makeCentered()
        .onInkTap(() => this.onPressed(this.service));
  }
}
