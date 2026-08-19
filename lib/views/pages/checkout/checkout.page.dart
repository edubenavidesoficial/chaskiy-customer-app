import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/checkout.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/checkout.vm.dart';
import 'package:chaskiy/views/pages/checkout/widgets/checkout_bottom_bar.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/checkout_section.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/driver_cash_delivery_note.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/driver_tip.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/order_delivery_address.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/multi_delivery.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/payment_methods.view.dart';
import 'package:chaskiy/views/pages/checkout/widgets/schedule_order.view.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/cards/order_summary.dart';
import 'package:chaskiy/widgets/currency_conversion_notice.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({required this.checkout, Key? key}) : super(key: key);

  final CheckOut checkout;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckoutViewModel>.reactive(
      viewModelBuilder: () => CheckoutViewModel(context, checkout),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //el teclado tapa la barra inferior, así que se oculta mientras escribe
        final keyboardIsOpen = context.mq.viewInsets.bottom > 0;

        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Checkout".tr(),
          bottomNavigationBar:
              keyboardIsOpen ? null : CheckoutBottomBarView(vm),
          body: VStack([
            //entrega: retiro en local, dirección y programación
            ScheduleOrderView(vm),
            if (vm.vendor!.allowScheduleOrder)
              UiSpacer.verticalSpace(space: 16),
            OrderDeliveryAddressPickerView(vm),
            if (vm.canUseMultiDelivery) ...[
              UiSpacer.verticalSpace(space: 16),
              MultiDeliveryView(vm),
            ],

            //propina
            if (!vm.isPickup) ...[
              UiSpacer.verticalSpace(space: 16),
              DriverTipView(vm),
            ],

            //nota para el negocio
            UiSpacer.verticalSpace(space: 16),
            CheckoutSectionView(
              icon: HugeIcons.strokeRoundedStickyNote01,
              title: "Note".tr(),
              subtitle: "Any detail the vendor should know".tr(),
              child: CustomTextFormField(
                hintText: "Note".tr(),
                textEditingController: vm.noteTEC,
                maxLines: 3,
                minLines: 2,
              ),
            ),

            //forma de pago
            if (vm.canSelectPaymentOption) ...[
              UiSpacer.verticalSpace(space: 16),
              CheckoutSectionView(
                icon: HugeIcons.strokeRoundedWallet01,
                title: "Payment Methods".tr(),
                child: PaymentMethodsView(vm, embedded: true),
              ),
            ],

            //desglose de montos
            UiSpacer.verticalSpace(space: 16),
            CheckoutSectionView(
              icon: HugeIcons.strokeRoundedInvoice01,
              title: "Order Summary".tr(),
              child: OrderSummary(
                showTitle: false,
                subTotal: vm.checkout!.subTotal,
                discount:
                    (vm.checkout!.coupon?.for_delivery ?? false)
                        ? null
                        : vm.checkout!.discount,
                deliveryDiscount:
                    (vm.checkout!.coupon?.for_delivery ?? false)
                        ? vm.checkout!.deliveryDiscount
                        : null,
                deliveryFee: vm.checkout!.deliveryFee,
                tax: vm.checkout!.tax,
                vendorTax:
                    vm.checkout!.tax_rate?.currencyValueFormat() ??
                    vm.vendor!.tax,
                driverTip: double.tryParse("${vm.driverTipTEC.text}") ?? 0.00,
                total: vm.checkout!.totalWithTip,
                fees: vm.vendor!.fees,
                //
                mCurrencySymbol: AppStrings.currentCurrencySymbol,
                allowConvert: true,
              ),
            ),

            //aviso de pago del envío en efectivo
            if (vm.checkout!.deliveryAddress != null)
              CheckoutDriverCashDeliveryNoticeView(
                vm.checkout!.deliveryAddress!,
              ),

            //
            if (AppCurrencySystemService().currentCurrencyCode !=
                AppStrings.currencyCode)
              CurrencyConversionNotice(
                convertedAmount: vm.checkout!.totalWithTip.convertCurrency,
                originalAmount: vm.checkout!.totalWithTip,
                baseCurrency: AppStrings.currencyCode,
              ).pOnly(top: Vx.dp16),
          ]).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom),
        );
      },
    );
  }
}
