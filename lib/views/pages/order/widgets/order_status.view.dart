import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/utils/order_status_localizer.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:jiffy/jiffy.dart';

class OrderStatusView extends StatelessWidget {
  const OrderStatusView(this.vm, {Key? key}) : super(key: key);

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
        //el estado del pedido ya está arriba; aquí solo hace falta el del pago
        Row(
          children: [
            Expanded(child: Text("Payment Status".tr(), style: mutedStyle)),
            OrderStatusChip(vm.order.paymentStatus),
          ],
        ),

        //quién paga, solo en envíos de paquetes
        if (vm.order.isPackageDelivery) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text("Order Payer".tr(), style: mutedStyle)),
              Text(
                (vm.order.payer == "1" ? "Sender" : "Receiver").tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        //pedido programado
        if (vm.order.isScheduled) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text("Scheduled Date".tr(), style: mutedStyle)),
              Text(
                "${Jiffy.parse(vm.order.pickupDate!).format(pattern: "d MMM y")}"
                " · "
                "${Jiffy.parse(vm.order.pickupTime!).format(pattern: "HH:mm")}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),
        Timeline.tileBuilder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          builder: TimelineTileBuilder.connected(
            contentsAlign: ContentsAlign.basic,
            nodePositionBuilder: (context, index) => 0.00,
            indicatorPositionBuilder: (context, index) => 0.14,
            indicatorBuilder: (context, index) {
              final orderStatus = vm.order.totalStatuses[index];
              return (orderStatus.passed ?? true)
                  ? DotIndicator(
                    color: theme.colorScheme.primary,
                    size: 24,
                    child: Icon(
                      FlutterIcons.check_ant,
                      size: 13,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                  : OutlinedDotIndicator(
                    color: theme.colorScheme.outline,
                    size: 24,
                  );
            },
            connectorBuilder:
                (context, index, connectorType) => SolidLineConnector(
                  color: theme.colorScheme.outlineVariant,
                  thickness: 2,
                ),
            contentsBuilder: (context, index) {
              final orderStatus = vm.order.totalStatuses[index];
              final passed = orderStatus.passed ?? true;

              return Padding(
                padding: const EdgeInsets.only(left: 14, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spanishOrderStatus('${orderStatus.name}'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: passed ? FontWeight.w700 : FontWeight.w500,
                        color:
                            passed
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    //el patrón anterior dejaba escrito "'p. m.t'" en la fecha
                    if (orderStatus.createdAt != null)
                      Text(
                        Utils.orderDate(orderStatus.createdAt!),
                        style: mutedStyle,
                      ),
                    if (_canTrack(index)) ...[
                      const SizedBox(height: 10),
                      CustomButton(
                        title: "Track Order".tr(),
                        icon: FlutterIcons.map_ent,
                        height: 44,
                        onPressed: vm.trackOrder,
                        loading: vm.busy(vm.order),
                      ),
                    ],
                  ],
                ),
              );
            },
            itemCount: vm.order.totalStatuses.length,
          ),
        ),
      ],
    );
  }

  /// El seguimiento en mapa solo sirve mientras el pedido va en camino y ya
  /// tiene conductor asignado.
  bool _canTrack(int index) {
    final orderStatus = vm.order.totalStatuses[index];
    return orderStatus.createdAt != null &&
        "${orderStatus.name}" == "enroute" &&
        vm.order.status == "enroute" &&
        AppStrings.enableOrderTracking &&
        (vm.order.dropoffLocation != null ||
            vm.order.deliveryAddress != null) &&
        vm.order.driverId != null;
  }
}
