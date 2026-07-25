import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/vehicle_type.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:flutter/material.dart';

class NewHorizontalVehicleTypeListItem extends StatelessWidget {
  const NewHorizontalVehicleTypeListItem(
    this.vm,
    this.vehicleType, {
    super.key,
  });

  final VehicleType vehicleType;
  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    final selected = vm.selectedVehicleType?.id == vehicleType.id;
    final symbol =
        vehicleType.currency?.symbol ?? AppStrings.currentCurrencySymbol;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color:
          selected
              ? AppColor.primaryColor.withOpacity(.12)
              : colors.surfaceContainerHighest.withOpacity(.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColor.primaryColor : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => vm.changeSelectedVehicleType(vehicleType),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomImage(
                  imageUrl: vehicleType.photo,
                  boxFit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$symbol ${vehicleType.total.convertIf(vehicleType.currency == null).currencyValueFormat()}',
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                vehicleType.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
