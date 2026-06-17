import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderDetailsRecipentInfoView extends StatelessWidget {
  const OrderDetailsRecipentInfoView(this.vm, {Key? key}) : super(key: key);
  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        vm.order.recipientName != null && vm.order.recipientName!.isNotBlank
            ? HStack(
                [
                  //
                  VStack(
                    [
                      "Recipient Name".tr().text.gray500.medium.sm.make(),
                      vm.order.recipientName!.text.medium.xl
                          .make()
                          .pOnly(bottom: Vx.dp20),
                    ],
                  ).expand(),
                  //call
                  CustomButton(
                    icon: FlutterIcons.phone_call_fea,
                    iconColor: Colors.white,
                    title: "",
                    color: AppColor.primaryColor,
                    shapeRadius: Vx.dp24,
                    onPressed: vm.callRecipient,
                  ).wh(Vx.dp64, Vx.dp40).p12(),
                ],
              )
            : UiSpacer.emptySpace(),
      ],
    );
  }
}
