import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
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
                                    () => _showConfiguredVehicleTypes(
                                      context,
                                      vm,
                                      'car',
                                      'Autos disponibles',
                                    ),
                              ),
                              const SizedBox(width: 10),
                              _VehiclePreference(
                                label: 'Taxi',
                                asset: AppImages.mapVehicleTaxi,
                                selected: vm.preferredVehicleKind == 'taxi',
                                onTap:
                                    () => _showConfiguredVehicleTypes(
                                      context,
                                      vm,
                                      'taxi',
                                      'Taxis disponibles',
                                    ),
                              ),
                              const SizedBox(width: 10),
                              _VehiclePreference(
                                label: 'Moto',
                                asset: AppImages.mapVehicleMotorcycle,
                                selected:
                                    vm.preferredVehicleKind == 'motorcycle',
                                onTap:
                                    () => _showConfiguredVehicleTypes(
                                      context,
                                      vm,
                                      'motorcycle',
                                      'Motos disponibles',
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

Future<void> _showConfiguredVehicleTypes(
  BuildContext context,
  TaxiViewModel vm,
  String kind,
  String title,
) async {
  await vm.selectPreferredVehicleKind(kind);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => _ConfiguredVehicleTypesSheet(vm: vm, kind: kind, title: title),
  );
}

class _ConfiguredVehicleTypesSheet extends StatefulWidget {
  const _ConfiguredVehicleTypesSheet({
    required this.vm,
    required this.kind,
    required this.title,
  });

  final TaxiViewModel vm;
  final String kind;
  final String title;

  @override
  State<_ConfiguredVehicleTypesSheet> createState() =>
      _ConfiguredVehicleTypesSheetState();
}

class _ConfiguredVehicleTypesSheetState
    extends State<_ConfiguredVehicleTypesSheet> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vehicleTypes = widget.vm.configuredTypesFor(widget.kind);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .64,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 16),
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'El precio final se calculará al elegir tu destino.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Flexible(
            child:
                vehicleTypes.isEmpty
                    ? _EmptyVehicleCategory(
                      failed: widget.vm.configuredVehicleTypesLoadFailed,
                      onRetry: () async {
                        await widget.vm.fetchConfiguredVehicleTypes(
                          force: true,
                        );
                        if (mounted) setState(() {});
                      },
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: vehicleTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final vehicleType = vehicleTypes[index];
                        return _ConfiguredVehicleTypeTile(
                          vehicleType: vehicleType,
                          selected:
                              widget.vm.preferredVehicleTypeId ==
                              vehicleType.id,
                          onTap: () {
                            widget.vm.selectPreferredVehicleType(vehicleType);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ConfiguredVehicleTypeTile extends StatelessWidget {
  const _ConfiguredVehicleTypeTile({
    required this.vehicleType,
    required this.selected,
    required this.onTap,
  });

  final VehicleType vehicleType;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final symbol =
        vehicleType.currency?.symbol ?? AppStrings.currentCurrencySymbol;
    return Material(
      color:
          selected
              ? AppColor.primaryColor.withOpacity(.12)
              : colors.surfaceContainerHighest.withOpacity(.48),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColor.primaryColor : colors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                height: 52,
                child: CustomImage(
                  imageUrl: vehicleType.photo,
                  boxFit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleType.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tarifa base $symbol${vehicleType.baseFare.toStringAsFixed(2)} · Mínima $symbol${vehicleType.minFare.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? AppColor.primaryColor : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVehicleCategory extends StatelessWidget {
  const _EmptyVehicleCategory({required this.failed, required this.onRetry});

  final bool failed;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car_outlined, size: 44),
          const SizedBox(height: 12),
          Text(
            failed
                ? 'No pudimos cargar los vehículos configurados.'
                : 'No hay vehículos activos en esta categoría.',
            textAlign: TextAlign.center,
          ),
          if (failed) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar nuevamente'),
            ),
          ],
        ],
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
