import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/widgets/list_items/new_horizontal_vehicle_type.list_item.dart';
import 'package:chaskiy/widgets/states/loading_indicator.dart';
import 'package:flutter/material.dart';

class NewTaxiVehicleTypeListView extends StatelessWidget {
  const NewTaxiVehicleTypeListView({
    super.key,
    this.min = false,
    required this.vm,
    this.axis = Axis.horizontal,
  });

  final TaxiViewModel vm;
  final bool min;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width * .34).clamp(124.0, 154.0);

    return LoadingIndicator(
      loading: vm.busy(vm.vehicleTypes),
      child: SizedBox(
        height: 154,
        child:
            vm.vehicleTypes.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vm.vehicleTypesLoadFailed
                              ? 'No pudimos cargar los vehículos disponibles.'
                              : 'No hay vehículos disponibles para esta ruta.',
                          textAlign: TextAlign.center,
                        ),
                        if (vm.vehicleTypesLoadFailed)
                          TextButton.icon(
                            onPressed: vm.fetchVehicleTypes,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Intentar nuevamente'),
                          ),
                      ],
                    ),
                  ),
                )
                : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: cardWidth * 4,
                  itemCount: vm.vehicleTypes.length,
                  itemBuilder:
                      (context, index) => SizedBox(
                        width: cardWidth,
                        child: NewHorizontalVehicleTypeListItem(
                          vm,
                          vm.vehicleTypes[index],
                        ),
                      ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                ),
      ),
    );
  }
}
