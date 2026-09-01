import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/list_items/order_card.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:jiffy/jiffy.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderBookingListItem extends StatelessWidget {
  const OrderBookingListItem({
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
    final booking = order.bookingOrder;
    final property = booking?.property;

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
                imageUrl: property?.mainPhoto,
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
                            booking == null
                                ? ''
                                : "${Jiffy.parse(booking.checkInDate.toString()).format(pattern: 'd MMM')} - ${Jiffy.parse(booking.checkOutDate.toString()).format(pattern: 'd MMM y')}",
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
                            property?.name ?? "",
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
                    if (order.paymentMethod != null)
                      Text("${order.paymentMethod?.name}", style: mutedStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reserva #${order.code}',
            style: mutedStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
