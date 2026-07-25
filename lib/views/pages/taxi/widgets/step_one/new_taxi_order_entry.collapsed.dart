import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/taxi_order_location_history.list_item.dart';
import 'package:flutter/material.dart';
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
                        Material(
                          color: colors.surfaceContainerHighest.withOpacity(
                            .65,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: taxiNewOrderViewModel.onDestinationPressed,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor.withOpacity(
                                        .12,
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '¿A dónde vas?',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Busca una dirección o elige en el mapa',
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
