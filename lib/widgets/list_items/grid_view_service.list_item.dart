import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/service.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class GridViewServiceListItem extends StatelessWidget {
  const GridViewServiceListItem({
    required this.service,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Function(Service) onPressed;
  final Service service;
  @override
  Widget build(BuildContext context) {
    return VStack([
          //service image
          Stack(
            children: [
              Hero(
                tag: service.heroTag ?? service.id,
                child: CustomImage(
                  imageUrl: service.photos.first,
                  boxFit: BoxFit.cover,
                  width: double.infinity,
                  height: 80,
                ),
              ),

              //discount
              Positioned(
                bottom: 0,
                left: Utils.isArabic ? 0 : null,
                right: !Utils.isArabic ? 0 : null,
                child:
                    service.showDiscount
                        ? "-${service.discountPercentage}%"
                            .text
                            .white
                            .sm
                            .semiBold
                            .make()
                            .p2()
                            .px4()
                            .box
                            .red500
                            .topRightRounded(value: !Utils.isArabic ? 0 : 10)
                            .topLeftRounded(value: Utils.isArabic ? 0 : 10)
                            .make()
                        : UiSpacer.emptySpace(),
              ),
            ],
          ),

          UiSpacer.verticalSpace(space: 10),
          //name/title
          service.name.text.sm.medium.make().px12(),
          //description and price
          HStack([
            "${service.description}".text
                .minFontSize(9)
                .size(9)
                .gray400
                .medium
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make()
                .expand(),
            CurrencyHStack([
              "${AppStrings.currentCurrencySymbol}".text.xs.light
                  .color(AppColor.primaryColor)
                  .make(),
              service.sellPrice.convertCurrency
                  .currencyValueFormat()
                  .text
                  .semiBold
                  .color(AppColor.primaryColor)
                  .sm
                  .make(),
            ]),
            " ${service.durationText}".text.medium.xs.make(),
          ]).px12(),
          UiSpacer.verticalSpace(space: 10),
        ]).box
        .withRounded(value: 10)
        .color(context.cardColor)
        .outerShadow
        .clip(Clip.antiAlias)
        .makeCentered()
        .onInkTap(() => this.onPressed(this.service))
        .py4();
  }
}
