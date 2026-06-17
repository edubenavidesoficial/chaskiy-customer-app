import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/states/product_stock.dart';
import 'package:velocity_x/velocity_x.dart';

class GridViewProductListItem extends StatelessWidget {
  const GridViewProductListItem({
    required this.product,
    required this.onPressed,
    required this.qtyUpdated,
    this.showStepper = false,
    Key? key,
  }) : super(key: key);

  final Function(Product) onPressed;
  final Function(Product, int) qtyUpdated;
  final Product product;
  final bool showStepper;
  @override
  Widget build(BuildContext context) {
    return VStack([
          //
          //product image
          Stack(
            children: [
              //
              Hero(
                tag: product.heroTag ?? product.id,
                child: CustomImage(
                  imageUrl: product.photo,
                  boxFit: BoxFit.contain,
                  width: double.infinity,
                  height: Vx.dp64 * 1.2,
                ),
              ),
              //
              //price tag
              Positioned(
                left: !Utils.isArabic ? 10 : null,
                right: !Utils.isArabic ? null : 10,
                child: Visibility(
                  visible: product.showDiscount,
                  child:
                      VxBox(
                            child:
                                "-${product.discountPercentage}%"
                                    .text
                                    .xs
                                    .semiBold
                                    .white
                                    .make(),
                          ).p4
                          .bottomRounded(value: 5)
                          .color(AppColor.primaryColor)
                          .make(),
                ),
              ),
            ],
          ),

          //
          VStack([
            product.name.text.semiBold
                .size(11)
                .minFontSize(10)
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make(),
            product.vendor.name.text.xs
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make(),

            //
            HStack([
              //price
              CurrencyHStack([
                AppStrings.currentCurrencySymbol.text.xs.make(),
                " ".text.make(),
                product.sellPrice.convertCurrency
                    .currencyValueFormat()
                    .text
                    .sm
                    .semiBold
                    .make(),
              ]).expand(),
              //plus/min icon here
              showStepper
                  ? ProductStockState(product, qtyUpdated: qtyUpdated)
                  : UiSpacer.emptySpace(),
            ]),
          ]).p8(),
        ])
        .material()
        .box
        .withRounded(value: 1)
        .color(context.theme.colorScheme.surface)
        .clip(Clip.antiAlias)
        .outerShadow
        .makeCentered()
        .onInkTap(() => this.onPressed(this.product));
  }
}
