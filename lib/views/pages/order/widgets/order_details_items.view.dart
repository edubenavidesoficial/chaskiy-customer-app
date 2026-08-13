import 'package:flutter/material.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/views/pages/cart/widgets/amount_tile.dart';
import 'package:chaskiy/views/pages/order/widgets/order_stops.view.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/order_product.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderDetailsItemsView extends StatelessWidget {
  const OrderDetailsItemsView(this.vm, {Key? key}) : super(key: key);
  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //paradas del envío de paquete
        if (vm.order.isPackageDelivery) ...[
          OrderStopsView(vm),
          const SizedBox(height: 12),
          AmountTile("Package Type".tr(), "${vm.order.packageType?.name}"),
          AmountTile("Width".tr(), "${vm.order.width} cm"),
          AmountTile("Length".tr(), "${vm.order.length} cm"),
          AmountTile("Height".tr(), "${vm.order.height} cm"),
          AmountTile("Weight".tr(), "${vm.order.weight} kg"),
        ],

        if (vm.order.isSerice) ...[
          Text(
            "${vm.order.orderService?.service?.name}",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "${vm.order.orderService?.service?.category?.name}",
            style: mutedStyle,
          ),
          if (vm.order.orderService?.options != null &&
              vm.order.orderService!.options!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text("${vm.order.orderService?.options}", style: mutedStyle),
          ],
        ],

        //
        if (vm.order.orderProducts != null &&
            vm.order.orderProducts!.isNotEmpty)
          CustomListView(
            padding: EdgeInsets.zero,
            noScrollPhysics: true,
            dataSet: vm.order.orderProducts!,
            separatorBuilder:
                (_, __) => Divider(
                  height: 24,
                  color: theme.colorScheme.outlineVariant,
                ),
            itemBuilder: (context, index) {
              final orderProduct = vm.order.orderProducts![index];
              return OrderProductListItem(
                orderProduct: orderProduct,
                order: vm.order,
              );
            },
          ),

        //foto del pedido
        if (vm.order.attachments == null || vm.order.attachments!.isEmpty)
          if (vm.order.photo != null && !Utils.isDefaultImg(vm.order.photo!))
            CustomImage(
              imageUrl: vm.order.photo!,
              boxFit: BoxFit.cover,
              width: double.infinity,
              height: context.percentHeight * 25,
            ).cornerRadius(14).pOnly(top: 12),
      ],
    );
  }
}
