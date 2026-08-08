import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/view_models/checkout.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

/// Barra fija inferior con el total y la acción de confirmar el pedido.
///
/// Mantiene juntos el monto, la aceptación de términos y el botón, para que
/// el cliente no tenga que desplazarse buscando por qué el botón está
/// deshabilitado.
class CheckoutBottomBarView extends StatelessWidget {
  const CheckoutBottomBarView(this.vm, {Key? key}) : super(key: key);

  final CheckoutViewModel vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currencySymbol = AppStrings.currentCurrencySymbol;
    final total = "$currencySymbol ${vm.checkout!.totalWithTip.convertCurrency}"
        .currencyFormat(currencySymbol);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: .55)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: VStack([
          //aceptación de términos
          HStack([
            Checkbox(
              value: vm.paymentTermsAgreed,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (value) {
                vm.paymentTermsAgreed = value ?? false;
                vm.notifyListeners();
              },
            ),
            8.widthBox,
            "By proceeding to place order, you agree that you are bound by our"
                .tr()
                .richText
                .size(12)
                .color(colors.onSurfaceVariant)
                .withTextSpanChildren([
                  " ".textSpan.make(),
                  "Terms & Conditions"
                      .tr()
                      .textSpan
                      .size(12)
                      .color(AppColor.primaryColor)
                      .bold
                      .underline
                      .tap(vm.openPaymentTerms)
                      .make(),
                ])
                .make()
                .expand(),
          ]).pOnly(bottom: Vx.dp12),

          //total
          HStack([
            "Total to pay".tr().text.color(colors.onSurfaceVariant).make(),
            total.text.xl2.bold.make(),
          ], alignment: MainAxisAlignment.spaceBetween).pOnly(bottom: Vx.dp12),

          //acción
          CustomButton(
            title: "PLACE ORDER".tr(),
            icon: HugeIcons.strokeRoundedShoppingBag01,
            iconSize: 20,
            height: 52,
            isFixedHeight: true,
            onPressed: vm.paymentTermsAgreed ? () => vm.placeOrder() : null,
            loading: vm.isBusy,
          ).wFull(context),
        ]).px20().pOnly(top: Vx.dp16, bottom: Vx.dp12),
      ),
    );
  }
}
