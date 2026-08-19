import 'package:flutter/material.dart';
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
          label: 'Recogida',
          address: "${vm.order.vendor?.address}",
        ),
        if (vm.order.deliveryAddress != null) ...[
          Container(
            width: 2,
            height: 18,
            margin: const EdgeInsets.only(left: 9),
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          _point(
            context,
            icon: AppImages.dropoffLocation,
            label: 'Entrega',
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
    required String label,
    required String address,
    String? name,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, width: 20, height: 20).pOnly(top: 2),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(address, style: theme.textTheme.bodyLarge),
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
