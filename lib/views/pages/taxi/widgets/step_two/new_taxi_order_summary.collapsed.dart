import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/view_models/taxi_new_order_summary.vm.dart';
import 'package:chaskiy/views/pages/taxi/widgets/order_taxi.button.dart';
import 'package:chaskiy/views/pages/taxi/widgets/step_two/new_style_taxi_order_vehicle_type.list_view.dart';
import 'package:chaskiy/views/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Volver',
                      onPressed: () => vm.closeOrderSummary(clear: false),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vm.hasConfirmedVehicleChoice
                                ? 'Confirma tu viaje'
                                : 'Elige tu viaje',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            vm.hasConfirmedVehicleChoice
                                ? 'Revisa el pago y solicita tu vehículo'
                                : 'Compara opciones y precios',
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
              if (vm.hasConfirmedVehicleChoice)
                _ConfirmedVehicleCard(vm: vm)
              else
                NewTaxiVehicleTypeListView(vm: vm),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
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

class _ConfirmedVehicleCard extends StatelessWidget {
  const _ConfirmedVehicleCard({required this.vm});

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    final vehicle = vm.selectedVehicleType!;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: .42),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.primary.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 48,
              child: CustomImage(
                imageUrl: vehicle.photo,
                boxFit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Vehículo seleccionado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: vm.revealVehicleOptions,
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }
}
