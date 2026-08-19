import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/view_models/taxi_new_order_location_entry.vm.dart';

class NewTaxiPickOnMapButton extends StatelessWidget {
  const NewTaxiPickOnMapButton({Key? key, required this.taxiNewOrderViewModel})
    : super(key: key);

  final NewTaxiOrderLocationEntryViewModel taxiNewOrderViewModel;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: taxiNewOrderViewModel.showChooseOnMap,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              onTap: taxiNewOrderViewModel.handleChooseOnMap,
              leading: Icon(Icons.map_outlined, color: AppColor.primaryColor),
              title: const Text('Elegir en el mapa'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
