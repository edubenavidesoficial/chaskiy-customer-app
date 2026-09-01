import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/list_items/order_card.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    required this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function onPayPressed;
  final Function orderPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return OrderCard(
      onPressed: orderPressed,
      onPayPressed:
          (order.isPaymentPending && order.isOngoing) ? onPayPressed : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImage(
                imageUrl: order.vendor?.logo,
                width: 56,
                height: 56,
              ).cornerRadius(16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        OrderStatusChip(order.status),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Utils.orderDate(order.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: mutedStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${order.vendor?.name}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${AppStrings.currencySymbol} ${order.total}"
                              .currencyFormat(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _summary(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: mutedStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pedido #${order.code}',
            style: mutedStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Qué se pidió y cómo se paga, en una línea: "2 productos · Efectivo".
  String _summary() {
    final parts = <String>[];

    if (order.isPackageDelivery) {
      parts.add("${order.packageType?.name}");
    } else if (order.isSerice) {
      parts.add("${order.orderService?.service?.category?.name}");
    } else {
      final quantity = order.orderProducts?.length ?? 0;
      //el singular se leía "1 producto (s)"
      parts.add(
        (quantity == 1 ? "%s product" : "%s products").tr().fill([quantity]),
      );
    }

    if (order.paymentMethod != null) {
      parts.add("${order.paymentMethod?.name}");
    }
    return parts.join(" · ");
  }
}
