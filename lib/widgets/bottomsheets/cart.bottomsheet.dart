import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/views/pages/cart/cart.page.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class CartViewBottomSheet extends StatelessWidget {
  const CartViewBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppUISettings.showCart) {
      return SizedBox.shrink();
    }
    //
    return StreamBuilder<int>(
      stream: CartServices.cartItemsCountStream.stream,
      initialData: CartServices.productsInCart.length,
      builder: (context, snapshot) {
        //
        if (!snapshot.hasData || snapshot.data == 0) {
          return SizedBox.shrink();
        }
        //
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
          width: double.infinity,
          child: HStack([
            VStack([
              "${snapshot.data} ${snapshot.data == 1 ? 'producto' : 'productos'}"
                  .text
                  .sm
                  .color(Theme.of(context).colorScheme.onSurfaceVariant)
                  .make(),
              "${AppStrings.currentCurrencySymbol} ${CartServices.totalSubtotal.convertCurrency}"
                  .currencyFormat()
                  .text
                  .bold
                  .xl
                  .color(Theme.of(context).colorScheme.onSurface)
                  .make(),
            ]).expand(),

            CustomButton(
              title: "Ver carrito",
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => CartPage()));
              },
            ),
          ], spacing: 20),
        ).safeArea();
      },
    );
  }
}
