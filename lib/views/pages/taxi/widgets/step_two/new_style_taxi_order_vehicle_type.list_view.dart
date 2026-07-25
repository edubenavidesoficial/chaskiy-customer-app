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
    final cardWidth = (width * .31).clamp(112.0, 142.0);

    return LoadingIndicator(
      loading: vm.busy(vm.vehicleTypes),
      child: SizedBox(
        height: 142,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
