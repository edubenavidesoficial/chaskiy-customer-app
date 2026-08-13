import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/services/order.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderPaymentInfoView extends StatelessWidget {
  const OrderPaymentInfoView(this.vm, {Key? key}) : super(key: key);
  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final pendingPayment = vm.order.isPaymentPending && vm.order.isOngoing;
    final requestedPayment =
        vm.order.paymentStatus == "request" &&
        ["pending"].contains(vm.order.status);

    if (!pendingPayment && !requestedPayment) return UiSpacer.emptySpace();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          title: "PAY FOR ORDER".tr(),
          icon: FlutterIcons.credit_card_fea,
          iconSize: 18,
          loading: requestedPayment && vm.busy(vm.order.paymentStatus),
          onPressed:
              pendingPayment
                  ? () => OrderService.openOrderPayment(vm.order, vm)
                  : vm.openPaymentMethodSelection,
        ),
      ),
    );
  }
}
