import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/driver.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiDriverInfoView extends StatelessWidget {
  const TaxiDriverInfoView(this.driver, {required this.order, super.key});

  final Order order;
  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(order.status, scheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child:
                  CustomImage(
                    imageUrl: driver.photo,
                    width: 54,
                    height: 54,
                  ).box.roundedFull.clip(Clip.antiAlias).make(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${driver.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColor.ratingColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        driver.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${driver.vehicle?.reg_no}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${driver.vehicle?.vehicleInfo}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(_statusIcon(order.status), color: statusColor, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  driverTripStatus(order),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 29),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'ready':
        return const Color(0xFFB46A00);
      case 'enroute':
      case 'preparing':
        return const Color(0xFF1769AA);
      case 'delivered':
      case 'completed':
        return const Color(0xFF16805C);
      case 'failed':
      case 'cancelled':
        return scheme.error;
      default:
        return scheme.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ready':
        return Icons.location_on_outlined;
      case 'enroute':
      case 'preparing':
        return Icons.route_outlined;
      case 'delivered':
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'failed':
      case 'cancelled':
        return Icons.error_outline_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  String driverTripStatus(Order order) {
    switch (order.status) {
      case 'pending':
        return 'Searching for driver'.tr();
      case 'preparing':
        return 'Driver on the way to you'.tr();
      case 'ready':
        return 'Driver has arrived your pickup location'.tr();
      case 'enroute':
        return 'Driver enroute to dropoff location'.tr();
      case 'delivered':
        return 'Driver has dropped you'.tr();
      case 'completed':
        return 'Trip completed'.tr();
      case 'failed':
        return 'Trip failed'.tr();
      default:
        return 'Driver is on the way'.tr();
    }
  }
}
