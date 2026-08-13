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
              //logo del negocio: es lo que la persona reconoce de un vistazo
              CustomImage(
                imageUrl: order.vendor?.logo,
                width: 52,
                height: 52,
              ).cornerRadius(14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${order.vendor?.name}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OrderStatusChip(order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_summary(), style: mutedStyle),
                    Text(Utils.orderDate(order.createdAt), style: mutedStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text("#${order.code}", style: mutedStyle)),
              Text(
                "${AppStrings.currencySymbol} ${order.total}".currencyFormat(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
