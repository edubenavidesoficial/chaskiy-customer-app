import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/views/pages/cart/cart.page.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class GoToCartView extends StatelessWidget {
  const GoToCartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        initialData: CartServices.productsInCart.length,
        stream: CartServices.cartItemsCountStream.stream,
        builder: (context, snapshot) {
          return Visibility(
            visible: snapshot.hasData && snapshot.data! > 0,
            child: HStack(
              [
                //
                "You have %s in your cart"
                    .tr()
                    .fill([snapshot.data])
                    .text
                    .white
                    .make()
                    .expand(),
                //
                CustomButton(
                  title: "View Cart".tr(),
                  height: 30,
                  color: AppColor.accentColor,
                  elevation: 1,
                  onPressed: () {
                    context.push((context) => CartPage());
                  },
                ),
                //
              ],
            )
                .p20()
                .safeArea(top: false)
                .box
                .color(AppColor.primaryColor)
                .topRounded()
                .make(),
          );
        });
  }
}
