import 'package:flutter/material.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/checkout_base.vm.dart';
import 'package:chaskiy/widgets/custom_grid_view.dart';
import 'package:chaskiy/widgets/list_items/payment_method.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView(this.vm, {this.embedded = false, Key? key})
    : super(key: key);

  final CheckoutBaseViewModel vm;

  /// Dentro de una tarjeta de sección el título y el separador ya los pone
  /// la tarjeta, así que aquí se omiten.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return VStack([
      if (!embedded) "Payment Methods".tr().text.semiBold.xl.make(),
      CustomGridView(
        noScrollPhysics: true,
        dataSet: vm.paymentMethods,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        isLoading: vm.busy(vm.paymentMethods),
        itemBuilder: (context, index) {
          //
          final paymentMethod = vm.paymentMethods[index];
          return PaymentOptionListItem(
            paymentMethod,
            selected: vm.isSelected(paymentMethod),
            onSelected: vm.changeSelectedPaymentMethod,
          );
        },
      ).pOnly(top: embedded ? 0 : Vx.dp16),
      //
      if (!embedded) UiSpacer.divider(thickness: 2).py12(),
    ]);
  }
}
