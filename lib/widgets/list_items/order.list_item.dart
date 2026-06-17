import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/sizes.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    required this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function onPayPressed;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    return VStack([
          HStack([
            //
            VStack([
              //
              HStack([
                "#${order.code}".text.medium.make().expand(),
                "${AppStrings.currencySymbol} ${order.total}"
                    .currencyFormat()
                    .text
                    .lg
                    .semiBold
                    .make(),
              ]),
              UiSpacer.divider(),
              //
              "${order.vendor?.name}".text.lg.medium.make().py4(),
              //amount and total products
              HStack([
                (order.isPackageDelivery
                        ? order.packageType?.name
                        : order.isSerice
                        ? "${order.orderService?.service?.category?.name}"
                        : "%s Product(s)".tr().fill([
                          order.orderProducts?.length ?? 0,
                        ]))!
                    .text
                    .medium
                    .make()
                    .expand(),
                "${order.status}"
                    .tr()
                    .capitalized
                    .text
                    .color(AppColor.getStausColor(order.status))
                    .medium
                    .make(),
              ]),
              //time & status
              HStack([
                //time
                Visibility(
                  visible: order.paymentMethod != null,
                  child: "${order.paymentMethod?.name}".text.medium.make(),
                ).expand(),
                VxTextBuilder(
                  Jiffy.parseFromDateTime(
                    order.createdAt,
                  ).format(pattern: 'dd E, MMM y'),
                ).sm.make(),
                //EEEE dd MMM yyyy
              ]),
            ]).p12().expand(),
          ]),

          //
          //payment is pending
          (order.isPaymentPending && order.isOngoing)
              ? CustomButton(
                title: "PAY FOR ORDER".tr(),
                titleStyle: context.textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
                icon: FlutterIcons.credit_card_fea,
                iconSize: 18,
                onPressed: onPayPressed,
                shapeRadius: 0,
              )
              : UiSpacer.emptySpace(),
        ]).box
        .clip(Clip.antiAlias)
        .color(context.cardColor)
        .outerShadowSm
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusSmall)
        .make()
        .onInkTap(() => orderPressed());
  }
}
