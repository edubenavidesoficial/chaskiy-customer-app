import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/widgets/list_items/parcel_order_stop.list_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderAddressesView extends StatelessWidget {
  const OrderAddressesView(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.order.isPackageDelivery) {
      return VStack([
        ParcelOrderStopListView(
          "Pickup Location",
          vm.order.orderStops!.first,
          canCall: vm.order.canChatVendor,
        ),
        ...stopsList(),
        ParcelOrderStopListView(
          "Dropoff Location",
          vm.order.orderStops!.last,
          canCall: vm.order.canChatVendor,
        ),
      ]);
    }

    //recorrido del pedido: de dónde sale y a dónde llega
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _point(
          context,
          icon: AppImages.pickupLocation,
          address: "${vm.order.vendor?.address}",
        ),
        if (vm.order.deliveryAddress != null) ...[
          DottedLine(
            direction: Axis.vertical,
            lineThickness: 2,
            dashGapLength: 1,
            dashColor: AppColor.primaryColor,
          ).wh(1, 16).px(7),
          _point(
            context,
            icon: AppImages.dropoffLocation,
            address: "${vm.order.deliveryAddress!.address}",
            name: vm.order.deliveryAddress!.name,
          ),
        ],
      ],
    );
  }

  Widget _point(
    BuildContext context, {
    required String icon,
    required String address,
    String? name,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, width: 15, height: 15).pOnly(top: 3),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address, style: theme.textTheme.bodyMedium),
              if (name != null && name.isNotEmpty)
                Text(
                  name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  //
  List<Widget> stopsList() {
    List<Widget> stopViews = [];
    if (vm.order.orderStops != null && vm.order.orderStops!.length > 2) {
      stopViews =
          vm.order.orderStops!
              .sublist(1, vm.order.orderStops!.length - 1)
              .mapIndexed((stop, index) {
                return VStack([
                  ParcelOrderStopListView(
                    "Stop".tr() + " ${index + 1}",
                    stop,
                    canCall: vm.order.canChatVendor,
                  ),
                ]);
              })
              .toList();
    } else {
      stopViews.add(UiSpacer.emptySpace());
    }

    return stopViews;
  }
}
