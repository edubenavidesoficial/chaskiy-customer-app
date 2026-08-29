import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/taxi_order_location_history.list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:measure_size/measure_size.dart';

class NewTaxiOrderEntryCollapsed extends StatelessWidget {
  const NewTaxiOrderEntryCollapsed(this.taxiNewOrderViewModel, {super.key});

  final NewTaxiOrderLocationEntryViewModel taxiNewOrderViewModel;

  @override
  Widget build(BuildContext context) {
    final TaxiViewModel vm = taxiNewOrderViewModel.taxiViewModel;
    final colors = Theme.of(context).colorScheme;

    return MeasureSize(
      onChange: (size) => vm.updateGoogleMapPadding(height: size.height + 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F0F2A4D),
              blurRadius: 28,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child:
                vm.isBusy
                    ? const SizedBox(
                      height: 92,
                      child: Center(child: BusyIndicator()),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: colors.outlineVariant,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        SizedBox(
                          height: 72,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _VehiclePreference(
                                label: 'Auto',
                                asset: AppImages.mapVehicleCar,
                                selected: vm.preferredVehicleKind == 'car',
                                onTap:
                                    () => vm.selectPreferredVehicleKind('car'),
                              ),
                              const SizedBox(width: 10),
                              _VehiclePreference(
                                label: 'Taxi',
                                asset: AppImages.mapVehicleTaxi,
                                selected: vm.preferredVehicleKind == 'taxi',
                                onTap:
                                    () => vm.selectPreferredVehicleKind('taxi'),
                              ),
                              const SizedBox(width: 10),
                              _VehiclePreference(
                                label: 'Moto',
                                asset: AppImages.mapVehicleMotorcycle,
                                selected:
                                    vm.preferredVehicleKind == 'motorcycle',
                                onTap:
                                    () => vm.selectPreferredVehicleKind(
                                      'motorcycle',
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: colors.surfaceContainerHighest.withOpacity(
                            .72,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: taxiNewOrderViewModel.onDestinationPressed,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 30,
                                    color: colors.onSurface,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '¿A dónde quieres ir?',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Busca tu destino o elige en el mapa',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (AppStrings.canScheduleTaxiOrder)
                                    IconButton(
                                      tooltip: 'Programar viaje',
                                      onPressed:
                                          taxiNewOrderViewModel
                                              .onScheduleOrderPressed,
                                      icon: const Icon(
                                        Icons.calendar_month_rounded,
                                      ),
                                      color: AppColor.primaryColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (taxiNewOrderViewModel
                            .shortPreviousAddressesList
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          CustomListView(
                            isLoading: taxiNewOrderViewModel.busy(
                              taxiNewOrderViewModel.previousAddresses,
                            ),
                            dataSet:
                                taxiNewOrderViewModel
                                    .shortPreviousAddressesList,
                            padding: EdgeInsets.zero,
                            noScrollPhysics: true,
                            itemBuilder: (ctx, index) {
                              final address =
                                  taxiNewOrderViewModel
                                      .shortPreviousAddressesList[index];
                              return TaxiOrderHistoryListItem(
                                address,
                                onPressed:
                                    taxiNewOrderViewModel.onDestinationSelected,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _VehiclePreference extends StatelessWidget {
  const _VehiclePreference({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color:
          selected
              ? AppColor.primaryColor.withOpacity(.13)
              : colors.surfaceContainerHighest.withOpacity(.42),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 94,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? AppColor.primaryColor : colors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(asset, width: 39, height: 32),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColor.primaryColor : colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
