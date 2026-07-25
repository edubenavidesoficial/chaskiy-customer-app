import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:chaskiy/views/pages/taxi/widgets/step_one/new_taxi_pick_on_map.view.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/address.list_item.dart';
import 'package:chaskiy/widgets/taxi_custom_text_form_field.dart';
import 'package:flutter/material.dart';

class NewTaxiOrderEntryPanel extends StatelessWidget {
  const NewTaxiOrderEntryPanel(this.taxiNewOrderViewModel, {super.key});

  final NewTaxiOrderLocationEntryViewModel taxiNewOrderViewModel;

  @override
  Widget build(BuildContext context) {
    final TaxiViewModel vm = taxiNewOrderViewModel.taxiViewModel;
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child:
              vm.isBusy
                  ? const Center(child: BusyIndicator())
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  tooltip: 'Cerrar',
                                  onPressed: taxiNewOrderViewModel.closePanel,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tu ruta',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Indica el origen y el destino',
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
                                  IconButton.filledTonal(
                                    tooltip: 'Programar viaje',
                                    onPressed:
                                        taxiNewOrderViewModel
                                            .showSchedulePeriodPicker,
                                    icon: const Icon(
                                      Icons.calendar_month_rounded,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                14,
                                12,
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withOpacity(.55),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.radio_button_checked,
                                          color: AppColor.primaryColor,
                                          size: 20,
                                        ),
                                        Container(
                                          width: 2,
                                          height: 35,
                                          color: colors.outlineVariant,
                                        ),
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: AppColor.accentColor,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        TaxiCustomTextFormField(
                                          hintText: 'Punto de partida',
                                          controller: vm.pickupLocationTEC,
                                          focusNode: vm.pickupLocationFocusNode,
                                          onChanged:
                                              taxiNewOrderViewModel.searchPlace,
                                          clear: true,
                                          onClearPressed: () {
                                            vm.currentAddressSelectionStep = 1;
                                            taxiNewOrderViewModel
                                                .clearAlreadySelected();
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        TaxiCustomTextFormField(
                                          hintText: '¿A dónde vas?',
                                          controller: vm.dropoffLocationTEC,
                                          focusNode:
                                              vm.dropoffLocationFocusNode,
                                          onChanged:
                                              taxiNewOrderViewModel.searchPlace,
                                          clear: true,
                                          onClearPressed: () {
                                            vm.currentAddressSelectionStep = 2;
                                            taxiNewOrderViewModel
                                                .clearAlreadySelected();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CustomListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          isLoading: taxiNewOrderViewModel.busy(
                            taxiNewOrderViewModel.places,
                          ),
                          dataSet: taxiNewOrderViewModel.places ?? const [],
                          itemBuilder:
                              (context, index) => AddressListItem(
                                taxiNewOrderViewModel.places![index],
                                onAddressSelected:
                                    taxiNewOrderViewModel.onAddressSelected,
                              ),
                        ),
                      ),
                      NewTaxiPickOnMapButton(
                        taxiNewOrderViewModel: taxiNewOrderViewModel,
                      ),
                      if (!vm.pickupLocationFocusNode.hasFocus &&
                          !vm.dropoffLocationFocusNode.hasFocus)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: CustomButton(
                            title: 'Continuar',
                            onPressed: taxiNewOrderViewModel.moveToNextStep,
                          ),
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}
