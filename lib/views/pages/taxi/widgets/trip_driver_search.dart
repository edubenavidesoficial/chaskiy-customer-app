import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/view_models/taxi.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/views/pages/order/widgets/taxi_order_trip_verification.view.dart';

class TripDriverSearch extends StatelessWidget {
  const TripDriverSearch(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: Vx.dp20,
      left: Vx.dp20,
      right: Vx.dp20,
      child: MeasureSize(
        onChange: (size) {
          vm.updateGoogleMapPadding(height: size.height);
        },
        child:
            VStack([
                  //cancel order button
                  "Buscando un conductor disponible"
                      .tr()
                      .text
                      .semiBold
                      .makeCentered(),
                  "Puedes compartir el código cuando el conductor llegue"
                      .tr()
                      .text
                      .color(context.theme.colorScheme.onSurfaceVariant)
                      .sm
                      .makeCentered()
                      .py8(),
                  if (vm.onGoingOrderTrip != null)
                    TaxiOrderTripVerificationView(vm.onGoingOrderTrip!).py8(),
                  //loading indicator
                  BusyIndicator().centered().py8(),
                  //only show if driver is yet to be assigned
                  Visibility(
                    visible: vm.onGoingOrderTrip?.canCancelTaxi ?? false,
                    child:
                        CustomTextButton(
                          title: "Cancelar viaje".tr(),
                          titleColor: AppColor.getStausColor("failed"),
                          loading: vm.busy(vm.onGoingOrderTrip),
                          onPressed: vm.cancelTrip,
                        ).centered(),
                  ),
                ])
                .p20()
                .box
                .color(context.theme.colorScheme.surface)
                .roundedSM
                .outerShadow2Xl
                .make(),
      ),
    );
  }
}
