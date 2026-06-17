import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/widgets/buttons/qty_stepper.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CommerceProductQtyEntry extends StatelessWidget {
  const CommerceProductQtyEntry({
    required this.model,
    Key? key,
  }) : super(key: key);

  final ProductDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;
    //
    return Visibility(
      visible: model.product.hasStock,
      child: VStack(
        [
          //
          HStack(
            [
              //
              "Quantity:".tr().text.make().expand(flex: 2),
              //
              HStack(
                [
                  QtyStepper(
                    defaultValue: model.product.selectedQty,
                    min: 1,
                    max: (model.product.availableQty != null &&
                            model.product.availableQty! > 0)
                        ? model.product.availableQty!
                        : 20,
                    disableInput: true,
                    onChange: model.updatedSelectedQty,
                    actionIconColor: AppColor.primaryColor,
                  )
                      .box
                      .border(
                        color: AppColor.primaryColor,
                      )
                      .roundedLg
                      .p1
                      .make(),
                ],
              ).expand(flex: 4),
            ],
          ),
          UiSpacer.verticalSpace(),
          //total quantity price
          HStack(
            [
              //
              "Total Price:".tr().text.make().expand(flex: 2),
              UiSpacer.smHorizontalSpace(),
              //
              CurrencyHStack(
                [
                  currencySymbol.text.sm.bold
                      .color(context.primaryColor)
                      .make(),
                  model.total
                      .currencyValueFormat()
                      .text
                      .xl
                      .bold
                      .color(context.primaryColor)
                      .make(),
                ],
                crossAlignment: CrossAxisAlignment.end,
              ).expand(flex: 4)
            ],
          ),
        ],
      ).py12().px20(),
    );
  }
}
