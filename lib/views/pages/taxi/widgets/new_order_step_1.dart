import 'package:flutter/material.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked/stacked.dart';

import 'step_one/new_taxi_order_entry.collapsed.dart';
import 'step_one/new_taxi_order_entry.panel.dart';

class NewTaxiOrderLocationEntryView extends StatelessWidget {
  const NewTaxiOrderLocationEntryView(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTaxiOrderLocationEntryViewModel>.reactive(
      viewModelBuilder: () => NewTaxiOrderLocationEntryViewModel(context, vm),
      onViewModelReady:
          (vm) => WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.initialise();
          }),
      builder: (context, taxiNewOrderViewModel, child) {
        return Visibility(
          visible: vm.currentStep(1),
          child: Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final minimumHeight =
                    taxiNewOrderViewModel.customViewHeight
                        .clamp(0.0, availableHeight)
                        .toDouble();

                return SlidingUpPanel(
                  color: Colors.transparent,
                  panel: NewTaxiOrderEntryPanel(taxiNewOrderViewModel),
                  collapsed: NewTaxiOrderEntryCollapsed(taxiNewOrderViewModel),
                  controller: taxiNewOrderViewModel.panelController,
                  minHeight: minimumHeight,
                  maxHeight: availableHeight,
                  onPanelClosed: taxiNewOrderViewModel.notifyListeners,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
