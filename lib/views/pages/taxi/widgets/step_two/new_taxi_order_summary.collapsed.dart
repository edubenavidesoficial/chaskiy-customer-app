import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/view_models/taxi_new_order_summary.vm.dart';
import 'package:chaskiy/views/pages/taxi/widgets/order_taxi.button.dart';
import 'package:chaskiy/views/pages/taxi/widgets/step_two/new_style_taxi_order_vehicle_type.list_view.dart';
import 'package:chaskiy/views/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:flutter/material.dart';
import 'package:measure_size/measure_size.dart';

class NewTaxiOrderSummaryCollapsed extends StatelessWidget {
  const NewTaxiOrderSummaryCollapsed(
    this.newTaxiOrderSummaryViewModel, {
    super.key,
  });

  final NewTaxiOrderSummaryViewModel newTaxiOrderSummaryViewModel;

  @override
  Widget build(BuildContext context) {
    final vm = newTaxiOrderSummaryViewModel.taxiViewModel;
    final colors = Theme.of(context).colorScheme;

    return MeasureSize(
      onChange: (size) => vm.updateGoogleMapPadding(height: size.height + 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x240F2A4D),
              blurRadius: 28,
              offset: Offset(0, -7),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Volver',
                      onPressed: () => vm.closeOrderSummary(clear: false),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Elige tu viaje',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Compara opciones y precios',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: vm.closeOrderSummary,
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
              NewTaxiVehicleTypeListView(vm: vm),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: NewTaxiOrderPaymentMethodSelectionView(
                        vm: newTaxiOrderSummaryViewModel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Badge(
                      isLabelVisible: vm.coupon != null,
                      label: const Text('1'),
                      backgroundColor: AppColor.primaryColor,
                      child: IconButton.filledTonal(
                        tooltip: 'Agregar cupón',
                        onPressed: newTaxiOrderSummaryViewModel.openCoupnDialog,
                        icon: const Icon(Icons.local_offer_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              OrderTaxiButton(vm),
            ],
          ),
        ),
      ),
    );
  }
}
