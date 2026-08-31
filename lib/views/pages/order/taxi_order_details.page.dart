import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_taxi_settings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/views/pages/cart/widgets/amount_tile.dart';
import 'package:chaskiy/views/pages/order/widgets/basic_taxi_trip_info.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_driver_info.view.dart';
import 'package:chaskiy/views/pages/order/widgets/taxi_order_trip_verification.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_details_card.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/cards/order_summary.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/constants/sizes.dart';

import 'widgets/taxi_trip_map.preview.dart';

class TaxiOrderDetailPage extends StatefulWidget {
  const TaxiOrderDetailPage({required this.order, Key? key}) : super(key: key);

  //
  final Order order;

  @override
  _TaxiOrderDetailPageState createState() => _TaxiOrderDetailPageState();
}

class _TaxiOrderDetailPageState extends State<TaxiOrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<OrderDetailsViewModel>.reactive(
      viewModelBuilder: () => OrderDetailsViewModel(context, widget.order),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        String currencySymbol = vm.order.taxiOrder!.currencySymbol;

        //
        return BasePage(
          title: "Trip Details".tr(),
          elevation: 0,
          showAppBar: true,
          showLeadingAction: true,
          isLoading: vm.isBusy,
          appBarColor: context.theme.colorScheme.surfaceContainerLow,
          appBarItemColor: context.theme.colorScheme.onSurface,
          backgroundColor: context.theme.colorScheme.surfaceContainerLow,
          body:
              VStack([
                //taxi trip map preview
                TaxiTripMapPreview(vm.order),

                VStack([
                  if (vm.order.isOngoing && !vm.order.isScheduled)
                    _ActiveTaxiActions(vm: vm),

                  //basic info
                  OrderDetailsCard(child: BasicTaxiTripInfoView(vm.order)),

                  //payment status
                  if (_showPaymentAction(vm))
                    OrderDetailsCard(child: OrderPaymentInfoView(vm)),

                  //driver
                  if (vm.order.driver != null)
                    OrderDetailsCard(
                      child: OrderDriverInfoView(
                        vm.order,
                        rateDriverAction: vm.rateDriver,
                      ),
                    ),

                  //trip codes (verification)
                  if (!vm.order.isCompleted &&
                      AppTaxiSettings.requiredBookingCode)
                    OrderDetailsCard(
                      child: TaxiOrderTripVerificationView(vm.order),
                    ),

                  //order summary
                  OrderDetailsCard(
                    child: OrderSummary(
                      subTotal: vm.order.subTotal!,
                      discount: vm.order.discount ?? 0,
                      driverTip: vm.order.tip ?? 0,
                      tax: vm.order.tax,
                      total: vm.order.total!,
                      mCurrencySymbol:
                          "${vm.order.taxiOrder!.currency != null ? vm.order.taxiOrder!.currency!.symbol : AppStrings.currencySymbol}",
                      //
                      customWidget: VStack([
                        AmountTile(
                          "Base Fare".tr(),
                          "${currencySymbol} ${vm.order.taxiOrder!.base_fare ?? 0}"
                              .currencyFormat(currencySymbol),
                        ).py2(),
                        AmountTile(
                          ("Trip Distance".tr() + " (Km)"),
                          "${vm.order.taxiOrder!.trip_distance ?? 0}  (${vm.order.taxiOrder!.distance_fare ?? 0}/Km)",
                        ).py2(),
                        AmountTile(
                          "Trip Duration".tr(),
                          "${vm.order.taxiOrder!.trip_time ?? 0}  (${vm.order.taxiOrder!.time_fare ?? 0}/${'Minute'.tr()})",
                        ).py2(),
                        DottedLine(
                          dashColor: context.textTheme.bodyLarge!.color!,
                        ).py8(),
                      ]),
                    ),
                  ),

                  (context.percentHeight * 10).heightBox,
                ], spacing: Sizes.paddingSizeDefault).p(
                  Sizes.paddingSizeDefault,
                ),
              ]).scrollVertical(),
          bottomSheet:
              vm.order.isScheduled
                  ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: Offset(0, 0),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: CustomButton(
                        loading: vm.busy(vm.order),
                        color: AppColor.closeColor,
                        title: "Cancel Order".tr(),
                        onPressed: vm.cancelOrder,
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  bool _showPaymentAction(OrderDetailsViewModel vm) {
    return (vm.order.isPaymentPending && vm.order.isOngoing) ||
        (vm.order.paymentStatus == "request" &&
            ["pending"].contains(vm.order.status));
  }
}

class _ActiveTaxiActions extends StatelessWidget {
  const _ActiveTaxiActions({required this.vm});

  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors_rounded, color: scheme.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tienes un viaje activo'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Vuelve al seguimiento para ver al conductor y el avance del viaje.'
                .tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: vm.resumeTaxiTrip,
              icon: const Icon(Icons.route_rounded),
              label: Text('Volver al seguimiento'.tr()),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: vm.shareTaxiTrip,
              icon: const Icon(Icons.ios_share_rounded),
              label: Text('Compartir viaje'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
