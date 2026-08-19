import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/views/pages/order/widgets/order_details_card.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderStatusHeader extends StatelessWidget {
  const OrderStatusHeader({required this.vm, Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return OrderDetailsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImage(
            imageUrl: vm.order.vendor?.logo,
            width: 64,
            height: 64,
          ).cornerRadius(8),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderStatusChip(vm.order.status),
                const SizedBox(height: 6),
                Text(
                  vm.order.vendor?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Utils.orderDate(vm.order.updatedAt)} · #${vm.order.code}',
                  maxLines: 2,
                  style: mutedStyle,
                ),
              ],
            ),
          ),
          //código de verificación: el repartidor lo escanea al entregar
          if (!vm.order.isTaxi && !vm.order.isSerice)
            IconButton(
              onPressed: vm.showVerificationQRCode,
              icon: const Icon(FlutterIcons.qrcode_ant, size: 22),
              tooltip: 'Código QR',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                foregroundColor: theme.colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
