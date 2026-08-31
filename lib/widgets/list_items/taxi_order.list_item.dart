import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/widgets/list_items/order_card.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiOrderListItem extends StatelessWidget {
  const TaxiOrderListItem({
    required this.order,
    this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function? onPayPressed;
  final Function orderPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final currencySymbol =
        order.taxiOrder?.currency?.symbol ?? AppStrings.currencySymbol;

    return OrderCard(
      onPressed: orderPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.isOngoing && !order.isScheduled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Viaje activo · Toca para continuar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  Utils.orderDate(order.createdAt),
                  style: mutedStyle,
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusChip(order.Taxistatus),
            ],
          ),
          const SizedBox(height: 10),
          _addressRow(
            context,
            AppImages.pickupLocation,
            "${order.taxiOrder?.pickupAddress}",
          ),
          DottedLine(
            direction: Axis.vertical,
            lineThickness: 2,
            dashGapLength: 1,
            dashColor: AppColor.primaryColor,
          ).wh(1, 14).px(5),
          _addressRow(
            context,
            AppImages.dropoffLocation,
            "${order.taxiOrder?.dropoffAddress}",
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text("#${order.code}", style: mutedStyle)),
              Text(
                "$currencySymbol ${order.total}".currencyFormat(currencySymbol),
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

  Widget _addressRow(BuildContext context, String icon, String address) {
    return Row(
      children: [
        Image.asset(icon).wh(12, 12),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
